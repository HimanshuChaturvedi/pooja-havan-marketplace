import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const META_API_URL = "https://graph.facebook.com/v21.0";
const META_ACCESS_TOKEN = Deno.env.get("META_ACCESS_TOKEN");
const PHONE_NUMBER_ID = Deno.env.get("PHONE_NUMBER_ID");

/**
 * Edge Function to send WhatsApp OTP/Notifications.
 * This can be used as a Supabase SMS Hook.
 */
serve(async (req) => {
  try {
    const { phone, code, type, metadata } = await req.json();

    // 1. Initialize Supabase Admin Client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 2. Check "Kill Switch" from app_config
    const { data: config } = await supabaseAdmin
      .from('app_config')
      .select('config_value')
      .eq('config_key', 'whatsapp_automation_enabled')
      .single();

    if (config?.config_value === false) {
      console.log("WhatsApp Automation is DISABLED via Kill-Switch.");
      return new Response(JSON.stringify({ status: "skipped", reason: "disabled" }), { status: 200 });
    }

    // 3. Prepare Payload based on type (OTP or Booking)
    let payload;
    if (type === "otp") {
      const { data: templateName } = await supabaseAdmin
        .from('app_config')
        .select('config_value')
        .eq('config_key', 'whatsapp_otp_template_name')
        .single();

      payload = {
        messaging_product: "whatsapp",
        to: phone,
        type: "template",
        template: {
          name: templateName?.config_value || "auth_otp",
          language: { code: "en_US" },
          components: [
            {
              type: "body",
              parameters: [{ type: "text", text: code }]
            },
            {
              type: "button",
              sub_type: "url",
              index: "0",
              parameters: [{ type: "text", text: code }]
            }
          ]
        }
      };
    } else {
       // Handle other notifications like Bookings...
    }

    // 4. Send to Meta
    const response = await fetch(`${META_API_URL}/${PHONE_NUMBER_ID}/messages`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${META_ACCESS_TOKEN}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const result = await response.json();
    return new Response(JSON.stringify(result), { status: 200 });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
})
