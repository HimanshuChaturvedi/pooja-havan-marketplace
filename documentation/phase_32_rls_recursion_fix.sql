-- Phase 32: Fix RLS Infinite Recursion
-- This script fixes the "infinite recursion detected" error caused by cross-table RLS policies.

-- 1. Helper Function: Check if a user is the vendor for a booking
-- Using SECURITY DEFINER to bypass RLS recursion
CREATE OR REPLACE FUNCTION public.check_vendor_access_to_booking(b_id UUID, u_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.samagri_orders o
        JOIN public.samagri_vendors v ON v.id = o.vendor_id
        WHERE o.booking_id = b_id
        AND v.owner_id = u_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Helper Function: Check if a user is the pandit for a booking's samagri order
CREATE OR REPLACE FUNCTION public.check_pandit_access_to_samagri(o_id UUID, u_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.samagri_orders o
        JOIN public.bookings b ON b.id = o.booking_id
        WHERE o.id = o_id
        AND b.pandit_id = u_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Update Bookings Policy (Fixes Phase 31)
DROP POLICY IF EXISTS "Vendors can view linked bookings" ON public.bookings;
CREATE POLICY "Vendors can view linked bookings" 
ON public.bookings FOR SELECT 
USING (public.check_vendor_access_to_booking(id, auth.uid()));

-- 4. Update Samagri Orders Policy (Fixes Phase 28 cross-dependency)
DROP POLICY IF EXISTS "Pandits can view linked samagri orders" ON public.samagri_orders;
CREATE POLICY "Pandits can view linked samagri orders" 
ON public.samagri_orders FOR SELECT 
USING (public.check_pandit_access_to_samagri(id, auth.uid()));

-- 5. Cleanup the problematic public debugging policy if it exists
DROP POLICY IF EXISTS "Public can view unassigned linked bookings" ON public.bookings;
