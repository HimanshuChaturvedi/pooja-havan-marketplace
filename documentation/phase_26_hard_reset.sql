-- Phase 26: Total Hard Reset & Global Uniqueness (Corrected Column Names)
-- Use this if you want a 100% CLEAN SLATE to start testing from zero.

-- 1. Wipe all Samagri Orders & Items
TRUNCATE TABLE public.samagri_order_items CASCADE;
TRUNCATE TABLE public.samagri_orders CASCADE;

-- 2. Wipe all Vendor Registrations
TRUNCATE TABLE public.samagri_vendors CASCADE;

-- 3. Add UNIQUE constraint to Vendors
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'samagri_vendors_owner_id_unique') THEN
        ALTER TABLE public.samagri_vendors ADD CONSTRAINT samagri_vendors_owner_id_unique UNIQUE (owner_id);
    END IF;
END $$;

-- 4. Pandit Profiles - Already unique per 'id' as per schema, 
-- but ensuring we have a clean status. No changes needed to uniqueness for Pandits 
-- as 'id' is already the Primary Key referencing auth.users.
-- (If you want to wipe Pandits too, uncomment the line below)
-- TRUNCATE TABLE public.pandit_profiles CASCADE;
