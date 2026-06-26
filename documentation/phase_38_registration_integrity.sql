-- Phase 38: Registration Integrity
-- Idempotently enforce unique phone numbers for both Pandit and Vendor roles

DO $$
BEGIN
    -- 0. Canonicalize existing valid Indian mobile numbers before adding constraints.
    -- This prevents legacy values like 9876543210 and +919876543210 from
    -- being treated as different numbers after the app starts saving +91 format.
    UPDATE public.samagri_vendors
    SET phone_number = CASE
        WHEN regexp_replace(phone_number, '\D', '', 'g') ~ '^[6-9][0-9]{9}$'
            THEN '+91' || regexp_replace(phone_number, '\D', '', 'g')
        WHEN regexp_replace(phone_number, '\D', '', 'g') ~ '^0[6-9][0-9]{9}$'
            THEN '+91' || substring(regexp_replace(phone_number, '\D', '', 'g') from 2)
        WHEN regexp_replace(phone_number, '\D', '', 'g') ~ '^91[6-9][0-9]{9}$'
            THEN '+' || regexp_replace(phone_number, '\D', '', 'g')
        ELSE phone_number
    END
    WHERE phone_number IS NOT NULL;

    UPDATE public.pandit_profiles
    SET phone_number = CASE
        WHEN regexp_replace(phone_number, '\D', '', 'g') ~ '^[6-9][0-9]{9}$'
            THEN '+91' || regexp_replace(phone_number, '\D', '', 'g')
        WHEN regexp_replace(phone_number, '\D', '', 'g') ~ '^0[6-9][0-9]{9}$'
            THEN '+91' || substring(regexp_replace(phone_number, '\D', '', 'g') from 2)
        WHEN regexp_replace(phone_number, '\D', '', 'g') ~ '^91[6-9][0-9]{9}$'
            THEN '+' || regexp_replace(phone_number, '\D', '', 'g')
        ELSE phone_number
    END
    WHERE phone_number IS NOT NULL;

    -- 1. samagri_vendors phone constraint check & creation
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_constraint 
        WHERE conname = 'samagri_vendors_phone_number_unique'
    ) AND NOT EXISTS (
        -- Check if any other unique constraint exists on phone_number in samagri_vendors
        SELECT 1
        FROM pg_constraint con
        JOIN pg_class rel ON rel.oid = con.conrelid
        JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
        JOIN pg_attribute attr ON attr.attrelid = rel.oid AND attr.attnum = ANY(con.conkey)
        WHERE nsp.nspname = 'public'
          AND rel.relname = 'samagri_vendors'
          AND con.contype = 'u'
          AND attr.attname = 'phone_number'
          AND array_length(con.conkey, 1) = 1
    ) THEN
        ALTER TABLE public.samagri_vendors 
        ADD CONSTRAINT samagri_vendors_phone_number_unique UNIQUE (phone_number);
        RAISE NOTICE 'Added UNIQUE constraint samagri_vendors_phone_number_unique to samagri_vendors(phone_number)';
    ELSE
        RAISE NOTICE 'UNIQUE constraint on samagri_vendors(phone_number) already exists';
    END IF;

    -- 2. pandit_profiles phone constraint check & creation
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_constraint 
        WHERE conname = 'pandit_profiles_phone_number_unique'
    ) AND NOT EXISTS (
        -- Check if any other unique constraint exists on phone_number in pandit_profiles
        SELECT 1
        FROM pg_constraint con
        JOIN pg_class rel ON rel.oid = con.conrelid
        JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
        JOIN pg_attribute attr ON attr.attrelid = rel.oid AND attr.attnum = ANY(con.conkey)
        WHERE nsp.nspname = 'public'
          AND rel.relname = 'pandit_profiles'
          AND con.contype = 'u'
          AND attr.attname = 'phone_number'
          AND array_length(con.conkey, 1) = 1
    ) THEN
        ALTER TABLE public.pandit_profiles 
        ADD CONSTRAINT pandit_profiles_phone_number_unique UNIQUE (phone_number);
        RAISE NOTICE 'Added UNIQUE constraint pandit_profiles_phone_number_unique to pandit_profiles(phone_number)';
    ELSE
        RAISE NOTICE 'UNIQUE constraint on pandit_profiles(phone_number) already exists';
    END IF;
