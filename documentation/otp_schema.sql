-- Table for tracking WhatsApp OTP verifications
CREATE TABLE IF NOT EXISTS otp_verifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    phone TEXT NOT NULL,
    code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    attempts INTEGER DEFAULT 0
);

-- Index for fast lookup by phone
CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_verifications(phone);

-- RLS Policies
ALTER TABLE otp_verifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to prevent "already exists" errors
DROP POLICY IF EXISTS "Allow public verification check" ON otp_verifications;
DROP POLICY IF EXISTS "Allow anonymous insertion" ON otp_verifications;

-- Create Policies
CREATE POLICY "Allow public verification check" 
ON otp_verifications FOR SELECT 
USING (created_at > NOW() - INTERVAL '15 minutes' AND is_verified = FALSE);

-- Allow both anon and authenticated users to request an OTP
CREATE POLICY "Allow anonymous insertion" 
ON otp_verifications FOR INSERT 
WITH CHECK (true);
