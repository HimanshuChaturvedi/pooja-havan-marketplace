-- Check existing booking statuses
SELECT id, status, reference_id FROM bookings LIMIT 5;

-- Check enum labels again if possible (different query)
SELECT enumlabel 
FROM pg_enum 
WHERE enumtypid = 'booking_status'::regtype;
