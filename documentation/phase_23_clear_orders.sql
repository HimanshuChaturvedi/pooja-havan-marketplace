-- Phase 23: Clean up Samagri Orders for Fresh Testing
-- WARNING: This will delete ALL existing orders and their items.

TRUNCATE TABLE public.samagri_order_items CASCADE;
TRUNCATE TABLE public.samagri_orders CASCADE;

-- Optional: If you want to see if your vendor is verified
-- SELECT id, shop_name, verification_status FROM public.samagri_vendors;
