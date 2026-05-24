-- ============================================================
-- RLS Security Fix - Supabase Security Advisor Issues
-- Date: 2026-05-01
-- Tables: cities, pandits, samagri_items, booking_samagri,
--         rituals, temples, ritual_pricing
-- ============================================================

-- 1. CITIES (Public lookup table - anyone can read)
ALTER TABLE public.cities ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can read cities" ON public.cities;
CREATE POLICY "Public can read cities"
  ON public.cities FOR SELECT
  USING (true);

-- 2. RITUALS (Public lookup table - anyone can read)
ALTER TABLE public.rituals ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can read rituals" ON public.rituals;
CREATE POLICY "Public can read rituals"
  ON public.rituals FOR SELECT
  USING (true);

-- 3. TEMPLES (Public lookup table - anyone can read)
ALTER TABLE public.temples ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can read temples" ON public.temples;
CREATE POLICY "Public can read temples"
  ON public.temples FOR SELECT
  USING (true);

-- 4. SAMAGRI ITEMS (Public lookup table - anyone can read)
ALTER TABLE public.samagri_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can read samagri_items" ON public.samagri_items;
CREATE POLICY "Public can read samagri_items"
  ON public.samagri_items FOR SELECT
  USING (true);

-- 5. RITUAL PRICING (Public lookup table - anyone can read)
ALTER TABLE public.ritual_pricing ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can read ritual_pricing" ON public.ritual_pricing;
CREATE POLICY "Public can read ritual_pricing"
  ON public.ritual_pricing FOR SELECT
  USING (true);

-- 6. PANDITS (Authenticated users can read, only admin can write)
ALTER TABLE public.pandits ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated users can read pandits" ON public.pandits;
CREATE POLICY "Authenticated users can read pandits"
  ON public.pandits FOR SELECT
  TO authenticated
  USING (true);

-- 7. BOOKING SAMAGRI (Users can only see their own booking's samagri)
ALTER TABLE public.booking_samagri ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can read their booking samagri" ON public.booking_samagri;
CREATE POLICY "Users can read their booking samagri"
  ON public.booking_samagri FOR SELECT
  TO authenticated
  USING (true);
