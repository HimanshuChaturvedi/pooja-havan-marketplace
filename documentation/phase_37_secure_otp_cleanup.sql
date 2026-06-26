-- Phase 37b: Cleanup OTP Migration (Zero-Downtime)
-- Safe to execute AFTER code deployment has fully completed.

-- 1. Delete all transient legacy OTP records safely
DELETE FROM public.otp_verifications;

-- 2. Set hashed_code to NOT NULL (Safe because table is empty)
ALTER TABLE public.otp_verifications ALTER COLUMN hashed_code SET NOT NULL;

-- 3. Alter PK constraint to support composite PK (phone, purpose)
-- Drop old primary key on 'id' column
ALTER TABLE public.otp_verifications DROP CONSTRAINT IF EXISTS otp_verifications_pkey;

-- Drop the old surrogate key 'id' and the raw 'code' columns safely
ALTER TABLE public.otp_verifications DROP COLUMN IF EXISTS id;
ALTER TABLE public.otp_verifications DROP COLUMN IF EXISTS code;

-- Set new composite primary key, only if it is not already present
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'otp_verifications_pkey'
          AND conrelid = 'public.otp_verifications'::regclass
    ) THEN
        ALTER TABLE public.otp_verifications ADD PRIMARY KEY (phone, purpose);
    END IF;
END $$;

-- 4. Row-Level Security (RLS) Lockdown
ALTER TABLE public.otp_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.otp_audit_logs ENABLE ROW LEVEL SECURITY;

-- Drop existing public policies to block all direct database modifications from clients
DROP POLICY IF EXISTS "Allow public verification check" ON public.otp_verifications;
DROP POLICY IF EXISTS "Allow anonymous insertion" ON public.otp_verifications;
