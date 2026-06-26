import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.8';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabaseClient = createClient(supabaseUrl, supabaseServiceKey);

    const { action, phone, purpose, code } = await req.json();

    if (!phone || !purpose) {
      return new Response(
        JSON.stringify({ error: 'Missing phone or purpose' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const sanitizedPhone = phone.replace(/\D/g, '');
    const formattedPhone = sanitizedPhone.length === 10 ? `91${sanitizedPhone}` : sanitizedPhone;

    const pepper = Deno.env.get('OTP_PEPPER');
    if (!pepper) {
      throw new Error('OTP_PEPPER environment variable is not configured');
    }

    if (action === 'send') {
      // 1. Generate Secure Code (6 digits)
      const randomValues = new Uint32Array(1);
      crypto.getRandomValues(randomValues);
      const rawCode = (100000 + (randomValues[0] % 900000)).toString();

      // 2. Compute HMAC-SHA256 Hash
      const hashedCode = await hmacSha256(rawCode, pepper);

      // 3. Fetch existing verification using safe query (ordered by created_at desc) to handle transition-period duplicates
      const { data: records, error: fetchError } = await supabaseClient
        .from('otp_verifications')
        .select('*')
        .eq('phone', formattedPhone)
        .eq('purpose', purpose)
        .order('created_at', { ascending: false })
        .limit(1);

      if (fetchError) throw fetchError;
      const existing = records && records.length > 0 ? records[0] : null;

      const now = new Date();
      let sendCountHour = 1;
      let sendCountDay = 1;
      let hourWindowStart = now;
      let dayWindowStart = now;

      if (existing) {
        // Check Lockout
        if (existing.locked_until && new Date(existing.locked_until) > now) {
          const lockTimeLeft = Math.ceil((new Date(existing.locked_until).getTime() - now.getTime()) / 1000);
          await writeAuditLog(supabaseClient, formattedPhone, purpose, 'RATE_LIMITED');
          return new Response(
            JSON.stringify({ error: `Too many requests. Try again in ${lockTimeLeft} seconds.` }),
            { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          );
        }

        // Check Cooldown (30 seconds)
        if (existing.last_sent_at) {
          const lastSent = new Date(existing.last_sent_at);
          const timeSinceLast = (now.getTime() - lastSent.getTime()) / 1000;
          if (timeSinceLast < 30) {
            await writeAuditLog(supabaseClient, formattedPhone, purpose, 'RATE_LIMITED');
            return new Response(
              JSON.stringify({ error: `Please wait ${Math.ceil(30 - timeSinceLast)} seconds before requesting another code.` }),
              { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
          }

          // Check Hour Limits (Reset window if >= 1 hour since window start)
          hourWindowStart = existing.hour_window_start ? new Date(existing.hour_window_start) : now;
          const timeSinceHourStart = (now.getTime() - hourWindowStart.getTime()) / (1000 * 60 * 60);
          if (timeSinceHourStart >= 1) {
            hourWindowStart = now;
            sendCountHour = 1;
          } else {
            sendCountHour = (existing.send_count_hour ?? 0) + 1;
            if (sendCountHour > 5) {
              const lockTime = new Date(now.getTime() + 60 * 60 * 1000); // Lock for 1 hour
              await supabaseClient
                .from('otp_verifications')
                .update({ locked_until: lockTime.toISOString(), attempts: 0 })
                .eq('phone', formattedPhone)
                .eq('purpose', purpose);

              await writeAuditLog(supabaseClient, formattedPhone, purpose, 'LOCKED');
              return new Response(
                JSON.stringify({ error: 'Hourly limit exceeded. Phone number locked for 1 hour.' }),
                { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
              );
            }
          }

          // Check Daily Limits (Reset window if >= 24 hours since window start)
          dayWindowStart = existing.day_window_start ? new Date(existing.day_window_start) : now;
          const timeSinceDayStart = (now.getTime() - dayWindowStart.getTime()) / (1000 * 60 * 60 * 24);
          if (timeSinceDayStart >= 1) {
            dayWindowStart = now;
            sendCountDay = 1;
          } else {
            sendCountDay = (existing.send_count_day ?? 0) + 1;
            if (sendCountDay > 20) {
              const lockTime = new Date(now.getTime() + 24 * 60 * 60 * 1000); // Lock for 24 hours
              await supabaseClient
                .from('otp_verifications')
                .update({ locked_until: lockTime.toISOString(), attempts: 0 })
                .eq('phone', formattedPhone)
                .eq('purpose', purpose);

              await writeAuditLog(supabaseClient, formattedPhone, purpose, 'LOCKED');
              return new Response(
                JSON.stringify({ error: 'Daily limit exceeded. Phone number locked for 24 hours.' }),
                { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
              );
            }
          }
        }
      }

      // 4. Save/Upsert OTP Record (Safe Select-then-Update-or-Insert to work with both PK schemas)
      const expiresAt = new Date(now.getTime() + 10 * 60 * 1000); // 10 minutes expiry

      let dbError;
      if (existing) {
        const { error } = await supabaseClient
          .from('otp_verifications')
          .update({
            hashed_code: hashedCode,
            expires_at: expiresAt.toISOString(),
            attempts: 0,
            last_sent_at: now.toISOString(),
            send_count_hour: sendCountHour,
            send_count_day: sendCountDay,
            hour_window_start: hourWindowStart.toISOString(),
            day_window_start: dayWindowStart.toISOString(),
            locked_until: null,
            is_verified: false,
          })
          .eq('phone', formattedPhone)
          .eq('purpose', purpose);
        dbError = error;
      } else {
        const { error } = await supabaseClient
          .from('otp_verifications')
          .insert({
            phone: formattedPhone,
            purpose: purpose,
            hashed_code: hashedCode,
            expires_at: expiresAt.toISOString(),
            attempts: 0,
            last_sent_at: now.toISOString(),
            send_count_hour: sendCountHour,
            send_count_day: sendCountDay,
            hour_window_start: hourWindowStart.toISOString(),
            day_window_start: dayWindowStart.toISOString(),
            locked_until: null,
            is_verified: false,
          });
        dbError = error;
      }

      if (dbError) throw dbError;

      // 5. Send WhatsApp Message (Meta API template)
      const isMockMode = Deno.env.get('USE_MOCK_API') === 'true';
      if (isMockMode) {
        console.log(`🚀 [WHATSAPP MOCK OTP] To: ${formattedPhone}, Code: ${rawCode}`);
        await writeAuditLog(supabaseClient, formattedPhone, purpose, 'SENT');
        return new Response(
          JSON.stringify({ success: true, message: `[MOCK] OTP sent successfully: ${rawCode}` }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }

      const phoneNumberId = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID');
      const accessToken = Deno.env.get('WHATSAPP_ACCESS_TOKEN');
      const apiVersion = 'v21.0';

      const waResponse = await fetch(
        `https://graph.facebook.com/${apiVersion}/${phoneNumberId}/messages`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            messaging_product: 'whatsapp',
            to: formattedPhone,
            type: 'template',
            template: {
              name: 'otp_verification',
              language: { code: 'en' },
              components: [
                {
                  type: 'body',
                  parameters: [
                    { type: 'text', text: rawCode },
                  ],
                },
                {
                  type: 'button',
                  sub_type: 'url',
                  index: 0,
                  parameters: [
                    { type: 'text', text: rawCode },
                  ],
                },
              ],
            },
          }),
        }
      );

      const waResult = await waResponse.json();
      if (waResponse.status === 200 || waResponse.status === 201) {
        await writeAuditLog(supabaseClient, formattedPhone, purpose, 'SENT');
        return new Response(
          JSON.stringify({ success: true, details: waResult }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      } else {
        console.error('WhatsApp Meta API failed:', waResult);
        return new Response(
          JSON.stringify({ error: 'Failed to send WhatsApp message', details: waResult }),
          { status: waResponse.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
    }

    else if (action === 'verify') {
      if (!code) {
        return new Response(
          JSON.stringify({ error: 'Missing verification code' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }

      // Compute peppered input hash on application side
      const inputHash = await hmacSha256(code, pepper);
      const now = new Date();

      // Call database-native atomic verification function using SELECT ... FOR UPDATE
      const { data, error: rpcError } = await supabaseClient.rpc('verify_otp_atomic', {
        p_phone: formattedPhone,
        p_purpose: purpose,
        p_input_hash: inputHash,
        p_now: now.toISOString(),
      });

      if (rpcError) throw rpcError;

      const result = data && data.length > 0 ? data[0] : null;

      if (!result) {
        return new Response(
          JSON.stringify({ error: 'No active OTP verification session found.' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }

      const { success, error_message, attempts_left, locked_until } = result;

      if (success) {
        await writeAuditLog(supabaseClient, formattedPhone, purpose, 'VERIFIED');
        return new Response(
          JSON.stringify({ success: true, message: error_message || 'OTP verified successfully.' }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      } else {
        // Handle Lockout (locked_until is returned)
        if (locked_until) {
          await writeAuditLog(supabaseClient, formattedPhone, purpose, 'FAILED_ATTEMPTS');
          return new Response(
            JSON.stringify({ error: error_message }),
            { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          );
        }

        // Handle Expiry
        if (error_message && error_message.includes('expired')) {
          await writeAuditLog(supabaseClient, formattedPhone, purpose, 'FAILED_EXPIRED');
          return new Response(
            JSON.stringify({ error: error_message }),
            { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          );
        }

        // Handle generic verification failure / wrong code
        await writeAuditLog(supabaseClient, formattedPhone, purpose, 'FAILED_ATTEMPTS');
        return new Response(
          JSON.stringify({
            error: error_message || 'Invalid verification code. Please try again.',
            attemptsLeft: attempts_left !== null ? attempts_left : undefined
          }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
    }

    else {
      return new Response(
        JSON.stringify({ error: 'Invalid action. Must be send or verify.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }
  } catch (error: any) {
    console.error('Edge Function Error:', error);
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
    "raw",
    keyData,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "HMAC",
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

async function writeAuditLog(supabaseClient: any, phone: string, purpose: string, status: string) {
  try {
    const len = phone.length;
    const masked = len > 4
      ? phone.substring(0, 3) + '*'.repeat(len - 7) + phone.substring(len - 4)
      : '***';

    await supabaseClient
      .from('otp_audit_logs')
      .insert({
        phone_masked: masked,
        purpose: purpose,
        status: status,
      });
  } catch (e) {
    console.error('Failed to write audit log:', e);
  }
}
