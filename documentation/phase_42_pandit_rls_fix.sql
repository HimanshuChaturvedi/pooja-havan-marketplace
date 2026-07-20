-- Phase 42: Pandit Reject & Reassign Booking (RLS-safe)
-- =========================================================
-- PROBLEM:
--   Pandit calling supabase.from('bookings').update() directly from Flutter
--   fails with RLS error 42501 because the pandit is NOT the booking owner
--   (user_id). The existing UPDATE policy only allows the booking owner
--   (customer) to update their own row.
--
-- SOLUTION:
--   SECURITY DEFINER RPC that runs as the DB owner, bypassing RLS, but
--   internally validates that the calling user is the assigned pandit
--   for this booking before making any changes.
--
-- SECURITY:
--   - Only the authenticated pandit assigned to the booking can call this.
--   - auth.uid() is checked against bookings.pandit_id inside the function.
--   - No RLS is disabled.
--   - No service_role key is used from Flutter.
-- =========================================================

CREATE OR REPLACE FUNCTION public.pandit_reject_and_reassign_booking(
  p_booking_id UUID,
  p_next_pandit_id UUID DEFAULT NULL   -- NULL = no candidate found, just release
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_uid UUID := auth.uid();
  v_current_pandit_id UUID;
  v_current_status TEXT;
BEGIN
  -- 1. Fetch the booking's current pandit and status
  SELECT pandit_id, status
    INTO v_current_pandit_id, v_current_status
  FROM public.bookings
  WHERE id = p_booking_id;

  -- 2. Guard: booking must exist
  IF v_current_pandit_id IS NULL AND v_current_status IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Booking not found');
  END IF;

  -- 3. Guard: caller must be the assigned pandit.
  --    pandit_profiles.id IS the auth user id (PK = auth.users.id).
  --    So we simply check that the booking's pandit_id equals auth.uid().
  IF v_current_pandit_id IS DISTINCT FROM v_caller_uid THEN
    RETURN jsonb_build_object('success', false, 'error', 'Forbidden: You are not the assigned pandit for this booking');
  END IF;

  -- 4. Perform the reassignment or release
  IF p_next_pandit_id IS NOT NULL THEN
    -- Reassign to next pandit
    UPDATE public.bookings
    SET
      pandit_id = p_next_pandit_id,
      status    = 'PAID'   -- Reset so new pandit can accept
    WHERE id = p_booking_id;

    RETURN jsonb_build_object('success', true, 'action', 'reassigned', 'next_pandit_id', p_next_pandit_id);
  ELSE
    -- No candidate: release pandit, reset to PAID for admin dispatch
    UPDATE public.bookings
    SET
      pandit_id = NULL,
      status    = 'PAID'
    WHERE id = p_booking_id;

    RETURN jsonb_build_object('success', true, 'action', 'released');
  END IF;
END;
$$;

-- Grant execute to authenticated users only (anon cannot call this)
REVOKE EXECUTE ON FUNCTION public.pandit_reject_and_reassign_booking(UUID, UUID) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.pandit_reject_and_reassign_booking(UUID, UUID) TO authenticated;
