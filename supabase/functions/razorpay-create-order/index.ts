import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.8';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabaseClient = createClient(supabaseUrl, supabaseServiceKey);

    const { internal_order_id, order_type } = await req.json();

    if (!internal_order_id || !order_type) {
      return new Response(
        JSON.stringify({ error: 'Missing internal_order_id or order_type' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    let totalAmount = 0;
    let currentStatus = '';
    let userId = '';

    // Fetch order/booking details from DB (trusted source of truth)
    if (order_type === 'ritual') {
      const { data: booking, error: fetchErr } = await supabaseClient
        .from('bookings')
        .select('total_amount, status, user_id')
        .eq('id', internal_order_id)
        .maybeSingle();

      if (fetchErr) throw fetchErr;
      if (!booking) {
        return new Response(
          JSON.stringify({ error: 'Ritual booking not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }

      totalAmount = booking.total_amount;
      currentStatus = booking.status;
      userId = booking.user_id;

      if (currentStatus === 'PAID') {
        return new Response(
          JSON.stringify({ error: 'This booking is already paid' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
    } else if (order_type === 'samagri') {
      const { data: order, error: fetchErr } = await supabaseClient
        .from('samagri_orders')
        .select('total_amount, status, user_id')
        .eq('id', internal_order_id)
        .maybeSingle();

      if (fetchErr) throw fetchErr;
      if (!order) {
        return new Response(
          JSON.stringify({ error: 'Samagri order not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }

      totalAmount = order.total_amount;
      currentStatus = order.status;
      userId = order.user_id;

      if (currentStatus === 'paid') {
        return new Response(
          JSON.stringify({ error: 'This Samagri order is already paid' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
    } else {
      return new Response(
        JSON.stringify({ error: 'Invalid order_type' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Call Razorpay API to create an order
    const keyId = Deno.env.get('RAZORPAY_KEY_ID');
    const keySecret = Deno.env.get('RAZORPAY_KEY_SECRET');

    if (!keyId || !keySecret) {
      throw new Error('Razorpay credentials are not configured in Edge Function secrets');
    }

    const amountInPaise = Math.round(totalAmount * 100);

    const rzpResponse = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${btoa(`${keyId}:${keySecret}`)}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: amountInPaise,
        currency: 'INR',
        receipt: internal_order_id,
        notes: {
          internal_id: internal_order_id,
          type: order_type,
          user_id: userId,
        },
      }),
    });

    const rzpResult = await rzpResponse.json();

    if (!rzpResponse.ok) {
      console.error('Razorpay Order API error:', rzpResult);
      return new Response(
        JSON.stringify({ error: 'Razorpay order creation failed', details: rzpResult }),
        { status: rzpResponse.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const razorpayOrderId = rzpResult.id;

    // Save razorpay_order_id back to database
    if (order_type === 'ritual') {
      const { error: updateErr } = await supabaseClient
        .from('bookings')
        .update({ razorpay_order_id: razorpayOrderId })
        .eq('id', internal_order_id);

      if (updateErr) throw updateErr;
    } else {
      const { error: updateErr } = await supabaseClient
        .from('samagri_orders')
        .update({ razorpay_order_id: razorpayOrderId })
        .eq('id', internal_order_id);

      if (updateErr) throw updateErr;
    }

    return new Response(
      JSON.stringify({ razorpay_order_id: razorpayOrderId }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error: any) {
    console.error('Create Order Error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal Server Error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
