-- FINAL DIAGNOSTIC: Run this whole block at once

-- 1. How many Vendor records do you have?
SELECT id, owner_id, shop_name, verification_status, is_active 
FROM public.samagri_vendors 
WHERE owner_id IN (SELECT id FROM auth.users WHERE email = 'himanshu2585storage002@gmail.com');

-- 2. What are the last 5 Samagri orders? 
-- (Note down 'vendor_id' and 'booking_id')
SELECT id, reference_id, booking_id, vendor_id, status, created_at
FROM public.samagri_orders
ORDER BY created_at DESC
LIMIT 5;

-- 3. Is there ANY order assigned to YOUR vendor IDs?
-- (This replaces the check with specific IDs from Step 1)
SELECT o.reference_id, o.vendor_id, v.shop_name, o.status
FROM public.samagri_orders o
LEFT JOIN public.samagri_vendors v ON o.vendor_id = v.id
WHERE v.owner_id = (SELECT id FROM auth.users WHERE email = 'himanshu2585storage002@gmail.com');
