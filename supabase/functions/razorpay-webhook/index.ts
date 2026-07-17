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
    const signature = req.headers.get('x-razorpay-signature');
    if (!signature) {
      console.warn('[webhook] Missing x-razorpay-signature header');
      return new Response(JSON.stringify({ error: 'Missing signature header' }), { status: 400 });
    }

    const rawBody = await req.text();
    const webhookSecret = Deno.env.get('RAZORPAY_WEBHOOK_SECRET');
    if (!webhookSecret) {
      throw new Error('RAZORPAY_WEBHOOK_SECRET is not configured in Edge Function secrets');
    }

    // 1. Verify webhook cryptographic signature
    const expectedSignature = await hmacSha256(rawBody, webhookSecret);
    if (!constantTimeEqual(expectedSignature, signature)) {
      console.warn(`[webhook] Webhook signature mismatch. Expected: ${expectedSignature}, Received: ${signature}`);
      return new Response(JSON.stringify({ error: 'Signature mismatch' }), { status: 400 });
    }

    const body = JSON.parse(rawBody);
    const eventId = body.id || body.event_id;

    if (!eventId) {
      return new Response(JSON.stringify({ error: 'Missing event ID' }), { status: 400 });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabaseClient = createClient(supabaseUrl, supabaseServiceKey);

    // 2. Deduplicate Event ID to prevent processing retried webhooks multiple times
    const { error: dedupErr } = await supabaseClient
      .from('processed_webhook_events')
      .insert({ event_id: eventId });

    if (dedupErr) {
      if (dedupErr.code === '23505') {
        // Unique violation means this event was already processed successfully
        console.log(`[webhook] Event ${eventId} already processed (deduplicated). Returning 200.`);
        return new Response(JSON.stringify({ success: true, message: 'Event already processed' }), { status: 200 });
      }
      throw dedupErr;
    }

    console.log(`[webhook] Processing new event: ${body.event} (ID: ${eventId})`);

    const entity = body.payload?.payment?.entity;
    if (!entity) {
      console.warn('[webhook] Missing payment entity in payload');
      return new Response(JSON.stringify({ success: true, message: 'Unhandled payload' }), { status: 200 });
    }

    if (body.event === 'payment.captured') {
      const paymentId = entity.id;
      const orderId = entity.order_id;
      const amountInPaise = entity.amount;
      const signatureText = entity.signature || 'webhook-reconciliation';

      let internalId = entity.notes?.internal_id;
      let type = entity.notes?.type;

      // Webhook fallback: lookup order in database by razorpay_order_id if notes are missing
      if (!internalId && orderId) {
        console.log(`[webhook] Notes missing, attempting DB lookup for orderId=${orderId}`);
        const { data: booking } = await supabaseClient
          .from('bookings')
          .select('id')
          .eq('razorpay_order_id', orderId)
          .maybeSingle();

        if (booking) {
          internalId = booking.id;
          type = 'ritual';
        } else {
          const { data: order } = await supabaseClient
            .from('samagri_orders')
            .select('id')
            .eq('razorpay_order_id', orderId)
            .maybeSingle();

          if (order) {
            internalId = order.id;
            type = 'samagri';
          }
        }
      }

      if (!internalId || !type) {
        console.error(`[webhook] Could not resolve internal order ID for Razorpay order: ${orderId}`);
        return new Response(JSON.stringify({ error: 'Could not resolve internal order' }), { status: 400 });
      }

      // Call database atomic RPC function (locking, validation, status updates)
      const { data: rpcResult, error: rpcErr } = await supabaseClient.rpc('confirm_razorpay_payment', {
        p_payment_id: paymentId,
        p_order_id: orderId,
        p_signature: signatureText,
        p_internal_id: internalId,
        p_type: type,
        p_amount: amountInPaise
      });

      if (rpcErr) throw rpcErr;

      if (!rpcResult.success) {
        console.warn(`[webhook] Payment update rejected by DB:`, rpcResult.error);
        return new Response(JSON.stringify({ error: rpcResult.error }), { status: 400 });
      }

      // Trigger WhatsApp Notifications ONLY if database transaction committed successfully and it was NOT already paid
      if (rpcResult.already_paid === false) {
        // Trigger notifications asynchronously (errors in sending must NOT invalidate/rollback successful payments)
        edgeTriggerNotifications(supabaseClient, internalId, type).catch(err => {
          console.error('[webhook] Asynchronous WhatsApp notification failed:', err);
        });
      }

    } else if (body.event === 'payment.failed') {
      const paymentId = entity.id;
      const orderId = entity.order_id;
      const amountInRupees = entity.amount ? entity.amount / 100 : 0;
      const errorCode = entity.error_code || 'UNKNOWN_ERROR';
      const errorDesc = entity.error_description || 'Payment failed during checkout';

      let internalId = entity.notes?.internal_id;
      let type = entity.notes?.type;
      let userId = entity.notes?.user_id;

      // Fallback lookup for user_id/internal_id
      if (!internalId && orderId) {
        const { data: booking } = await supabaseClient
          .from('bookings')
          .select('id, user_id')
          .eq('razorpay_order_id', orderId)
          .maybeSingle();

        if (booking) {
          internalId = booking.id;
          type = 'ritual';
          userId = booking.user_id;
        } else {
          const { data: order } = await supabaseClient
            .from('samagri_orders')
            .select('id, user_id')
            .eq('razorpay_order_id', orderId)
            .maybeSingle();

          if (order) {
            internalId = order.id;
            type = 'samagri';
            userId = order.user_id;
          }
        }
      }

      if (userId) {
        // Record the failed payment in the payments table
        console.log(`[webhook] Logging failed payment ${paymentId} for user ${userId}`);
        const { error: insertErr } = await supabaseClient
          .from('payments')
          .insert({
            booking_id: type === 'ritual' ? internalId : null,
            samagri_order_id: type === 'samagri' ? internalId : null,
            razorpay_payment_id: paymentId,
            razorpay_order_id: orderId,
            amount: amountInRupees,
            status: 'failed',
            error_code: errorCode,
            error_description: errorDesc,
            failed_at: new Date().toISOString(),
            user_id: userId
          });

        if (insertErr && insertErr.code !== '23505') {
          console.error('[webhook] Failed to log failure in payments table:', insertErr);
        }
      }
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });

  } catch (error: any) {
    console.error('Webhook Error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal Server Error' }),
      { status: 500 }
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

