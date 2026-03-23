-- Create app_config table for master toggles and remote configuration
CREATE TABLE IF NOT EXISTS public.app_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key TEXT UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- Allow only admins to update/delete config
CREATE POLICY "Allow public read access to app_config"
ON public.app_config FOR SELECT
USING (true);

-- Initial data for WhatsApp Automation Kill-Switch
INSERT INTO public.app_config (config_key, config_value, description)
VALUES 
('whatsapp_automation_enabled', 'true'::jsonb, 'Master switch for all automated WhatsApp messages (OTP, Bookings, etc).'),
('whatsapp_otp_template_name', '\"auth_otp_template\"'::jsonb, 'The template name registered in Meta for OTPs.'),
('whatsapp_booking_template_name', '\"booking_confirm_template\"'::jsonb, 'The template name registered in Meta for Booking confirmations.');

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_app_config_updated_at
BEFORE UPDATE ON public.app_config
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();
