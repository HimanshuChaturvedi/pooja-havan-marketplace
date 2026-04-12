-- SQL Patch: Add missing Razorpay columns to existing payments table

ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS razorpay_payment_id TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS razorpay_order_id TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS razorpay_signature TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS method TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS error_code TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS error_description TEXT;

-- Notify Supabase to reload schema cache
NOTIFY pgrst, 'reload schema';
