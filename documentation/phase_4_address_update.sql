-- Add address and pin_code columns to pandit_profiles
ALTER TABLE IF EXISTS public.pandit_profiles 
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS pin_code TEXT;

-- Update existing records if necessary (optional)
-- UPDATE public.pandit_profiles SET address = '', pin_code = '' WHERE address IS NULL;
