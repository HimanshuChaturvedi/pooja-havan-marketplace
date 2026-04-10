-- Phase 29: Samagri Fees and Reference ID Fix
ALTER TABLE public.samagri_orders ADD COLUMN IF NOT EXISTS delivery_fee DOUBLE PRECISION DEFAULT 50.0;
ALTER TABLE public.samagri_orders ADD COLUMN IF NOT EXISTS reference_id TEXT;

-- Update existing orders to have a default reference ID if missing
UPDATE public.samagri_orders 
SET reference_id = 'PHM-SMG-' || id::text 
WHERE reference_id IS NULL;
