-- 1. IDENTIFY THE VENDOR
SELECT id, owner_id, shop_name FROM samagri_vendors WHERE owner_id = (SELECT id FROM auth.users WHERE email = 'ankit001@gmail.com');

-- 2. SIMULATE THE APP QUERY (REPLACE THE UUID BELOW WITH THE ID FROM QUERY 1)
-- SELECT * FROM samagri_orders WHERE vendor_id = 'PUT_VENDOR_ID_HERE';

-- 3. CHECK RLS POLICIES FOR ITEMS
SELECT 
    schemaname, tablename, policyname, roles, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename IN ('samagri_orders', 'samagri_order_items');
