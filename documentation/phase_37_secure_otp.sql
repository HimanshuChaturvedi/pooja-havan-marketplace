-- Phase 37: Secure OTP Schema Migration (Zero-Downtime)
-- Upgrades the existing public.otp_verifications table to support multi-purpose hashing and rate limits.
-- Creates an audit logging table and locks down RLS.

-- 1. Create the audit logs table
CREATE TABLE IF NOT EXISTS public.otp_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_masked TEXT NOT NULL,
    purpose TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 2. Alter existing public.otp_verifications table
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS purpose TEXT DEFAULT 'LOGIN';
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS hashed_code TEXT;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS last_sent_at TIMESTAMPTZ DEFAULT now() NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS send_count_hour INTEGER DEFAULT 1 NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS send_count_day INTEGER DEFAULT 1 NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS hour_window_start TIMESTAMPTZ DEFAULT now() NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS day_window_start TIMESTAMPTZ DEFAULT now() NOT NULL;
ALTER TABLE public.otp_verifications ADD COLUMN IF NOT EXISTS locked_until TIMESTAMPTZ;

-- Add check constraint for purpose
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'otp_verifications_purpose_check') THEN
        ALTER TABLE public.otp_verifications ADD CONSTRAINT otp_verifications_purpose_check 
        CHECK (purpose IN ('LOGIN', 'PANDIT_ONBOARDING', 'VENDOR_ONBOARDING', 'PASSWORD_RESET', 'WHATSAPP_VERIFICATION'));
    END IF;
END $$;

-- 3. Delete all transient legacy OTP records safely to prevent primary key conflicts
DELETE FROM public.otp_verifications;

-- 4. Set hashed_code to NOT NULL (Safe now because table is empty)
ALTER TABLE public.otp_verifications ALTER COLUMN hashed_code SET NOT NULL;

-- 5. Alter PK constraint to support composite PK (phone, purpose)
-- Drop old primary key on 'id' column
ALTER TABLE public.otp_verifications DROP CONSTRAINT IF EXISTS otp_verifications_pkey;

-- Drop the old surrogate key 'id' and the raw 'code' columns safely
ALTER TABLE public.otp_verifications DROP COLUMN IF EXISTS id;
ALTER TABLE public.otp_verifications DROP COLUMN IF EXISTS code;

-- Set new composite primary key
ALTER TABLE public.otp_verifications ADD PRIMARY KEY (phone, purpose);

-- 6. Row-Level Security (RLS) Lockdown
ALTER TABLE public.otp_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.otp_audit_logs ENABLE ROW LEVEL SECURITY;

-- Drop existing public policies to block all direct database modifications from clients
DROP POLICY IF EXISTS "Allow public verification check" ON public.otp_verifications;
DROP POLICY IF EXISTS "Allow anonymous insertion" ON public.otp_verifications;

-- Note: By leaving the tables without SELECT/INSERT/UPDATE policies, 
-- we ensure only the Supabase 'service_role' (used by Edge Functions) can read or write to them.
