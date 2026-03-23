-- Phase 3: Pandit Onboarding Schema (Update for v8.1)
-- Run this script to update your existing Phase 3 schema with the new Identity fields.

-- 1. Add new columns to the existing pandit_profiles table
ALTER TABLE public.pandit_profiles 
ADD COLUMN IF NOT EXISTS email_address TEXT,
ADD COLUMN IF NOT EXISTS aadhar_number TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS pan_number TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- 2. Make Aadhar number NOT NULL for future records (Optional if there's existing data)
-- If you already have mock data in there without an Aadhar, this might fail, so we leave it nullable at DB level
-- but our App UI will enforce that it is 12 digits.

-- 3. Create the update trigger if it wasn't created before
CREATE OR REPLACE FUNCTION update_pandit_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_pandit_profiles_updated_at ON public.pandit_profiles;

CREATE TRIGGER update_pandit_profiles_updated_at
BEFORE UPDATE ON public.pandit_profiles
FOR EACH ROW
EXECUTE FUNCTION update_pandit_profiles_updated_at();

-- The rest of the tables (service_areas, specializations) and RLS policies 
-- remain unchanged from your previous successful execution.
