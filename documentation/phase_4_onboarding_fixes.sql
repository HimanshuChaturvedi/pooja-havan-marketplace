-- Phase 4: Pandit Onboarding Infrastructure & Schema Fixes

-- 1. Schema Updates: Split Address & Aadhar URLs
ALTER TABLE public.pandit_profiles RENAME COLUMN address TO address_line_1;
ALTER TABLE public.pandit_profiles ADD COLUMN IF NOT EXISTS address_line_2 TEXT;
ALTER TABLE public.pandit_profiles RENAME COLUMN aadhar_image_url TO aadhar_front_url;
ALTER TABLE public.pandit_profiles ADD COLUMN IF NOT EXISTS aadhar_back_url TEXT;

-- 2. Storage Setup: Create Buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('aadhar-copies', 'aadhar-copies', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Storage RLS: Public Read (Already enabled if public = true, but explicit doesn't hurt)
CREATE POLICY "Public Read Access" 
    ON storage.objects FOR SELECT 
    USING (bucket_id IN ('profile-photos', 'aadhar-copies'));

-- 4. Storage RLS: Authenticated Upload (Fixes 403 StorageException)
CREATE POLICY "Authenticated users can upload profile photos" 
    ON storage.objects FOR INSERT 
    WITH CHECK (bucket_id = 'profile-photos' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can upload aadhar copies" 
    ON storage.objects FOR INSERT 
    WITH CHECK (bucket_id = 'aadhar-copies' AND auth.role() = 'authenticated');

-- 5. Storage RLS: Users can update/delete their own files (Optional but good practice)
-- Note: This assumes filenames start with user_id or similar. 
-- For MVP, simple bucket-level upload is enough.
