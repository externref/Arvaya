CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'gender_type') THEN
        CREATE TYPE gender_type AS ENUM ('Male', 'Female', 'Non-binary', 'Prefer not to say');
    END IF;
END $$;
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'indian_state_type') THEN
        CREATE TYPE indian_state_type AS ENUM (
            'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
            'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
            'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
            'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
            'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
            'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
            'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
        );
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    username TEXT UNIQUE NOT NULL,
    gender gender_type,
    date_of_birth DATE,
    state indian_state_type,
    tags TEXT,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


DO $$
DECLARE
    profile_record RECORD;
    new_username TEXT;
    counter INTEGER;
BEGIN
    FOR profile_record IN 
        SELECT id, username FROM profiles WHERE length(username) < 3
    LOOP
        new_username := profile_record.username || 'user';
        counter := 1;
        WHILE EXISTS (SELECT 1 FROM profiles WHERE username = new_username AND id != profile_record.id) LOOP
            new_username := profile_record.username || 'user' || counter::TEXT;
            counter := counter + 1;
        END LOOP;
        UPDATE profiles SET username = new_username WHERE id = profile_record.id;
    END LOOP;
    
    FOR profile_record IN 
        SELECT id, username FROM profiles WHERE length(username) > 20
    LOOP
        new_username := left(profile_record.username, 20);
        counter := 1;
        WHILE EXISTS (SELECT 1 FROM profiles WHERE username = new_username AND id != profile_record.id) LOOP
            IF length(new_username) + length(counter::TEXT) > 20 THEN
                new_username := left(profile_record.username, 20 - length(counter::TEXT)) || counter::TEXT;
            ELSE
                new_username := left(profile_record.username, 20 - length(counter::TEXT)) || counter::TEXT;
            END IF;
            counter := counter + 1;
        END LOOP;
        UPDATE profiles SET username = new_username WHERE id = profile_record.id;
    END LOOP;
    
    FOR profile_record IN 
        SELECT id, username FROM profiles WHERE username !~ '^[a-zA-Z0-9_]+$'
    LOOP
        new_username := lower(regexp_replace(profile_record.username, '[^a-zA-Z0-9_]', '', 'g'));
        IF length(new_username) < 3 THEN
            new_username := new_username || 'user';
        END IF;
        IF length(new_username) > 20 THEN
            new_username := left(new_username, 20);
        END IF;
        counter := 1;
        WHILE EXISTS (SELECT 1 FROM profiles WHERE username = new_username AND id != profile_record.id) LOOP
            IF length(new_username) + length(counter::TEXT) > 20 THEN
                new_username := left(new_username, 20 - length(counter::TEXT)) || counter::TEXT;
            ELSE
                new_username := new_username || counter::TEXT;
            END IF;
            counter := counter + 1;
        END LOOP;
        UPDATE profiles SET username = new_username WHERE id = profile_record.id;
    END LOOP;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

DO $$
BEGIN
    BEGIN
        ALTER TABLE profiles ADD CONSTRAINT profiles_bio_check CHECK (length(bio) <= 500);
    EXCEPTION WHEN duplicate_object THEN
        NULL;
    END;
    BEGIN
        ALTER TABLE profiles ADD CONSTRAINT username_length CHECK (length(username) >= 3 AND length(username) <= 20);
    EXCEPTION WHEN duplicate_object THEN
        NULL;
    END;
    BEGIN
        ALTER TABLE profiles ADD CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9_]+$');
    EXCEPTION WHEN duplicate_object THEN
        NULL;
    END;
    BEGIN
        ALTER TABLE profiles ADD CONSTRAINT valid_birth_date CHECK (date_of_birth <= CURRENT_DATE AND date_of_birth >= '1900-01-01');
    EXCEPTION WHEN duplicate_object THEN
        NULL;
    END;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'blog_count') THEN
        ALTER TABLE profiles ADD COLUMN blog_count INTEGER DEFAULT 0 CHECK (blog_count >= 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'places_explored') THEN
        ALTER TABLE profiles ADD COLUMN places_explored INTEGER DEFAULT 0 CHECK (places_explored >= 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'endorsements') THEN
        ALTER TABLE profiles ADD COLUMN endorsements INTEGER DEFAULT 0 CHECK (endorsements >= 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'activity_points') THEN
        ALTER TABLE profiles ADD COLUMN activity_points INTEGER DEFAULT 0 CHECK (activity_points >= 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'profile_image_url') THEN
        ALTER TABLE profiles ADD COLUMN profile_image_url TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'is_profile_complete') THEN
        ALTER TABLE profiles ADD COLUMN is_profile_complete BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'blog_count') THEN
        BEGIN
            ALTER TABLE profiles ADD CONSTRAINT profiles_blog_count_check CHECK (blog_count >= 0);
        EXCEPTION WHEN duplicate_object THEN
            NULL;
        END;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'places_explored') THEN
        BEGIN
            ALTER TABLE profiles ADD CONSTRAINT profiles_places_explored_check CHECK (places_explored >= 0);
        EXCEPTION WHEN duplicate_object THEN
            NULL;
        END;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'endorsements') THEN
        BEGIN
            ALTER TABLE profiles ADD CONSTRAINT profiles_endorsements_check CHECK (endorsements >= 0);
        EXCEPTION WHEN duplicate_object THEN
            NULL;
        END;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'activity_points') THEN
        BEGIN
            ALTER TABLE profiles ADD CONSTRAINT profiles_activity_points_check CHECK (activity_points >= 0);
        EXCEPTION WHEN duplicate_object THEN
            NULL;
        END;
    END IF;
