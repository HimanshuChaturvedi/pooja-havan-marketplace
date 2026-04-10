-- Phase 22: Add Location Columns and RLS Policies to Samagri Orders
-- Required for standalone orders and vendor dashboard visibility

-- 1. Add missing location columns
ALTER TABLE public.samagri_orders 
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- 2. RLS Policies for Vendor Visibility
-- Enable RLS if not already enabled
ALTER TABLE public.samagri_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.samagri_order_items ENABLE ROW LEVEL SECURITY;

-- Policy: Vendors can view their assigned orders
DROP POLICY IF EXISTS "Vendors can view assigned orders" ON public.samagri_orders;
CREATE POLICY "Vendors can view assigned orders" 
ON public.samagri_orders FOR SELECT 
USING (
  vendor_id IN (
    SELECT id FROM public.samagri_vendors WHERE owner_id = auth.uid()
  )
);

-- Policy: Vendors can update status of their assigned orders
DROP POLICY IF EXISTS "Vendors can update assigned orders" ON public.samagri_orders;
CREATE POLICY "Vendors can update assigned orders" 
ON public.samagri_orders FOR UPDATE 
USING (
  vendor_id IN (
    SELECT id FROM public.samagri_vendors WHERE owner_id = auth.uid()
  )
);

-- Policy: Vendors can view items for their assigned orders
DROP POLICY IF EXISTS "Vendors can view order items" ON public.samagri_order_items;
CREATE POLICY "Vendors can view order items" 
ON public.samagri_order_items FOR SELECT 
USING (
  order_id IN (
    SELECT o.id FROM public.samagri_orders o
    JOIN public.samagri_vendors v ON o.vendor_id = v.id
    WHERE v.owner_id = auth.uid()
  )
);
