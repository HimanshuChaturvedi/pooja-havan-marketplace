-- DEBUG SCRIPT: Run this in Supabase SQL Editor
-- 1. Check your vendor profile status
SELECT id, shop_name, verification_status, is_active, owner_id 
FROM public.samagri_vendors;

-- 2. Check the last 5 samagri orders and see who they are assigned to
SELECT id, reference_id, vendor_id, total_amount, created_at, booking_id
FROM public.samagri_orders
ORDER BY created_at DESC
LIMIT 5;

-- 3. Check if your current user ID matches the vendor's owner_id
SELECT auth.uid();
