-- Phase 27: Admin RLS Policies
-- Grants hardcoded Admin(s) access to view and approve registrations.

-- 1. Policies for Samagri Vendors
DROP POLICY IF EXISTS "Admins can view all vendors" ON public.samagri_vendors;
CREATE POLICY "Admins can view all vendors" 
ON public.samagri_vendors FOR SELECT 
USING (auth.jwt() ->> 'email' = 'bharatpoojasetu@gmail.com');

DROP POLICY IF EXISTS "Admins can update vendor status" ON public.samagri_vendors;
CREATE POLICY "Admins can update vendor status" 
ON public.samagri_vendors FOR UPDATE 
USING (auth.jwt() ->> 'email' = 'bharatpoojasetu@gmail.com');

-- 2. Policies for Pandit Profiles
DROP POLICY IF EXISTS "Admins can view all pandits" ON public.pandit_profiles;
CREATE POLICY "Admins can view all pandits" 
ON public.pandit_profiles FOR SELECT 
USING (auth.jwt() ->> 'email' = 'bharatpoojasetu@gmail.com');

DROP POLICY IF EXISTS "Admins can update pandit status" ON public.pandit_profiles;
CREATE POLICY "Admins can update pandit status" 
ON public.pandit_profiles FOR UPDATE 
USING (auth.jwt() ->> 'email' = 'bharatpoojasetu@gmail.com');
