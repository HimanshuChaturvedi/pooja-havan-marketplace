-- Phase 30: Robust Clean Slate
-- 1. DELETE all test data
DELETE FROM public.samagri_order_items;
DELETE FROM public.samagri_orders;
DELETE FROM public.bookings;

-- 2. FORCE VERIFY ALL VENDORS (For testing ease)
-- This ensures ANY shop you use will be able to receive orders.
UPDATE public.samagri_vendors
SET 
    verification_status = 'VERIFIED',
    is_active = TRUE,
    delivery_radius_km = 50.0; -- Large radius so mismatch in 'Detect Location' doesn't break testing

-- 3. Check results
SELECT id, shop_name, verification_status, is_active FROM public.samagri_vendors;