async function edgeTriggerNotifications(supabaseClient: any, internalId: string, type: string) {
  try {
    console.log(`[WA-NOTIF] Orchestrating notifications for internalId=${internalId} type=${type}`);
    
    if (type === 'ritual') {
      const { data: booking, error: fetchErr } = await supabaseClient
        .from('bookings')
        .select('*')
        .eq('id', internalId)
        .maybeSingle();

      if (fetchErr) throw fetchErr;
      if (!booking) return;

      const { data: userRecord, error: userErr } = await supabaseClient.auth.admin.getUserById(booking.user_id);
      if (userErr) console.warn('[WA-NOTIF] Failed to fetch customer user record', userErr);
      const user = userRecord?.user;
      
      const customerPhone = user?.phone || user?.userMetadata?.whatsapp_number as string || '';
      const customerName = user?.userMetadata?.full_name as string || 'Devotee';

      const dateStr = booking.selected_date 
        ? `${new Date(booking.selected_date).getDate()}/${new Date(booking.selected_date).getMonth() + 1}/${new Date(booking.selected_date).getFullYear()} ${booking.selected_time ?? ''}`
        : 'TBD';

      if (customerPhone) {
        const displayName = booking.samagri_required 
            ? `${booking.ritual_name} (with Samagri)` 
            : booking.ritual_name;
        await sendWhatsAppTemplate(customerPhone, 'booking_confirm_v2', [displayName, dateStr]);
      }

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

          const customerMobile = user?.phone || user?.userMetadata?.whatsapp_number as string || '';
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
      const { data: order, error: fetchErr } = await supabaseClient
        .from('samagri_orders')
        .select('*')
        .eq('id', internalId)
        .maybeSingle();

      if (fetchErr) throw fetchErr;
      if (!order) return;

      const { data: userRecord } = await supabaseClient.auth.admin.getUserById(order.user_id);
      const user = userRecord?.user;

      const customerPhone = user?.phone || user?.userMetadata?.whatsapp_number as string || '';
      const customerName = user?.userMetadata?.full_name as string || 'Client';

      const { data: orderItems } = await supabaseClient
        .from('samagri_order_items')
        .select('samagri_items (name)')
        .eq('order_id', internalId);

      const itemsList = orderItems && orderItems.length > 0
        ? orderItems.map((oi: any) => oi.samagri_items?.name).filter(Boolean)
        : [];
      
      const cleanItemsText = itemsList.join(', ');

      if (customerPhone) {
        await sendWhatsAppTemplate(customerPhone, 'standalone_samagri_order_confirmation', [
          customerName,
          cleanItemsText,
          'Express Delivery',
          (order.total_amount ?? 0).toString()
        ]);
      }

      if (order.vendor_id) {
        const { data: vendor } = await supabaseClient
          .from('samagri_vendors')
          .select('phone_number')
          .eq('id', order.vendor_id)
          .maybeSingle();

        if (vendor?.phone_number) {
          const customerMobile = user?.phone || user?.userMetadata?.whatsapp_number as string || '';
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