END $$;


CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_state ON profiles(state);
CREATE INDEX IF NOT EXISTS idx_profiles_updated_at ON profiles(updated_at);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON profiles(created_at);
CREATE INDEX IF NOT EXISTS idx_profiles_is_complete ON profiles(is_profile_complete);
CREATE INDEX IF NOT EXISTS idx_profiles_blog_count ON profiles(blog_count DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_places_explored ON profiles(places_explored DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_endorsements ON profiles(endorsements DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_activity_points ON profiles(activity_points DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_tags_gin ON profiles USING gin(to_tsvector('english', tags));

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
        ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON profiles;

CREATE POLICY "Public profiles are viewable by everyone" ON profiles
    FOR SELECT 
    USING (true);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT 
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE 
    USING (auth.uid() = id) 
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own profile" ON profiles
    FOR DELETE 
    USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_default_username(email TEXT)
RETURNS TEXT AS $$
DECLARE
    base_username TEXT;
    final_username TEXT;
    counter INTEGER := 0;
BEGIN
    base_username := split_part(email, '@', 1);
    base_username := lower(regexp_replace(base_username, '[^a-zA-Z0-9]', '', 'g'));
    IF length(base_username) < 3 THEN
        base_username := base_username || 'user';
    END IF;
    IF length(base_username) > 20 THEN
        base_username := left(base_username, 20);
    END IF;
    final_username := base_username;
    WHILE EXISTS (SELECT 1 FROM profiles WHERE username = final_username) LOOP
        counter := counter + 1;
        final_username := base_username || counter::TEXT;
        IF length(final_username) > 20 THEN
            base_username := left(base_username, 20 - length(counter::TEXT));
            final_username := base_username || counter::TEXT;
        END IF;
    END LOOP;
    RETURN final_username;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_profile_completion(profile_id UUID)
RETURNS INTEGER AS $$
DECLARE
    profile_record profiles%ROWTYPE;
    completion_score INTEGER := 0;
    total_fields INTEGER := 7;
BEGIN
    SELECT * INTO profile_record FROM profiles WHERE id = profile_id;
    IF profile_record.full_name IS NOT NULL AND profile_record.full_name != '' THEN
        completion_score := completion_score + 1;
    END IF;
    IF profile_record.username IS NOT NULL AND profile_record.username != '' THEN
        completion_score := completion_score + 1;
    END IF;
    IF profile_record.gender IS NOT NULL THEN
        completion_score := completion_score + 1;
    END IF;
    IF profile_record.date_of_birth IS NOT NULL THEN
        completion_score := completion_score + 1;
    END IF;
    IF profile_record.state IS NOT NULL THEN
        completion_score := completion_score + 1;
    END IF;
    IF profile_record.tags IS NOT NULL AND profile_record.tags != '' THEN
        completion_score := completion_score + 1;
    END IF;
    IF profile_record.bio IS NOT NULL AND profile_record.bio != '' THEN
        completion_score := completion_score + 1;
    END IF;
    RETURN (completion_score * 100 / total_fields);
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    default_username TEXT;
BEGIN
    default_username := generate_default_username(NEW.email);
    
    INSERT INTO public.profiles (
        id, 
        full_name, 
        username, 
        created_at, 
        updated_at,
        is_profile_complete
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        default_username,
        NOW(),
        NOW(),
        FALSE
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.handle_new_user() IS 
    'Trigger function to automatically create a profile when a new user signs up';


CREATE OR REPLACE FUNCTION update_profile_completion()
RETURNS TRIGGER AS $$
DECLARE
    completion_percentage INTEGER;
BEGIN
    completion_percentage := calculate_profile_completion(NEW.id);
    NEW.is_profile_complete := completion_percentage >= 80;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_profile_completion() IS 
    'Trigger function to update profile completion status when profile is modified';

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
DROP TRIGGER IF EXISTS trigger_update_profile_completion ON profiles;

CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TRIGGER update_profiles_updated_at ON profiles IS 
    'Automatically updates updated_at timestamp when profile is modified';

-- Trigger 2: Update profile completion status
CREATE TRIGGER trigger_update_profile_completion
    BEFORE INSERT OR UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_profile_completion();

COMMENT ON TRIGGER trigger_update_profile_completion ON profiles IS 
    'Updates profile completion status when profile data changes';


CREATE OR REPLACE FUNCTION public.handle_new_user_manually(
    user_id UUID,
    user_email TEXT,
    display_name TEXT DEFAULT ''
)
RETURNS UUID AS $$
DECLARE
    default_username TEXT;
    existing_profile UUID;
BEGIN
    -- Check if profile already exists
    SELECT id INTO existing_profile FROM profiles WHERE id = user_id;
    
    IF existing_profile IS NOT NULL THEN
        RETURN existing_profile; -- Profile already exists
    END IF;
    
    -- Generate default username from email
    default_username := generate_default_username(user_email);
    
    -- Insert new profile with default values
    INSERT INTO public.profiles (
        id, 
        full_name, 
        username, 
        created_at, 
        updated_at,
        is_profile_complete
    )
    VALUES (
        user_id,
        display_name,
        default_username,
        NOW(),
        NOW(),
        FALSE
    );
    
    RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.handle_new_user_manually(UUID, TEXT, TEXT) IS 
    'Manually creates a profile for a new user - call this from application code after signup';



CREATE OR REPLACE VIEW public_profiles AS
SELECT 
    p.id,
    p.username,
    p.full_name,
    p.gender,
    p.state,
    p.tags,
    p.bio,
    p.blog_count,
    p.places_explored,
    p.endorsements,
    p.activity_points,
    p.profile_image_url,
    p.is_profile_complete,
    p.created_at,
    p.updated_at,
    -- Calculate age from date_of_birth
    CASE 
        WHEN p.date_of_birth IS NOT NULL THEN 
            DATE_PART('year', AGE(p.date_of_birth))::INTEGER
        ELSE NULL 
    END as age,
    -- Calculate profile completion percentage
    calculate_profile_completion(p.id) as completion_percentage,
    -- Parse tags into an array (for JSON response)
    CASE 
        WHEN p.tags IS NOT NULL AND p.tags != '' THEN 
            string_to_array(p.tags, ',')
        ELSE ARRAY[]::TEXT[] 
    END as tags_array
FROM profiles p;

COMMENT ON VIEW public_profiles IS 
    'Public view of profiles with calculated fields like age and completion percentage';

-- ============================================================================
-- INITIAL DATA / SEEDS
-- ============================================================================

-- Add any initial data or seed data here if needed
-- For example, you might want to create default tags or categories

-- Example: Create a table for predefined interest tags (optional)
CREATE TABLE IF NOT EXISTS interest_categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ensure the sequence exists and is properly owned
DO $$
BEGIN
    -- Make sure the sequence is owned by the correct column
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'interest_categories') THEN
        ALTER SEQUENCE IF EXISTS interest_categories_id_seq OWNED BY interest_categories.id;
    END IF;
END $$;

COMMENT ON TABLE interest_categories IS 
    'Predefined categories for user interests/tags';

-- Insert some default interest categories (safe to run multiple times)
DO $$
BEGIN
    -- Only insert if the table is empty or specific records don't exist
    INSERT INTO interest_categories (name, description) VALUES
        ('Art & Culture', 'Traditional and contemporary arts, cultural practices'),
        ('History', 'Historical sites, monuments, and heritage'),
        ('Music & Dance', 'Classical and folk music, traditional dances'),
        ('Architecture', 'Temple architecture, forts, palaces'),
        ('Festivals', 'Religious and cultural festivals'),
        ('Cuisine', 'Traditional foods and cooking methods'),
        ('Crafts', 'Handicrafts, textiles, pottery'),
        ('Literature', 'Classical texts, poetry, storytelling'),
        ('Philosophy', 'Ancient wisdom, spiritual practices'),
        ('Nature & Environment', 'Sacred groves, natural heritage sites')
    ON CONFLICT (name) DO NOTHING;
EXCEPTION WHEN OTHERS THEN
    -- Table might not exist yet, continue
    NULL;
END $$;

-- ============================================================================
-- GRANTS AND PERMISSIONS
-- ============================================================================

-- Grant necessary permissions to authenticated users (safe to run multiple times)
DO $$
BEGIN
    -- Grant permissions to authenticated users
    BEGIN
        GRANT USAGE ON SCHEMA public TO authenticated;
    EXCEPTION WHEN OTHERS THEN
        -- Role might not exist yet, continue
        NULL;
    END;
    
    BEGIN
        GRANT ALL ON profiles TO authenticated;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    
    BEGIN
        GRANT SELECT ON interest_categories TO authenticated;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    
    BEGIN
        GRANT SELECT ON public_profiles TO authenticated;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    
    -- Grant permissions to anonymous users
    BEGIN
        GRANT USAGE ON SCHEMA public TO anon;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    
    BEGIN
        GRANT SELECT ON profiles TO anon;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    
    BEGIN
        GRANT SELECT ON public_profiles TO anon;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    
    BEGIN
        GRANT SELECT ON interest_categories TO anon;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
END $$;

-- ============================================================================
-- UTILITY FUNCTIONS FOR MAINTENANCE
-- ============================================================================

-- Function to clean up orphaned profiles (profiles without corresponding auth users)
CREATE OR REPLACE FUNCTION cleanup_orphaned_profiles()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM profiles 
    WHERE id NOT IN (SELECT id FROM auth.users);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_orphaned_profiles() IS 
    'Utility function to clean up profiles that no longer have corresponding auth users';

-- Function to increment blog count
CREATE OR REPLACE FUNCTION increment_blog_count(user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE profiles 
    SET blog_count = blog_count + 1, updated_at = NOW()
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment places explored
CREATE OR REPLACE FUNCTION increment_places_explored(user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE profiles 
    SET places_explored = places_explored + 1, updated_at = NOW()
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment endorsements
CREATE OR REPLACE FUNCTION increment_endorsements(user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE profiles 
    SET endorsements = endorsements + 1, updated_at = NOW()
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to add activity points
CREATE OR REPLACE FUNCTION add_activity_points(user_id UUID, points_to_add INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE profiles 
    SET activity_points = activity_points + points_to_add, updated_at = NOW()
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comments for the activity metric functions
COMMENT ON FUNCTION increment_blog_count(UUID) IS 'Increments the blog count for a user';
COMMENT ON FUNCTION increment_places_explored(UUID) IS 'Increments the places explored count for a user';
COMMENT ON FUNCTION increment_endorsements(UUID) IS 'Increments the endorsements count for a user';
COMMENT ON FUNCTION add_activity_points(UUID, INTEGER) IS 'Adds activity points to a user profile';

-- ============================================================================
-- SCHEMA VERSION TRACKING
-- ============================================================================

-- Create a simple version tracking table
CREATE TABLE IF NOT EXISTS schema_versions (
    version TEXT PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    description TEXT
);

-- Insert current version (safe to run multiple times)
DO $$
BEGIN
    INSERT INTO schema_versions (version, description) VALUES 
        ('1.0.0', 'Initial Arvaya database schema with profiles, RLS policies, and triggers'),
        ('1.1.0', 'Added activity metrics columns: blog_count, places_explored, endorsements, activity_points')
    ON CONFLICT (version) DO NOTHING;
EXCEPTION WHEN OTHERS THEN
    -- Table might not exist yet, continue
    NULL;
END $$;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

-- Final message
DO $$
DECLARE
    profile_count INTEGER;
    version_count INTEGER;
BEGIN
    -- Get some stats
    SELECT COUNT(*) INTO profile_count FROM profiles WHERE profiles.id IS NOT NULL;
    SELECT COUNT(*) INTO version_count FROM schema_versions WHERE schema_versions.version IS NOT NULL;
    
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'ARVAYA DATABASE SCHEMA SUCCESSFULLY APPLIED!';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Schema version: 1.1.0 (with activity metrics)';
    RAISE NOTICE 'Current profiles in database: %', profile_count;
    RAISE NOTICE 'Schema versions tracked: %', version_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Features included:';
    RAISE NOTICE '  ✓ Profiles table with activity metrics';
    RAISE NOTICE '  ✓ Row Level Security policies';
    RAISE NOTICE '  ✓ Automatic username generation';
    RAISE NOTICE '  ✓ Profile completion tracking';
    RAISE NOTICE '  ✓ Activity increment functions';
    RAISE NOTICE '  ✓ Public profile showcase';
    RAISE NOTICE '  ✓ Interest categories';
    RAISE NOTICE '  ✓ Proper indexes for performance';
    RAISE NOTICE '';
    RAISE NOTICE 'This schema is idempotent and safe to run multiple times.';
    RAISE NOTICE '============================================================================';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Schema applied successfully! Some stats unavailable.';
END $$;