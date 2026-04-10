-- Phase 25: Enforce Vendor Uniqueness & Cleanup
-- Prevents duplicate registrations for the same user which was causing stale records
-- and "Offline" vendors matching orders because they had multiple entries.

-- 1. Identify and keep only the LATEST record per owner, delete others
DELETE FROM public.samagri_vendors 
WHERE id NOT IN (
    SELECT DISTINCT ON (owner_id) id 
    FROM public.samagri_vendors 
    ORDER BY owner_id, created_at DESC
);

-- 2. Add Unique Constraint to owner_id
ALTER TABLE public.samagri_vendors 
ADD CONSTRAINT samagri_vendors_owner_id_unique UNIQUE (owner_id);

-- 3. Re-enforce RPC check (Just to be sure)
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
    WHERE v.is_active = TRUE 
      AND v.verification_status = 'VERIFIED'
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