END $$;

-- Atomic verification function with row-level locks to prevent replay/concurrency races
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
AS $$
DECLARE
  v_rec record;
  v_new_attempts integer;
  v_lock_time timestamptz;
BEGIN
  -- 1. Acquire Row-Level Lock using SELECT ... FOR UPDATE
  SELECT * INTO v_rec
  FROM public.otp_verifications
  WHERE phone = p_phone AND purpose = p_purpose
  FOR UPDATE;

  -- 2. If no record found
  IF v_rec IS NULL THEN
    RETURN QUERY SELECT FALSE, 'No active OTP verification session found.'::TEXT, NULL::INTEGER, NULL::TIMESTAMPTZ;
    RETURN;
  END IF;

  -- 3. Check if lockout has expired and reset attempts atomically
  IF v_rec.locked_until IS NOT NULL AND v_rec.locked_until < p_now THEN
    v_rec.attempts := 0;
    v_rec.locked_until := NULL;
    UPDATE public.otp_verifications
    SET attempts = 0, locked_until = NULL
    WHERE phone = p_phone AND purpose = p_purpose;
  END IF;

  -- 4. Check if currently locked
  IF v_rec.locked_until IS NOT NULL AND v_rec.locked_until > p_now THEN
    RETURN QUERY SELECT FALSE, 
      ('Too many failed verification attempts. Try again in ' || CEIL(EXTRACT(EPOCH FROM (v_rec.locked_until - p_now)))::TEXT || ' seconds.')::TEXT,
      0::INTEGER,
      v_rec.locked_until;
    RETURN;
  END IF;

  -- 5. Check if expired
  IF v_rec.expires_at < p_now THEN
    -- Consume/delete the expired record
    DELETE FROM public.otp_verifications WHERE phone = p_phone AND purpose = p_purpose;
    RETURN QUERY SELECT FALSE, 'OTP code has expired. Please request a new one.'::TEXT, NULL::INTEGER, NULL::TIMESTAMPTZ;
    RETURN;
  END IF;

  -- 6. Check Attempts (Brute Force Protection)
  IF v_rec.attempts >= 5 THEN
    v_lock_time := p_now + (p_lockout_duration_min * INTERVAL '1 minute');
    UPDATE public.otp_verifications
    SET locked_until = v_lock_time
    WHERE phone = p_phone AND purpose = p_purpose;
    RETURN QUERY SELECT FALSE, 'Too many failed verification attempts. Try again in 15 minutes.'::TEXT, 0::INTEGER, v_lock_time;
    RETURN;
  END IF;

  -- 7. Validate Hash
  IF p_input_hash = v_rec.hashed_code THEN
    -- SUCCESS: Consume the OTP by deleting the record atomically
    DELETE FROM public.otp_verifications WHERE phone = p_phone AND purpose = p_purpose;
    RETURN QUERY SELECT TRUE, 'OTP verified successfully.'::TEXT, NULL::INTEGER, NULL::TIMESTAMPTZ;
    RETURN;
  ELSE
    -- FAILURE: Increment attempts
    v_new_attempts := v_rec.attempts + 1;
    
    IF v_new_attempts >= 5 THEN
      -- Trigger Lockout immediately on the 5th failed attempt
      v_lock_time := p_now + (p_lockout_duration_min * INTERVAL '1 minute');
      UPDATE public.otp_verifications
      SET attempts = v_new_attempts, locked_until = v_lock_time
      WHERE phone = p_phone AND purpose = p_purpose;
      RETURN QUERY SELECT FALSE, 'Too many failed verification attempts. Try again in 15 minutes.'::TEXT, 0::INTEGER, v_lock_time;
    ELSE
      UPDATE public.otp_verifications
      SET attempts = v_new_attempts
      WHERE phone = p_phone AND purpose = p_purpose;
      RETURN QUERY SELECT FALSE, 'Invalid verification code. Please try again.'::TEXT, (5 - v_new_attempts)::INTEGER, NULL::TIMESTAMPTZ;
    END IF;
    RETURN;
  END IF;
END;
$$;
