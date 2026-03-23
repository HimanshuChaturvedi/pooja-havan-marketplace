-- Phase 3: Pandit Onboarding Schema (Revised v8.1)

-- 1. pandit_profiles table
CREATE TABLE public.pandit_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT UNIQUE NOT NULL,
    email_address TEXT,
    aadhar_number TEXT UNIQUE NOT NULL,
    pan_number TEXT UNIQUE,
    experience_years INTEGER NOT NULL DEFAULT 0,
    bio TEXT,
    profile_image_url TEXT,
    verification_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Note: We assume the use of Row Level Security (RLS)
ALTER TABLE public.pandit_profiles ENABLE ROW LEVEL SECURITY;

-- Pandits can read their own profile
CREATE POLICY "Pandits can view own profile" 
    ON public.pandit_profiles FOR SELECT 
    USING (auth.uid() = id);

-- Public can view verified pandit profiles
CREATE POLICY "Public can view verified pandit profiles" 
    ON public.pandit_profiles FOR SELECT 
    USING (verification_status = 'VERIFIED');

-- Pandits can insert their own profile
CREATE POLICY "Pandits can insert own profile" 
    ON public.pandit_profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- Pandits can update their own profile
CREATE POLICY "Pandits can update own profile" 
    ON public.pandit_profiles FOR UPDATE 
    USING (auth.uid() = id);


-- 2. pandit_service_areas table
CREATE TABLE public.pandit_service_areas (
    pandit_id UUID REFERENCES public.pandit_profiles(id) ON DELETE CASCADE,
    city TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (pandit_id, city)
);

ALTER TABLE public.pandit_service_areas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pandits can view own service areas" 
    ON public.pandit_service_areas FOR SELECT 
    USING (auth.uid() = pandit_id);

CREATE POLICY "Public can view verified pandit service areas" 
    ON public.pandit_service_areas FOR SELECT 
    USING (EXISTS (
        SELECT 1 FROM public.pandit_profiles 
        WHERE id = pandit_service_areas.pandit_id 
        AND verification_status = 'VERIFIED'
    ));

CREATE POLICY "Pandits can manage own service areas" 
    ON public.pandit_service_areas FOR ALL 
    USING (auth.uid() = pandit_id);


-- 3. pandit_specializations table
CREATE TABLE public.pandit_specializations (
    pandit_id UUID REFERENCES public.pandit_profiles(id) ON DELETE CASCADE,
    ritual_slug TEXT NOT NULL,
    PRIMARY KEY (pandit_id, ritual_slug)
);

ALTER TABLE public.pandit_specializations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pandits can view own specializations" 
    ON public.pandit_specializations FOR SELECT 
    USING (auth.uid() = pandit_id);

CREATE POLICY "Public can view verified pandit specializations" 
    ON public.pandit_specializations FOR SELECT 
    USING (EXISTS (
        SELECT 1 FROM public.pandit_profiles 
        WHERE id = pandit_specializations.pandit_id 
        AND verification_status = 'VERIFIED'
    ));

CREATE POLICY "Pandits can manage own specializations" 
    ON public.pandit_specializations FOR ALL 
    USING (auth.uid() = pandit_id);


-- Function to automatically update `updated_at` timestamp
CREATE OR REPLACE FUNCTION update_pandit_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_pandit_profiles_updated_at
BEFORE UPDATE ON public.pandit_profiles
FOR EACH ROW
EXECUTE FUNCTION update_pandit_profiles_updated_at();

-- End of schema
