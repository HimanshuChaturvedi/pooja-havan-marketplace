// Supabase Edge Function for WhatsApp Notifications

const FACEBOOK_API_VERSION = 'v21.0';
const WHATSAPP_PHONE_NUMBER_ID = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID');
const WHATSAPP_ACCESS_TOKEN = Deno.env.get('WHATSAPP_ACCESS_TOKEN');

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    } });
  }

  const { phone, template_name, parameters } = await req.json();

  if (!phone || !template_name) {
    return new Response(JSON.stringify({ error: 'Missing phone or template_name' }), { 
      status: 400,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });
  }

  // Format phone to E.164 if not already (e.g., 919876543210)
  const formattedPhone = phone.replace(/\D/g, '');

  try {
    // Map parameters array to Meta's expected format
    const templateParams = parameters ? parameters.map((param: string) => ({
      type: 'text',
      text: param
    })) : [];

    const bodyComponents = templateParams.length > 0 ? [
      {
        type: 'body',
        parameters: templateParams,
      },
      {
        type: 'button',
        sub_type: 'url',
        index: '0',
        parameters: [
          { type: 'text', text: parameters[0] } // The OTP code
        ]
      }
    ] : [];

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
            name: template_name,
            language: { code: 'en' },
            components: bodyComponents,
          },
        }),
      }
    );

    const result = await response.json();
    return new Response(JSON.stringify(result), { 
      status: response.status,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });
  }
});
