-- Phase 24: Fix Vendor Matching RPC
-- Ensures that only ACTIVE and VERIFIED vendors are matched with orders.

CREATE OR REPLACE FUNCTION public.find_nearest_samagri_vendor(
    user_lat DOUBLE PRECISION,
    user_lon DOUBLE PRECISION
)
RETURNS TABLE (
    vendor_id UUID,
    distance_km DOUBLE PRECISION
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.id as vendor_id,
        (
            6371 * acos(
                cos(radians(user_lat)) * cos(radians(v.latitude)) * 
                cos(radians(v.longitude) - radians(user_lon)) + 
                sin(radians(user_lat)) * sin(radians(v.latitude))
            )
        ) AS distance_km
    FROM public.samagri_vendors v
    WHERE v.is_active = TRUE -- CRITICAL: Respect the 'Offline' toggle
      AND v.verification_status = 'VERIFIED' -- Only verified vendors
      AND (
            6371 * acos(
                cos(radians(user_lat)) * cos(radians(v.latitude)) * 
                cos(radians(v.longitude) - radians(user_lon)) + 
                sin(radians(user_lat)) * sin(radians(v.latitude))
            )
        ) <= v.delivery_radius_km
    ORDER BY distance_km ASC
    LIMIT 1;
END;
$$;
