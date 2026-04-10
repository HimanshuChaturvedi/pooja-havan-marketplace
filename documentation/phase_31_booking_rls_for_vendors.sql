-- Phase 31: Booking RLS for Vendors
-- Allow Vendors to view bookings linked to their assigned Samagri orders
-- This is necessary for the join in the Vendor Dashboard to show Date/Time.

DROP POLICY IF EXISTS "Vendors can view linked bookings" ON public.bookings;
CREATE POLICY "Vendors can view linked bookings" 
ON public.bookings FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.samagri_orders o
        WHERE o.booking_id = public.bookings.id
        AND EXISTS (
            SELECT 1 FROM public.samagri_vendors v
            WHERE v.id = o.vendor_id
            AND v.owner_id = auth.uid()
        )
    )
);

-- Also allow everyone to see linked bookings for Unassigned orders in Debug mode
DROP POLICY IF EXISTS "Public can view unassigned linked bookings" ON public.bookings;
CREATE POLICY "Public can view unassigned linked bookings" 
ON public.bookings FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.samagri_orders o
        WHERE o.booking_id = public.bookings.id
        AND o.vendor_id IS NULL
    )
);
