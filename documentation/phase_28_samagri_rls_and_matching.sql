-- Phase 28: Samagri RLS and Assignment Fixes
-- 1. Allow Pandits to see Samagri orders linked to THEIR bookings (Fixes 2450 vs 2100 issue)
-- 2. Allow Vendors to see orders assigned to them

-- Enable RLS on samagri_orders if not already
ALTER TABLE public.samagri_orders ENABLE ROW LEVEL SECURITY;

-- Policy for Customers (already usually exists, but ensuring)
DROP POLICY IF EXISTS "Users can view own samagri orders" ON public.samagri_orders;
CREATE POLICY "Users can view own samagri orders" 
ON public.samagri_orders FOR SELECT 
USING (auth.uid() = user_id);

-- Policy for Vendors (Fixes "Vendor sees nothing" if RLS was blocking)
DROP POLICY IF EXISTS "Vendors can view assigned orders" ON public.samagri_orders;
CREATE POLICY "Vendors can view assigned orders" 
ON public.samagri_orders FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.samagri_vendors v 
        WHERE v.id = public.samagri_orders.vendor_id 
        AND v.owner_id = auth.uid()
    )
);

-- Policy for Pandits (Fixes Amount Calculation by allowing repository to fetch samagriTotal)
DROP POLICY IF EXISTS "Pandits can view linked samagri orders" ON public.samagri_orders;
CREATE POLICY "Pandits can view linked samagri orders" 
ON public.samagri_orders FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.bookings b 
        WHERE b.id = public.samagri_orders.booking_id 
        AND b.pandit_id = auth.uid()
    )
);

-- 3. Policy for samagri_order_items (Linked table)
ALTER TABLE public.samagri_order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own order items" ON public.samagri_order_items;
CREATE POLICY "Users can view own order items" 
ON public.samagri_order_items FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.samagri_orders o
        WHERE o.id = public.samagri_order_items.order_id
        AND (
            o.user_id = auth.uid() OR
            EXISTS (SELECT 1 FROM public.samagri_vendors v WHERE v.id = o.vendor_id AND v.owner_id = auth.uid()) OR
            EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = o.booking_id AND b.pandit_id = auth.uid())
        )
    )
);
