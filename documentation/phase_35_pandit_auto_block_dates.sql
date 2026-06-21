-- ============================================================================
-- SQL DDL to automatically union manually blocked dates and committed bookings
-- Run this in your Supabase Console SQL Editor.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_pandit_blocked_dates(p_id UUID)
RETURNS TABLE(blocked_date TEXT) AS $$
BEGIN
    RETURN QUERY
    -- 1. Fetch manually blocked dates (format as YYYY-MM-DD text)
    SELECT bu.blocked_date::TEXT 
    FROM public.pandit_unavailability bu 
    WHERE bu.pandit_id = p_id
    
    UNION
    
    -- 2. Fetch paid or accepted booking dates (format as YYYY-MM-DD text)
    -- This blocks the date as soon as a devotee pays (PAID) or the pandit accepts (CONFIRMED)
    SELECT (b.selected_date::DATE)::TEXT 
    FROM public.bookings b 
    WHERE b.pandit_id = p_id 
    AND b.status IN ('CONFIRMED', 'PAID')
    AND b.selected_date IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions to public/authenticated users
GRANT EXECUTE ON FUNCTION public.get_pandit_blocked_dates(UUID) TO anon, authenticated;
