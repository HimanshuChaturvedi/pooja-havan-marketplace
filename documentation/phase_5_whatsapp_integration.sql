-- WhatsApp OTP Integration Tables and Settings

-- 1. App Configuration Table (Kill-Switch)
CREATE TABLE IF NOT EXISTS app_config (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default WhatsApp toggle
INSERT INTO app_config (key, value) 
VALUES ('whatsapp_enabled', 'true'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- 2. Audit Log for WhatsApp Messages
CREATE TABLE IF NOT EXISTS whatsapp_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT NOT NULL,
    message_type TEXT NOT NULL,
    status TEXT,
    response_body JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for logs (Admin only)
ALTER TABLE whatsapp_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can view all logs" ON whatsapp_logs FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

-- Note: You need to configure the Auth SMS Hook in Supabase Dashboard
-- URL: https://[your-project-ref].supabase.co/functions/v1/whatsapp-otp
-- Secrets needed: WHATSAPP_PHONE_NUMBER_ID, WHATSAPP_ACCESS_TOKEN
