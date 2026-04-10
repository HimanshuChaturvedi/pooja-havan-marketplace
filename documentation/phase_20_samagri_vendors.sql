-- Phase 20: Samagri Vendor Geofencing System (Revised v1.0)

-- 1. samagri_vendors table
-- Represents local Pooja Samagri shops/vendors
CREATE TABLE public.samagri_vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    shop_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    delivery_radius_km DOUBLE PRECISION NOT NULL DEFAULT 3.0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    verification_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.samagri_vendors ENABLE ROW LEVEL SECURITY;

-- Vendors can view and manage their own shop
CREATE POLICY "Vendors can manage own shop" 
    ON public.samagri_vendors FOR ALL 
    USING (auth.uid() = owner_id);

-- Public can view active/verified vendors for matching
CREATE POLICY "Public can view active vendors" 
    ON public.samagri_vendors FOR SELECT 
    USING (is_active = TRUE AND verification_status = 'VERIFIED');


-- 2. Modify samagri_orders to link to vendors
-- This links an order to the specific fulfilling shop
ALTER TABLE public.samagri_orders ADD COLUMN IF NOT EXISTS vendor_id UUID REFERENCES public.samagri_vendors(id);


-- 3. Function to find nearest active vendor for a given lat/lon
-- Uses spherical distance (Haversine approximation)
CREATE OR REPLACE FUNCTION find_nearest_samagri_vendor(user_lat DOUBLE PRECISION, user_lon DOUBLE PRECISION)
RETURNS TABLE (
    vendor_id UUID,
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.id,
        (6371 * acos(
            cos(radians(user_lat)) * cos(radians(v.latitude)) * 
            cos(radians(v.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * sin(radians(v.latitude))
        )) AS dist
    FROM public.samagri_vendors v
    WHERE v.is_active = TRUE 
      AND v.verification_status = 'VERIFIED'
      -- Only within their specific delivery radius
      AND (6371 * acos(
            cos(radians(user_lat)) * cos(radians(v.latitude)) * 
            cos(radians(v.longitude) - radians(user_lon)) + 
            sin(radians(user_lat)) * sin(radians(v.latitude))
        )) <= v.delivery_radius_km
    ORDER BY dist ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
