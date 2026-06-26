-- Phase 39: Hardened Atomic OTP Verification Function
-- Replaces public.verify_otp_atomic with search_path pinning and permission lockdown.
-- Safe to run against current production schema (composite PK on phone, purpose).
-- Fully idempotent via CREATE OR REPLACE.

-- ============================================================================
-- 1. CREATE OR REPLACE the function with security hardening
-- ============================================================================
CREATE OR REPLACE FUNCTION public.verify_otp_atomic(
  p_phone TEXT,
  p_purpose TEXT,
  p_input_hash TEXT,
  p_now TIMESTAMPTZ,
  p_lockout_duration_min INTEGER DEFAULT 15
)
RETURNS TABLE (
  success BOOLEAN,
  error_message TEXT,
  attempts_left INTEGER,
  locked_until TIMESTAMPTZ
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_rec record;
  v_new_attempts integer;
  v_lock_time timestamptz;
BEGIN
  -- 1. Acquire exclusive row-level lock.
  --    The composite PK (phone, purpose) guarantees at most one row.
  --    FOR UPDATE blocks concurrent callers on the same row until this
  --    transaction commits or rolls back.
  SELECT * INTO v_rec
  FROM public.otp_verifications
  WHERE phone = p_phone AND purpose = p_purpose
  FOR UPDATE;

  -- 2. No record exists — nothing to verify.
  IF v_rec IS NULL THEN
    RETURN QUERY SELECT
      FALSE,
      'No active OTP verification session found.'::TEXT,
      NULL::INTEGER,
      NULL::TIMESTAMPTZ;
    RETURN;
  END IF;

  -- 3. Expired lockout — reset attempts atomically before proceeding.
  IF v_rec.locked_until IS NOT NULL AND v_rec.locked_until < p_now THEN
    UPDATE public.otp_verifications
    SET attempts = 0, locked_until = NULL
    WHERE phone = p_phone AND purpose = p_purpose;
    -- Refresh local state to match the UPDATE.
    v_rec.attempts   := 0;
    v_rec.locked_until := NULL;
  END IF;

  -- 4. Active lockout — reject immediately.
  IF v_rec.locked_until IS NOT NULL AND v_rec.locked_until > p_now THEN
    RETURN QUERY SELECT
      FALSE,
      ('Too many failed verification attempts. Try again in '
        || CEIL(EXTRACT(EPOCH FROM (v_rec.locked_until - p_now)))::TEXT
        || ' seconds.')::TEXT,
      0::INTEGER,
      v_rec.locked_until;
    RETURN;
  END IF;

  -- 5. OTP expired — consume (delete) the stale record.
  IF v_rec.expires_at < p_now THEN
    DELETE FROM public.otp_verifications
    WHERE phone = p_phone AND purpose = p_purpose;
    RETURN QUERY SELECT
      FALSE,
      'OTP code has expired. Please request a new one.'::TEXT,
      NULL::INTEGER,
      NULL::TIMESTAMPTZ;
    RETURN;
  END IF;

  -- 6. Attempts already at limit (should not normally be reached because
  --    step 7 triggers lockout on the 5th failure, but guards against
  --    edge cases such as manual DB edits).
  IF v_rec.attempts >= 5 THEN
    v_lock_time := p_now + (p_lockout_duration_min * INTERVAL '1 minute');
    UPDATE public.otp_verifications
    SET locked_until = v_lock_time
    WHERE phone = p_phone AND purpose = p_purpose;
    RETURN QUERY SELECT
      FALSE,
      'Too many failed verification attempts. Try again in 15 minutes.'::TEXT,
      0::INTEGER,
      v_lock_time;
    RETURN;
  END IF;

  -- 7. Hash comparison.
  IF p_input_hash = v_rec.hashed_code THEN
    -- SUCCESS — atomically consume (delete) the OTP record.
    DELETE FROM public.otp_verifications
    WHERE phone = p_phone AND purpose = p_purpose;
    RETURN QUERY SELECT
      TRUE,
      'OTP verified successfully.'::TEXT,
      NULL::INTEGER,
      NULL::TIMESTAMPTZ;
    RETURN;
  ELSE
    -- FAILURE — increment attempts under the same lock.
    v_new_attempts := v_rec.attempts + 1;

    IF v_new_attempts >= 5 THEN
      v_lock_time := p_now + (p_lockout_duration_min * INTERVAL '1 minute');
      UPDATE public.otp_verifications
      SET attempts = v_new_attempts, locked_until = v_lock_time
      WHERE phone = p_phone AND purpose = p_purpose;
      RETURN QUERY SELECT
        FALSE,
        'Too many failed verification attempts. Try again in 15 minutes.'::TEXT,
        0::INTEGER,
        v_lock_time;
    ELSE
      UPDATE public.otp_verifications
      SET attempts = v_new_attempts
      WHERE phone = p_phone AND purpose = p_purpose;
      RETURN QUERY SELECT
        FALSE,
        'Invalid verification code. Please try again.'::TEXT,
        (5 - v_new_attempts)::INTEGER,
        NULL::TIMESTAMPTZ;
    END IF;
    RETURN;
  END IF;
END;
$$;

-- ============================================================================
-- 2. PERMISSION LOCKDOWN
--    Revoke default PUBLIC execute, grant only to service_role.
--    The Edge Function uses the service_role key so it retains access.
--    Direct PostgREST calls from anon/authenticated are blocked.
-- ============================================================================
REVOKE ALL ON FUNCTION public.verify_otp_atomic(TEXT, TEXT, TEXT, TIMESTAMPTZ, INTEGER) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.verify_otp_atomic(TEXT, TEXT, TEXT, TIMESTAMPTZ, INTEGER) FROM anon;
REVOKE ALL ON FUNCTION public.verify_otp_atomic(TEXT, TEXT, TEXT, TIMESTAMPTZ, INTEGER) FROM authenticated;
GRANT  EXECUTE ON FUNCTION public.verify_otp_atomic(TEXT, TEXT, TEXT, TIMESTAMPTZ, INTEGER) TO service_role;
