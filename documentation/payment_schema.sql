-- Consolidated SQL Migration: Payments Table (Robust Version)

-- 1. Drop if exists to ensure a clean slate (BE CAREFUL: Only use if no real data exists)
-- DROP TABLE IF EXISTS public.payments CASCADE;

-- 2. Create Table
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    booking_id UUID REFERENCES public.bookings(id),
    samagri_order_id UUID REFERENCES public.samagri_orders(id),
    razorpay_payment_id TEXT NOT NULL,
    razorpay_order_id TEXT,
    razorpay_signature TEXT,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR',
    status TEXT NOT NULL DEFAULT 'captured', 
    method TEXT,
    error_code TEXT,
    error_description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. In case table already existed without the new column, add it manually
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='payments' AND column_name='samagri_order_id') THEN
        ALTER TABLE public.payments ADD COLUMN samagri_order_id UUID REFERENCES public.samagri_orders(id);
    END IF;
END $$;

-- 4. Enable RLS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- 5. Drop old policies to avoid "already exists" errors
DROP POLICY IF EXISTS "Users can view their own payments" ON public.payments;
DROP POLICY IF EXISTS "Users can insert their own payment records" ON public.payments;

-- 6. Create Policies
CREATE POLICY "Users can view their own payments"
    ON public.payments FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payment records"
    ON public.payments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 7. Indexes
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON public.payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_samagri_id ON public.payments(samagri_order_id);
