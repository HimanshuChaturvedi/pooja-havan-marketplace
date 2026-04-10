-- SUPER RLS FIX: Run this to see Unassigned Orders in Debug Tab
-- 1. Allow everyone to SELECT unassigned orders (Debug Mode)
DROP POLICY IF EXISTS "Anyone can view unassigned orders" ON public.samagri_orders;
CREATE POLICY "Anyone can view unassigned orders" 
ON public.samagri_orders FOR SELECT 
USING (vendor_id IS NULL);

-- 2. Double check Vendor assignment policy
DROP POLICY IF EXISTS "Vendors can view assigned orders" ON public.samagri_orders;
CREATE POLICY "Vendors can view assigned orders" 
ON public.samagri_orders FOR SELECT 
USING (
    vendor_id IN (
        SELECT id FROM public.samagri_vendors 
        WHERE owner_id = auth.uid()
    )
);

-- 3. Check Order Items Policy (linked table)
DROP POLICY IF EXISTS "View order items" ON public.samagri_order_items;
CREATE POLICY "View order items" 
ON public.samagri_order_items FOR SELECT 
USING (true); -- Relaxed for testing items visibility

-- 4. Audit result
SELECT * FROM public.samagri_orders WHERE vendor_id IS NULL;
