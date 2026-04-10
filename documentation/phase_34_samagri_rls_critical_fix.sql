-- CRITICAL FIX: Add Vendor Visibility Policy
-- WITHOUT THIS, VENDORS CANNOT SEE ANY ORDERS ASSIGNED TO THEM
DROP POLICY IF EXISTS "Vendors can view their assigned orders" ON public.samagri_orders;

CREATE POLICY "Vendors can view their assigned orders" ON public.samagri_orders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.samagri_vendors v
            WHERE v.id = public.samagri_orders.vendor_id
            AND v.owner_id = auth.uid()
        )
    );

-- Ensure items are also visible to vendors
DROP POLICY IF EXISTS "Vendors can view order items" ON public.samagri_order_items;
CREATE POLICY "Vendors can view order items" ON public.samagri_order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.samagri_orders o
            JOIN public.samagri_vendors v ON v.id = o.vendor_id
            WHERE o.id = public.samagri_order_items.order_id
            AND v.owner_id = auth.uid()
        )
    );

-- Grant permissions (Just in case)
GRANT SELECT ON public.samagri_orders TO authenticated;
GRANT SELECT ON public.samagri_order_items TO authenticated;
