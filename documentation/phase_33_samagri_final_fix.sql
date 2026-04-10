-- Phase 33: Universal Booking & Samagri Pricing Sync (Final Corrected v1.0)

-- 1. ADD COLUMNS TO BOOKINGS (For split pricing and coordinate persistence)
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS pooja_dakshina DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS samagri_charges DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS delivery_fee DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS platform_fee DOUBLE PRECISION DEFAULT 50.0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- 2. ADD COLUMNS TO SAMAGRI_ORDERS (For consistency)
ALTER TABLE public.samagri_orders ADD COLUMN IF NOT EXISTS platform_fee DOUBLE PRECISION DEFAULT 20.0;
ALTER TABLE public.samagri_orders ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE public.samagri_orders ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- 3. IMPROVE MATCHING RPC (Precision & Resilience)
CREATE OR REPLACE FUNCTION public.find_nearest_samagri_vendor(user_lat DOUBLE PRECISION, user_lon DOUBLE PRECISION)
RETURNS TABLE (
    vendor_id UUID,
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.id,
        (6371 * acos(LEAST(GREATEST(
            cos(radians(user_lat)) * cos(radians(v.latitude)) * 
            cos(radians(v.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * sin(radians(v.latitude))
        , -1), 1))) AS dist
    FROM public.samagri_vendors v
    WHERE v.is_active = TRUE 
      AND v.verification_status = 'VERIFIED'
      AND (6371 * acos(LEAST(GREATEST(
            cos(radians(user_lat)) * cos(radians(v.latitude)) * 
            cos(radians(v.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * sin(radians(v.latitude))
        , -1), 1))) <= v.delivery_radius_km
    ORDER BY dist ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- 4. CLEAN SLATE QUERY (Run this to reset for testing)
/*
DELETE FROM public.samagri_order_items;
DELETE FROM public.samagri_orders;
DELETE FROM public.bookings;
*/
