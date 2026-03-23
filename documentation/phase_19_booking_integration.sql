-- Phase 19: Post-Verification & Booking Integration SQL Updates

-- 1. Add pandit_id to bookings table
-- This allows linking a specific verified Pandit to a customer booking.
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS pandit_id UUID REFERENCES public.pandit_profiles(id);

-- 2. Add lifecycle timestamps for status tracking
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

-- 3. RLS Policies for Pandits
-- Allow Pandits to SELECT bookings where they are assigned
CREATE POLICY "Pandits can view assigned bookings" 
ON public.bookings FOR SELECT 
USING (auth.uid() = pandit_id);

-- Allow Pandits to UPDATE status of their assigned bookings (e.g., mark as Completed)
CREATE POLICY "Pandits can update assigned bookings" 
ON public.bookings FOR UPDATE 
USING (auth.uid() = pandit_id);

-- 4. Storage cleanup (Optional maintenance)
-- Ensure storage buckets for pandit docs are protected but accessible
-- (Handled in previous phases, but good to keep in mind)
