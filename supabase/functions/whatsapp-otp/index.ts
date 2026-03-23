import "https://esm.sh/serve@14.2.1";

// Meta WhatsApp Cloud API Configuration
const FACEBOOK_API_VERSION = 'v21.0';
const WHATSAPP_PHONE_NUMBER_ID = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID');
const WHATSAPP_ACCESS_TOKEN = Deno.env.get('WHATSAPP_ACCESS_TOKEN');

Deno.serve(async (req) => {
  const { phone, otp } = await req.json();

  if (!phone || !otp) {
    return new Response(JSON.stringify({ error: 'Missing phone or otp' }), { status: 400 });
  }

  // Format phone to E.164 if not already (e.g., 919876543210)
  const formattedPhone = phone.replace(/\D/g, '');

  try {
    const response = await fetch(
      `https://graph.facebook.com/${FACEBOOK_API_VERSION}/${WHATSAPP_PHONE_NUMBER_ID}/messages`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${WHATSAPP_ACCESS_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          to: formattedPhone,
          type: 'template',
          template: {
            name: 'otp_verification', // You must create this template in Meta Console
            language: { code: 'en' },
            components: [
              {
                type: 'body',
                parameters: [
                  { type: 'text', text: otp },
                ],
              },
              {
                type: 'button',
                sub_type: 'url',
                index: 0,
                parameters: [
                  { type: 'text', text: otp },
                ],
              },
            ],
          },
        }),
      }
    );

    const result = await response.json();
    return new Response(JSON.stringify(result), { status: response.status });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
