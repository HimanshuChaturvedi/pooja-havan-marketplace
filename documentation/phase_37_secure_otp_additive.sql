-- Phase 37a: Additive OTP Migration (Zero-Downtime)
-- Adds columns and logging safely. Safe to execute BEFORE code deployment.

-- 1. Create the audit logs table
CREATE TABLE IF NOT EXISTS public.otp_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_masked TEXT NOT NULL,
    purpose TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 2. Alter existing public.otp_verifications table (Additive changes only)
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS purpose TEXT DEFAULT 'LOGIN';
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS hashed_code TEXT;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS last_sent_at TIMESTAMPTZ DEFAULT now() NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS send_count_hour INTEGER DEFAULT 1 NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS send_count_day INTEGER DEFAULT 1 NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS hour_window_start TIMESTAMPTZ DEFAULT now() NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS day_window_start TIMESTAMPTZ DEFAULT now() NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS locked_until TIMESTAMPTZ;

-- Drop NOT NULL constraint on legacy code column to allow Edge Function writes
ALTER TABLE public.otp_verifications ALTER COLUMN code DROP NOT NULL;

-- Add check constraint for purpose
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'otp_verifications_purpose_check') THEN
        ALTER TABLE public.otp_verifications ADD CONSTRAINT otp_verifications_purpose_check 
        CHECK (purpose IN ('LOGIN', 'PANDIT_ONBOARDING', 'VENDOR_ONBOARDING', 'PASSWORD_RESET', 'WHATSAPP_VERIFICATION'));
    END IF;
END $$;
