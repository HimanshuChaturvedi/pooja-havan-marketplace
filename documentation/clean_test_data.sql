-- Clean Slate: Reset all test data for a fresh start

-- 1. Clear payments first (they link to bookings/orders)
DELETE FROM public.payments;

-- 2. Clear samagri order items
DELETE FROM public.samagri_order_items;

-- 3. Clear samagri orders
DELETE FROM public.samagri_orders;

-- 4. Clear ritual bookings
DELETE FROM public.bookings;

-- 5. Clear Pandit-related data
DELETE FROM public.pandit_specializations;
DELETE FROM public.pandit_service_areas;
DELETE FROM public.pandit_profiles;

-- 5. Notify to reload cache (just in case)
NOTIFY pgrst, 'reload schema';

SELECT 'Clean slate complete! All test bookings, orders, payments, and Pandit profiles have been cleared.' as status;
