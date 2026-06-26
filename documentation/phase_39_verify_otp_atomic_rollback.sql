-- Phase 39 Rollback: Revert Atomic OTP Verification Function
-- Drops the function and restores default permissions.

DROP FUNCTION IF EXISTS public.verify_otp_atomic(TEXT, TEXT, TEXT, TIMESTAMPTZ, INTEGER);
