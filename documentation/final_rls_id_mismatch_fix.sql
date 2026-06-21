-- ============================================================================
-- SQL DDL script to fix RLS Policies for Pandit Auth ID vs Profile ID mismatch
-- Run this script in your Supabase Console SQL Editor.
-- ============================================================================

-- 1. Helper function to resolve the current Pandit Profile ID
CREATE OR REPLACE FUNCTION public.get_current_pandit_profile_id()
RETURNS UUID AS $$
DECLARE
    p_id UUID;
    u_email TEXT;
BEGIN
    -- Try to match by Auth ID directly (normal case)
    SELECT id INTO p_id FROM public.pandit_profiles WHERE id = auth.uid();
    
    -- Fallback: Resolve by email address in JWT (handles ID mismatch after re-auth)
    IF p_id IS NULL THEN
        u_email := auth.jwt() ->> 'email';
        IF u_email IS NOT NULL AND u_email <> '' THEN
            SELECT id INTO p_id FROM public.pandit_profiles WHERE email_address = u_email;
        END IF;
    END IF;
    
    RETURN p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Update Helper function for Samagri order access
CREATE OR REPLACE FUNCTION public.check_pandit_access_to_samagri(o_id UUID, u_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    p_id UUID;
BEGIN
    -- Resolve profile ID for the passed Auth ID
    p_id := public.get_current_pandit_profile_id();
    
    RETURN EXISTS (
        SELECT 1 FROM public.samagri_orders o
        JOIN public.bookings b ON b.id = o.booking_id
        WHERE o.id = o_id
        AND b.pandit_id = COALESCE(p_id, u_id)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 3. BOOKINGS RLS Policies
DROP POLICY IF EXISTS "Pandits can view assigned bookings" ON public.bookings;
CREATE POLICY "Pandits can view assigned bookings" 
ON public.bookings FOR SELECT 
USING (pandit_id = public.get_current_pandit_profile_id());

DROP POLICY IF EXISTS "Pandits can update assigned bookings" ON public.bookings;
CREATE POLICY "Pandits can update assigned bookings" 
ON public.bookings FOR UPDATE 
USING (pandit_id = public.get_current_pandit_profile_id());


-- 4. PANDIT UNAVAILABILITY RLS Policies
DROP POLICY IF EXISTS "Allow pandits to manage their own blocked dates" ON public.pandit_unavailability;
CREATE POLICY "Allow pandits to manage their own blocked dates" 
ON public.pandit_unavailability FOR ALL 
USING (pandit_id = public.get_current_pandit_profile_id())
WITH CHECK (pandit_id = public.get_current_pandit_profile_id());


-- 5. PANDIT PROFILES RLS Policies
DROP POLICY IF EXISTS "Pandits can view own profile" ON public.pandit_profiles;
CREATE POLICY "Pandits can view own profile" 
ON public.pandit_profiles FOR SELECT 
USING (id = public.get_current_pandit_profile_id());

DROP POLICY IF EXISTS "Pandits can update own profile" ON public.pandit_profiles;
CREATE POLICY "Pandits can update own profile" 
ON public.pandit_profiles FOR UPDATE 
USING (id = public.get_current_pandit_profile_id());


-- 6. PANDIT SERVICE AREAS RLS Policies
DROP POLICY IF EXISTS "Pandits can view own service areas" ON public.pandit_service_areas;
CREATE POLICY "Pandits can view own service areas" 
ON public.pandit_service_areas FOR SELECT 
USING (pandit_id = public.get_current_pandit_profile_id());

DROP POLICY IF EXISTS "Pandits can manage own service areas" ON public.pandit_service_areas;
CREATE POLICY "Pandits can manage own service areas" 
ON public.pandit_service_areas FOR ALL 
USING (pandit_id = public.get_current_pandit_profile_id());


-- 7. PANDIT SPECIALIZATIONS RLS Policies
DROP POLICY IF EXISTS "Pandits can view own specializations" ON public.pandit_specializations;
CREATE POLICY "Pandits can view own specializations" 
ON public.pandit_specializations FOR SELECT 
USING (pandit_id = public.get_current_pandit_profile_id());

DROP POLICY IF EXISTS "Pandits can manage own specializations" ON public.pandit_specializations;
CREATE POLICY "Pandits can manage own specializations" 
ON public.pandit_specializations FOR ALL 
USING (pandit_id = public.get_current_pandit_profile_id());
