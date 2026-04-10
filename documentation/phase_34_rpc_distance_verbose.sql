-- Phase 34: Verbose Matching RPC
-- Adds 'distance_km' to the result for easier debugging in UI

CREATE OR REPLACE FUNCTION public.find_nearest_samagri_vendor(user_lat DOUBLE PRECISION, user_lon DOUBLE PRECISION)
RETURNS TABLE (vendor_id UUID, shop_name TEXT, distance_km DOUBLE PRECISION) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.id as vendor_id,
        v.shop_name,
        (6371 * acos(LEAST(GREATEST(cos(radians(user_lat)) * cos(radians(v.latitude)) * cos(radians(v.longitude) - radians(user_lon)) + sin(radians(user_lat)) * sin(radians(v.latitude)), -1), 1))) AS dist
    FROM public.samagri_vendors v
    WHERE v.is_active = TRUE 
      AND v.verification_status = 'VERIFIED'
      AND (6371 * acos(LEAST(GREATEST(cos(radians(user_lat)) * cos(radians(v.latitude)) * cos(radians(v.longitude) - radians(user_lon)) + sin(radians(user_lat)) * sin(radians(v.latitude)), -1), 1))) <= v.delivery_radius_km
    ORDER BY dist ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;
