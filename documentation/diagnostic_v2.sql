-- DIAGNOSTIC V2: Run this in SQL Editor to see why Vendor Matching is failing

-- 1. Check your Vendor status and coordinates
SELECT id, shop_name, verification_status, is_active, latitude, longitude, delivery_radius_km
FROM public.samagri_vendors;

-- 2. Check the MOST RECENT Order's coordinates and vendor_id
SELECT id, reference_id, vendor_id, latitude, longitude, status, created_at
FROM public.samagri_orders
ORDER BY created_at DESC
LIMIT 1;

-- 3. TEST THE RPC MANUALLY (Replace with the coordinates of the last order)
-- If this returns NO ROWS, then the Vendor is either too far, not active, or not verified.
-- SELECT * FROM find_nearest_samagri_vendor(LAST_ORDER_LAT, LAST_ORDER_LON);

-- 4. Check distance to your shop manually
-- Replace LAT/LON with the coordinates from step 2 and 1
/*
SELECT shop_name,
  (6371 * acos(LEAST(GREATEST(cos(radians(USER_LAT)) * cos(radians(latitude)) * cos(radians(longitude) - radians(USER_LON)) + sin(radians(USER_LAT)) * sin(radians(latitude)), -1), 1))) AS distance_away
FROM public.samagri_vendors;
*/
