-- Migration: Secure Razorpay Payment Integration & Webhook Deduplication
-- File: documentation/phase_41_razorpay_security.sql

-- 1. Create Webhook Event Deduplication Table
CREATE TABLE IF NOT EXISTS public.processed_webhook_events (
    event_id TEXT PRIMARY KEY,
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on processed_webhook_events
ALTER TABLE public.processed_webhook_events ENABLE ROW LEVEL SECURITY;

-- Allow only authenticated admin or service role to read/write webhook events (service role does this naturally)
CREATE POLICY "Admins can view processed webhook events" ON public.processed_webhook_events
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

-- 2. Add razorpay_order_id columns to bookings and samagri_orders
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS razorpay_order_id TEXT;
ALTER TABLE public.samagri_orders ADD COLUMN IF NOT EXISTS razorpay_order_id TEXT;

-- Create indexes for fast lookup during webhooks
CREATE INDEX IF NOT EXISTS idx_bookings_razorpay_order_id ON public.bookings(razorpay_order_id);
CREATE INDEX IF NOT EXISTS idx_samagri_orders_razorpay_order_id ON public.samagri_orders(razorpay_order_id);

-- 3. Add unique constraint to payments table on razorpay_payment_id
-- In PostgreSQL, we can use ALTER TABLE ADD CONSTRAINT. First, remove existing if any to avoid errors.
ALTER TABLE public.payments DROP CONSTRAINT IF EXISTS unique_razorpay_payment_id;
ALTER TABLE public.payments ADD CONSTRAINT unique_razorpay_payment_id UNIQUE (razorpay_payment_id);

-- Ensure payments table has failure metadata columns
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS error_code TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS error_description TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS failed_at TIMESTAMP WITH TIME ZONE;

-- 4. Create Atomic Transaction & Locking Function (confirm_razorpay_payment)
CREATE OR REPLACE FUNCTION public.confirm_razorpay_payment(
  p_payment_id TEXT,
  p_order_id TEXT,
  p_signature TEXT,
  p_internal_id UUID,
  p_type TEXT,
  p_amount NUMERIC
) RETURNS JSONB AS $$
DECLARE
  v_status TEXT;
  v_db_amount NUMERIC;
  v_db_order_id TEXT;
  v_user_id UUID;
  v_already_processed BOOLEAN;
BEGIN
  -- A. Acquire exclusive row lock based on type to prevent concurrent verification races
  IF p_type = 'ritual' THEN
    SELECT status, total_amount, razorpay_order_id, user_id
    INTO v_status, v_db_amount, v_db_order_id, v_user_id
    FROM public.bookings
    WHERE id = p_internal_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
      RETURN jsonb_build_object('success', false, 'error', 'Booking not found');
    END IF;
  ELSIF p_type = 'samagri' THEN
    SELECT status, total_amount, razorpay_order_id, user_id
    INTO v_status, v_db_amount, v_db_order_id, v_user_id
    FROM public.samagri_orders
    WHERE id = p_internal_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
      RETURN jsonb_build_object('success', false, 'error', 'Samagri order not found');
    END IF;
  ELSE
    RETURN jsonb_build_object('success', false, 'error', 'Invalid order type');
  END IF;

  -- B. Validate Razorpay Order ID matches what was registered on order creation
  IF v_db_order_id IS NULL OR v_db_order_id <> p_order_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Razorpay Order ID mismatch');
  END IF;

  -- C. Validate Amount matches (Database amount is source of truth)
  -- DB total_amount is in Rupees, p_amount (from Razorpay) is in paise.
  IF ROUND(v_db_amount * 100) <> p_amount THEN
    RETURN jsonb_build_object('success', false, 'error', 'Payment amount mismatch');
  END IF;

  -- D. Check if payment record already exists in payments table
  SELECT EXISTS(
    SELECT 1 FROM public.payments WHERE razorpay_payment_id = p_payment_id
  ) INTO v_already_processed;

  IF v_already_processed THEN
    -- Check if status is already paid (idempotent duplicate request)
    IF (p_type = 'ritual' AND v_status = 'PAID') OR (p_type = 'samagri' AND v_status = 'paid') THEN
      RETURN jsonb_build_object('success', true, 'message', 'Payment already processed successfully', 'already_paid', true);
    ELSE
      -- Heal state if payment was logged but order status update was interrupted
      IF p_type = 'ritual' THEN
        UPDATE public.bookings SET status = 'PAID' WHERE id = p_internal_id;
      ELSE
        UPDATE public.samagri_orders SET status = 'paid' WHERE id = p_internal_id;
      END IF;
      RETURN jsonb_build_object('success', true, 'message', 'Status healed successfully', 'already_paid', false);
    END IF;
  END IF;

  -- E. Insert payment record (Unique constraint handles safety)
  BEGIN
    INSERT INTO public.payments (
      booking_id,
      samagri_order_id,
      razorpay_payment_id,
      razorpay_order_id,
      razorpay_signature,
      amount,
      status,
      user_id
    ) VALUES (
      CASE WHEN p_type = 'ritual' THEN p_internal_id ELSE NULL END,
      CASE WHEN p_type = 'samagri' THEN p_internal_id ELSE NULL END,
      p_payment_id,
      p_order_id,
      p_signature,
      v_db_amount,
      'captured',
      v_user_id
    );
  EXCEPTION WHEN unique_violation THEN
    -- Fallback for concurrent inserts
    IF p_type = 'ritual' THEN
      UPDATE public.bookings SET status = 'PAID' WHERE id = p_internal_id;
    ELSE
      UPDATE public.samagri_orders SET status = 'paid' WHERE id = p_internal_id;
    END IF;
    RETURN jsonb_build_object('success', true, 'message', 'Payment recorded concurrently', 'already_paid', true);
  END;

  -- F. Update Order Status
  IF p_type = 'ritual' THEN
    UPDATE public.bookings SET status = 'PAID' WHERE id = p_internal_id;
  ELSE
    UPDATE public.samagri_orders SET status = 'paid' WHERE id = p_internal_id;
  END IF;

  RETURN jsonb_build_object('success', true, 'message', 'Payment verified and status updated', 'already_paid', false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
