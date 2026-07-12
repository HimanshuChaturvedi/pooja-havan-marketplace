-- Redefine find_nearest_samagri_vendor with fallback matching
CREATE OR REPLACE FUNCTION public.find_nearest_samagri_vendor(user_lat DOUBLE PRECISION, user_lon DOUBLE PRECISION)
RETURNS TABLE (
    vendor_id UUID,
    distance_km DOUBLE PRECISION
) AS $$
DECLARE
    matched_id UUID;
    matched_dist DOUBLE PRECISION;
BEGIN
    -- 1. Try matching within delivery radius
    SELECT v.id, (6371 * acos(
        cos(radians(user_lat)) * cos(radians(v.latitude)) * 
        cos(radians(v.longitude) - radians(user_lon)) + 
        sin(radians(user_lat)) * sin(radians(v.latitude))
    )) INTO matched_id, matched_dist
    FROM public.samagri_vendors v
    WHERE v.is_active = TRUE 
      AND v.verification_status = 'VERIFIED'
      AND (6371 * acos(
            cos(radians(user_lat)) * cos(radians(v.latitude)) * 
            cos(radians(v.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * sin(radians(v.latitude))
        )) <= v.delivery_radius_km
    ORDER BY (6371 * acos(
        cos(radians(user_lat)) * cos(radians(v.latitude)) * 
        cos(radians(v.longitude) - radians(user_lon)) + 
        sin(radians(user_lat)) * sin(radians(v.latitude))
    )) ASC
    LIMIT 1;
    
    -- 2. Fallback: if none found within radius, match absolute closest active verified vendor
    IF matched_id IS NULL THEN
        SELECT v.id, (6371 * acos(
            cos(radians(user_lat)) * cos(radians(v.latitude)) * 
            cos(radians(v.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * sin(radians(v.latitude))
        )) INTO matched_id, matched_dist
        FROM public.samagri_vendors v
        WHERE v.is_active = TRUE 
          AND v.verification_status = 'VERIFIED'
        ORDER BY (6371 * acos(
            cos(radians(user_lat)) * cos(radians(v.latitude)) * 
            cos(radians(v.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * sin(radians(v.latitude))
        )) ASC
        LIMIT 1;
    END IF;
    
    IF matched_id IS NOT NULL THEN
        RETURN QUERY SELECT matched_id, matched_dist;
    END IF;
END;
$$ LANGUAGE plpgsql;
