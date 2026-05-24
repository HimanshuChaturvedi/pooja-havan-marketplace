-- ==========================================
-- TOTAL WIPE SCRIPT (CLEAN SLATE FOR TESTING)
-- ==========================================
-- Ye script chalane se saare Bookings, Orders, 
-- Pandits, aur Vendors delete ho jayenge.
-- Isse aapko naye sire se registration aur
-- WhatsApp OTP flow test karne ka mauka milega.

-- 1. Wipe all transactions
TRUNCATE TABLE public.bookings CASCADE;
TRUNCATE TABLE public.samagri_order_items CASCADE;
TRUNCATE TABLE public.samagri_orders CASCADE;

-- 2. Wipe all profiles
TRUNCATE TABLE public.samagri_vendors CASCADE;
TRUNCATE TABLE public.pandit_profiles CASCADE;

-- 3. Wipe all Auth Users (So you can reuse the same email to test)
-- Note: This deletes all users from the authentication system.
DELETE FROM auth.users;
