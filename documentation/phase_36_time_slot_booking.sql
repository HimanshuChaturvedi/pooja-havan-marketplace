-- ============================================================================
-- Phase 36: Time-Slot Based Booking System
-- Replaces whole-day blocking with granular time-slot conflict detection.
-- Allows Pandits to take multiple bookings per day with buffer between them.
--
-- CONSTANTS:
--   Pooja Duration: 90 minutes
--   Buffer Between Bookings: 60 minutes
--   Total Blocked Window Per Booking: 150 minutes (2.5 hours)
--   Operating Hours: 5:00 AM – 8:00 PM
--
-- Run this in your Supabase SQL Editor.
-- ============================================================================

-- 1. Function: Get all booked time slots for a Pandit on a specific date
-- Returns: start_time, end_time (with buffer), ritual_name, booking_status
CREATE OR REPLACE FUNCTION public.get_pandit_booked_slots(p_id UUID, p_date TEXT)
RETURNS TABLE(
  start_time TEXT,
  end_time TEXT,
  ritual_name TEXT,
  booking_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.selected_time AS start_time,
        -- Calculate end time: selected_time + 150 minutes (90 min pooja + 60 min buffer)
        TO_CHAR(
            (p_date || ' ' || b.selected_time)::TIMESTAMP + INTERVAL '150 minutes',
            'HH12:MI AM'
        ) AS end_time,
        COALESCE(b.ritual_name, 'Pooja') AS ritual_name,
        b.status AS booking_status
    FROM public.bookings b
    WHERE b.pandit_id = p_id
    AND (b.selected_date::DATE)::TEXT = p_date
    AND (b.status != 'CANCELLED' OR b.status IS NULL)
    AND b.selected_time IS NOT NULL
    ORDER BY (p_date || ' ' || b.selected_time)::TIMESTAMP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Function: Check if a requested time conflicts with existing bookings
-- Returns TRUE if there IS a conflict (time not available)
CREATE OR REPLACE FUNCTION public.check_pandit_time_conflict(
    p_id UUID, 
    p_date TEXT, 
    p_time TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    requested_ts TIMESTAMP;
    conflict_count INTEGER;
BEGIN
    -- Parse the requested time into a full timestamp
    requested_ts := (p_date || ' ' || p_time)::TIMESTAMP;
    
    -- Check if the requested time falls within any existing booking window
    -- A booking window = [selected_time, selected_time + 150 minutes)
    -- Also check reverse: does the requested booking's window overlap existing ones
    SELECT COUNT(*) INTO conflict_count
    FROM public.bookings b
    WHERE b.pandit_id = p_id
    AND (b.selected_date::DATE)::TEXT = p_date
    AND (b.status != 'CANCELLED' OR b.status IS NULL)
    AND b.selected_time IS NOT NULL
    AND (
        -- Case 1: Requested time falls within an existing booking's window
        (
            requested_ts >= (p_date || ' ' || b.selected_time)::TIMESTAMP
            AND requested_ts < (p_date || ' ' || b.selected_time)::TIMESTAMP + INTERVAL '150 minutes'
        )
        OR
        -- Case 2: An existing booking falls within the requested booking's window
        (
            (p_date || ' ' || b.selected_time)::TIMESTAMP >= requested_ts
            AND (p_date || ' ' || b.selected_time)::TIMESTAMP < requested_ts + INTERVAL '150 minutes'
        )
    );
    
    RETURN conflict_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Update get_pandit_blocked_dates to return ONLY manually blocked dates
-- (No longer auto-blocking whole days based on bookings)
CREATE OR REPLACE FUNCTION public.get_pandit_blocked_dates(p_id UUID)
RETURNS TABLE(blocked_date TEXT) AS $$
BEGIN
    RETURN QUERY
    -- Only manually blocked dates (Pandit's day off)
    SELECT bu.blocked_date::TEXT 
    FROM public.pandit_unavailability bu 
    WHERE bu.pandit_id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_pandit_booked_slots(UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.check_pandit_time_conflict(UUID, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_pandit_blocked_dates(UUID) TO anon, authenticated;
