-- Clean Slate: Reset all test data for a fresh start

-- 1. Clear payments first (they link to bookings/orders)
DELETE FROM public.payments;

-- 2. Clear samagri order items
DELETE FROM public.samagri_order_items;

-- 3. Clear samagri orders
DELETE FROM public.samagri_orders;

-- 4. Clear ritual bookings
DELETE FROM public.bookings;

-- 5. Notify to reload cache (just in case)
NOTIFY pgrst, 'reload schema';

SELECT 'Clean slate complete! All test bookings, orders, and payments have been cleared.' as status;
