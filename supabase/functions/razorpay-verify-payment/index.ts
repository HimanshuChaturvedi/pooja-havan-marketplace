import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.8';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabaseClient = createClient(supabaseUrl, supabaseServiceKey);

    const { payment_id, order_id, signature, internal_id, type } = await req.json();

    if (!payment_id || !order_id || !signature || !internal_id || !type) {
      return new Response(
        JSON.stringify({ error: 'Missing payment details or order identifiers' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 1. Validate Razorpay signature on server
    const keySecret = Deno.env.get('RAZORPAY_KEY_SECRET');
    if (!keySecret) {
      throw new Error('RAZORPAY_KEY_SECRET is not configured in Edge Function secrets');
    }

    const payload = `${order_id}|${payment_id}`;
    const expectedSignature = await hmacSha256(payload, keySecret);

    if (!constantTimeEqual(expectedSignature, signature)) {
      console.warn(`[verify-payment] Signature mismatch. Expected: ${expectedSignature}, Received: ${signature}`);
      return new Response(
        JSON.stringify({ error: 'Razorpay cryptographic signature verification failed' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 2. Resolve trusted total amount from database
    let dbAmount = 0;
    if (type === 'ritual') {
      const { data: booking, error: fetchErr } = await supabaseClient
        .from('bookings')
        .select('total_amount')
        .eq('id', internal_id)
        .maybeSingle();

      if (fetchErr) throw fetchErr;
      if (!booking) {
        return new Response(
          JSON.stringify({ error: 'Booking not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
      dbAmount = booking.total_amount;
    } else if (type === 'samagri') {
      const { data: order, error: fetchErr } = await supabaseClient
        .from('samagri_orders')
        .select('total_amount')
        .eq('id', internal_id)
        .maybeSingle();

      if (fetchErr) throw fetchErr;
      if (!order) {
        return new Response(
          JSON.stringify({ error: 'Samagri order not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
      dbAmount = order.total_amount;
    } else {
      return new Response(
        JSON.stringify({ error: 'Invalid order type' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const amountInPaise = Math.round(dbAmount * 100);

    // 3. Call database atomic RPC function (Handles locking, validation, idempotency and status updates)
    const { data: rpcResult, error: rpcErr } = await supabaseClient.rpc('confirm_razorpay_payment', {
      p_payment_id: payment_id,
      p_order_id: order_id,
      p_signature: signature,
      p_internal_id: internal_id,
      p_type: type,
      p_amount: amountInPaise
    });

    if (rpcErr) {
      console.error('Database RPC error:', rpcErr);
      throw rpcErr;
    }

    if (!rpcResult.success) {
      console.warn('Payment verification rejected by DB transaction:', rpcResult.error);
      return new Response(
        JSON.stringify({ error: rpcResult.error }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 4. Trigger WhatsApp Notifications ONLY if database transaction committed successfully and it was NOT already paid
    if (rpcResult.already_paid === false) {
      // Trigger notifications asynchronously (errors in sending must NOT invalidate/rollback successful payments)
      edgeTriggerNotifications(supabaseClient, internal_id, type).catch(err => {
        console.error('Asynchronous WhatsApp notification failed:', err);
      });
    }

    return new Response(
      JSON.stringify({ success: true, message: rpcResult.message }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error: any) {
    console.error('Verification Error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal Server Error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

// --- HELPERS ---

async function hmacSha256(message: string, secret: string): Promise<string> {
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const messageData = encoder.encode(message);

  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const signature = await crypto.subtle.sign(
    'HMAC',
    cryptoKey,
    messageData
  );

  return Array.from(new Uint8Array(signature))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

function constantTimeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

// Helper to trigger Meta Graph API WhatsApp notifications
async function sendWhatsAppTemplate(phone: string, templateName: string, parameters: string[], language: string = 'en') {
  const WHATSAPP_ACCESS_TOKEN = Deno.env.get('WHATSAPP_ACCESS_TOKEN');
  const WHATSAPP_PHONE_NUMBER_ID = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID');
  
  if (!WHATSAPP_ACCESS_TOKEN || !WHATSAPP_PHONE_NUMBER_ID) {
    console.warn('[WA-NOTIF] Secrets not configured. Mocking success.');
    return;
  }

  const formattedPhone = phone.replace(/\D/g, '');
  const templateParams = parameters.map(p => ({ type: 'text', text: p }));

  const payload = {
    messaging_product: 'whatsapp',
    to: formattedPhone,
    type: 'template',
    template: {
      name: templateName,
      language: { code: language },
      components: templateParams.length > 0 ? [{
        type: 'body',
        parameters: templateParams
      }] : []
    }
  };

  console.log(`[WA-NOTIF] Sending template=${templateName} to=${formattedPhone}`);
  try {
    const res = await fetch(`https://graph.facebook.com/v21.0/${WHATSAPP_PHONE_NUMBER_ID}/messages`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${WHATSAPP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });
    
    const result = await res.json();
    console.log(`[WA-NOTIF] Meta API response status=${res.status} body=${JSON.stringify(result)}`);
  } catch (e) {
    console.error(`[WA-NOTIF] Error invoking Meta Graph API:`, e);
  }
}

// Orchestrator for sending WhatsApp notifications on successful payment
async function edgeTriggerNotifications(supabaseClient: any, internalId: string, type: string) {
  try {
    console.log(`[WA-NOTIF] Orchestrating notifications for internalId=${internalId} type=${type}`);
    
    if (type === 'ritual') {
      // 1. Fetch booking details
      const { data: booking, error: fetchErr } = await supabaseClient
        .from('bookings')
        .select('*')
        .eq('id', internalId)
        .maybeSingle();

      if (fetchErr) throw fetchErr;
      if (!booking) return;

      // 2. Fetch customer details
      const { data: userRecord, error: userErr } = await supabaseClient.auth.admin.getUserById(booking.user_id);
      if (userErr) console.warn('[WA-NOTIF] Failed to fetch customer user record', userErr);
      const user = userRecord?.user;
      
      const customerPhone = user?.phone || user?.user_metadata?.whatsapp_number as string || '';
      const customerName = user?.user_metadata?.full_name as string || 'Devotee';

      const dateStr = booking.selected_date 
        ? `${new Date(booking.selected_date).getDate()}/${new Date(booking.selected_date).getMonth() + 1}/${new Date(booking.selected_date).getFullYear()} ${booking.selected_time ?? ''}`
        : 'TBD';

      // A. Alert Customer
      if (customerPhone) {
        const displayName = booking.samagri_required 
            ? `${booking.ritual_name} (with Samagri)` 
            : booking.ritual_name;
        await sendWhatsAppTemplate(customerPhone, 'booking_confirmation', [displayName, dateStr]);
      }

      // B. Alert Pandit (if assigned)
      if (booking.pandit_id) {
        const { data: pandit } = await supabaseClient
          .from('pandit_profiles')
          .select('phone_number')
          .eq('id', booking.pandit_id)
          .maybeSingle();
        
        if (pandit?.phone_number) {
          await sendWhatsAppTemplate(pandit.phone_number, 'new_assignment_alert', [booking.ritual_name, booking.address ?? 'Client Location', dateStr]);
        }
      }

      // C. Alert Vendor (if assigned)
      const { data: samagriOrder } = await supabaseClient
        .from('samagri_orders')
        .select('id, vendor_id, total_amount')
        .eq('booking_id', internalId)
        .maybeSingle();

      if (samagriOrder?.vendor_id) {
        const { data: vendor } = await supabaseClient
          .from('samagri_vendors')
          .select('phone_number')
          .eq('id', samagriOrder.vendor_id)
          .maybeSingle();

        if (vendor?.phone_number) {
          // Fetch item names
          const { data: orderItems } = await supabaseClient
            .from('samagri_order_items')
            .select('samagri_items (name)')
            .eq('order_id', samagriOrder.id);

          const itemsText = orderItems && orderItems.length > 0
            ? orderItems.map((oi: any) => oi.samagri_items?.name).filter(Boolean).join(', ')
            : `Samagri items for ${booking.ritual_name}`;

          let deliveryNote = '';
          if (booking.selected_date) {
            const deliverBy = new Date(booking.selected_date);
            deliverBy.setDate(deliverBy.getDate() - 1);
            const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            deliveryNote = ` | Deliver by: ${deliverBy.getDate()} ${months[deliverBy.getMonth()]} ${deliverBy.getFullYear()}`;
          }
          const addressWithDelivery = `${booking.address ?? 'Client Location'}${deliveryNote}`;
          const vendorPhone = vendor.phone_number;

          const customerMobile = user?.phone || user?.user_metadata?.whatsapp_number as string || '';
          const customerDetails = customerMobile ? `${customerName} | ${customerMobile}` : customerName;

          await sendWhatsAppTemplate(vendorPhone, 'new_samagri_order', [
            booking.ritual_name,
            customerDetails,
            itemsText,
            addressWithDelivery,
            (booking.samagri_charges ?? 0).toString()
          ]);
        }
      }
    } else if (type === 'samagri') {
      // Standalone Samagri Order
      const { data: order, error: fetchErr } = await supabaseClient
        .from('samagri_orders')
        .select('*')
        .eq('id', internalId)
        .maybeSingle();

      if (fetchErr) throw fetchErr;
      if (!order) return;

      const { data: userRecord } = await supabaseClient.auth.admin.getUserById(order.user_id);
      const user = userRecord?.user;

      const customerPhone = user?.phone || user?.user_metadata?.whatsapp_number as string || '';
      const customerName = user?.user_metadata?.full_name as string || 'Client';

      const { data: orderItems } = await supabaseClient
        .from('samagri_order_items')
        .select('samagri_items (name)')
        .eq('order_id', internalId);

      const itemsList = orderItems && orderItems.length > 0
        ? orderItems.map((oi: any) => oi.samagri_items?.name).filter(Boolean)
        : [];
      
      const cleanItemsText = itemsList.join(', ');

      // A. Alert Customer
      if (customerPhone) {
        await sendWhatsAppTemplate(customerPhone, 'standalone_samagri_order_confirmation', [
          customerName,
          cleanItemsText,
          'Express Delivery',
          (order.total_amount ?? 0).toString()
        ]);
      }

      // B. Alert Vendor
      if (order.vendor_id) {
        const { data: vendor } = await supabaseClient
          .from('samagri_vendors')
          .select('phone_number')
          .eq('id', order.vendor_id)
          .maybeSingle();

        if (vendor?.phone_number) {
          const customerMobile = user?.phone || user?.user_metadata?.whatsapp_number as string || '';
          const customerDetails = customerMobile ? `${customerName} | ${customerMobile}` : customerName;

          await sendWhatsAppTemplate(vendor.phone_number, 'standalone_vendor_samagri_order', [
            customerDetails,
            cleanItemsText,
            order.delivery_address ?? 'Client Location',
            'Express Delivery',
            (order.total_amount ?? 0).toString()
          ]);
        }
      }
    }
  } catch (err) {
    console.error('[WA-NOTIF] Error triggering notifications:', err);
  }
}
