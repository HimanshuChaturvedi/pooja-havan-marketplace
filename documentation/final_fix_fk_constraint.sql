-- Final Fix for Foreign Key Constraint (Simplified)
-- This script only touches the constraint to avoid RLS policy conflicts.

-- 1. Drop the constraint causing the error
ALTER TABLE public.bookings DROP CONSTRAINT IF EXISTS booking_pandit_id_fkey;

-- 2. Drop the standardized one if it already exists from a previous attempt
ALTER TABLE public.bookings DROP CONSTRAINT IF EXISTS bookings_pandit_id_fkey;

-- 3. Create a clean constraint pointing directly to auth.users(id)
-- This bypasses any issues with the pandit_profiles table view/schema.
ALTER TABLE public.bookings 
ADD CONSTRAINT bookings_pandit_id_fkey 
FOREIGN KEY (pandit_id) 
REFERENCES auth.users(id) 
ON DELETE SET NULL;
