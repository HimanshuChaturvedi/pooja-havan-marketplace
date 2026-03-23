-- Phase 3.5: Split Name Migration
ALTER TABLE pandit_profiles ADD COLUMN first_name TEXT;
ALTER TABLE pandit_profiles ADD COLUMN last_name TEXT;

-- Attempt to migrate existing data (Full Name -> First & Last)
UPDATE pandit_profiles 
SET first_name = split_part(full_name, ' ', 1), 
    last_name = CASE 
        WHEN strpos(full_name, ' ') > 0 THEN substr(full_name, strpos(full_name, ' ') + 1)
        ELSE ''
    END
WHERE full_name IS NOT NULL;

-- Finalize: Set NOT NULL and remove old column
ALTER TABLE pandit_profiles ALTER COLUMN first_name SET NOT NULL;
ALTER TABLE pandit_profiles DROP COLUMN full_name;
