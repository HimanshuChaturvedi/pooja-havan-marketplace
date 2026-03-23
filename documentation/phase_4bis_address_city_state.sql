-- Add city and state columns to pandit_profiles
ALTER TABLE pandit_profiles 
ADD COLUMN IF NOT EXISTS city TEXT,
ADD COLUMN IF NOT EXISTS state TEXT;

-- Update RLS policies if necessary (already handled by existing policies)
