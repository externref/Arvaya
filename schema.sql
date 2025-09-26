-- Arvaya Database Schema - Basic User Management
-- Safe to run multiple times

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create enums for profile data (safe to run multiple times)
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

-- Profiles table with user information and activity metrics
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    username TEXT UNIQUE NOT NULL,
    gender gender_type,
    date_of_birth DATE,
    state indian_state_type,
    tags TEXT,
    bio TEXT,
    profile_image_url TEXT,
    blog_count INTEGER DEFAULT 0 CHECK (blog_count >= 0),
    places_explored INTEGER DEFAULT 0 CHECK (places_explored >= 0),
    endorsements INTEGER DEFAULT 0 CHECK (endorsements >= 0),
    activity_points INTEGER DEFAULT 0 CHECK (activity_points >= 0),
    is_profile_complete BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add new columns if they don't exist (for existing databases) - DO THIS FIRST
DO $$
BEGIN
    -- Add blog_count column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'blog_count') THEN
        ALTER TABLE profiles ADD COLUMN blog_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add places_explored column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'places_explored') THEN
        ALTER TABLE profiles ADD COLUMN places_explored INTEGER DEFAULT 0;
    END IF;
    
    -- Add endorsements column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'endorsements') THEN
        ALTER TABLE profiles ADD COLUMN endorsements INTEGER DEFAULT 0;
    END IF;
    
    -- Add activity_points column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'activity_points') THEN
        ALTER TABLE profiles ADD COLUMN activity_points INTEGER DEFAULT 0;
    END IF;
    
    -- Add is_profile_complete column if it doesn't exist  
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'is_profile_complete') THEN
        ALTER TABLE profiles ADD COLUMN is_profile_complete BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- Add constraints AFTER columns exist (safe to run multiple times)
DO $$
BEGIN
    -- Bio length constraint
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_bio_check') THEN
        ALTER TABLE profiles ADD CONSTRAINT profiles_bio_check CHECK (length(bio) <= 500);
    END IF;
    
    -- Username length constraint
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'username_length') THEN
        ALTER TABLE profiles ADD CONSTRAINT username_length CHECK (length(username) >= 3 AND length(username) <= 20);
    END IF;
    
    -- Username format constraint
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'username_format') THEN
        ALTER TABLE profiles ADD CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9_]+$');
    END IF;
    
    -- Valid birth date constraint
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'valid_birth_date') THEN
        ALTER TABLE profiles ADD CONSTRAINT valid_birth_date CHECK (date_of_birth <= CURRENT_DATE AND date_of_birth >= '1900-01-01');
    END IF;
    
    -- Activity points constraint
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_activity_points_check') THEN
        ALTER TABLE profiles ADD CONSTRAINT profiles_activity_points_check CHECK (activity_points >= 0);
    END IF;
    
    -- Blog count constraint
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_blog_count_check') THEN
        ALTER TABLE profiles ADD CONSTRAINT profiles_blog_count_check CHECK (blog_count >= 0);
    END IF;
    
    -- Places explored constraint
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_places_explored_check') THEN
        ALTER TABLE profiles ADD CONSTRAINT profiles_places_explored_check CHECK (places_explored >= 0);
    END IF;
    
    -- Endorsements constraint
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_endorsements_check') THEN
        ALTER TABLE profiles ADD CONSTRAINT profiles_endorsements_check CHECK (endorsements >= 0);
    END IF;
END $$;

-- Create indexes (safe to run multiple times)
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies (drop and recreate to ensure consistency)
DROP POLICY IF EXISTS "Users can view all profiles" ON profiles;
CREATE POLICY "Users can view all profiles" ON profiles
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can delete own profile" ON profiles;
CREATE POLICY "Users can delete own profile" ON profiles
    FOR DELETE USING (auth.uid() = id);

-- Function to generate unique username from email
CREATE OR REPLACE FUNCTION generate_unique_username(user_email TEXT, display_name TEXT DEFAULT '')
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    base_username TEXT;
    final_username TEXT;
    counter INTEGER := 0;
    max_attempts INTEGER := 100;
BEGIN
    -- Try to use display name first if provided
    IF display_name IS NOT NULL AND length(trim(display_name)) > 0 THEN
        base_username := LOWER(trim(display_name));
        -- Clean username: keep only alphanumeric and underscore
        base_username := regexp_replace(base_username, '[^a-zA-Z0-9_]', '', 'g');
        base_username := regexp_replace(base_username, '\s+', '_', 'g');
    END IF;
    
    -- Fallback to email if display name is empty or too short
    IF base_username IS NULL OR length(base_username) < 3 THEN
        base_username := LOWER(split_part(user_email, '@', 1));
        -- Clean username: keep only alphanumeric and underscore
        base_username := regexp_replace(base_username, '[^a-zA-Z0-9_]', '', 'g');
    END IF;
    
    -- Ensure minimum length
    IF length(base_username) < 3 THEN
        base_username := base_username || '123';
    END IF;
    
    -- Ensure maximum length
    IF length(base_username) > 15 THEN
        base_username := left(base_username, 15);
    END IF;
    
    final_username := base_username;
    
    -- Find unique username
    WHILE counter < max_attempts LOOP
        -- Check if username exists
        IF NOT EXISTS (SELECT 1 FROM profiles WHERE username = final_username) THEN
            RETURN final_username;
        END IF;
        
        counter := counter + 1;
        final_username := base_username || counter::TEXT;
        
        -- Ensure we don't exceed length limit with counter
        IF length(final_username) > 20 THEN
            base_username := left(base_username, 20 - length(counter::TEXT));
            final_username := base_username || counter::TEXT;
        END IF;
    END LOOP;
    
    -- If we can't find a unique username, use UUID suffix
    RETURN left(base_username, 15) || substr(gen_random_uuid()::TEXT, 1, 5);
END;
$$;

-- Function to automatically create profile when user signs up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    generated_username TEXT;
    user_email TEXT;
    display_name TEXT;
BEGIN
    -- Get user email and display name from the new user record
    user_email := COALESCE(NEW.email, '');
    display_name := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', '');
    
    -- Generate unique username
    generated_username := generate_unique_username(user_email, display_name);
    
    -- Insert profile record
    INSERT INTO profiles (
        id,
        full_name,
        username,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        display_name,
        generated_username,
        NOW(),
        NOW()
    );
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the user creation
        RAISE WARNING 'Failed to create profile for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$;

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically create profile on user signup
-- Note: This trigger may fail in some Supabase configurations due to auth schema permissions
-- If it fails, profiles will be created manually via the handle_new_user_manually function
DO $$
BEGIN
    -- Drop trigger if it exists
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    
    -- Try to create the trigger
    BEGIN
        CREATE TRIGGER on_auth_user_created
            AFTER INSERT ON auth.users
            FOR EACH ROW
            EXECUTE FUNCTION handle_new_user();
        
        RAISE NOTICE 'Successfully created trigger on auth.users';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Cannot create trigger on auth.users due to permissions - profiles will be created manually';
        WHEN OTHERS THEN
            RAISE NOTICE 'Cannot create trigger on auth.users: % - profiles will be created manually', SQLERRM;
    END;
END $$;

-- Trigger for updating timestamps on profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Manual function for creating profiles (fallback for when trigger doesn't work)
CREATE OR REPLACE FUNCTION handle_new_user_manually(
    user_id UUID,
    user_email TEXT,
    display_name TEXT DEFAULT ''
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    generated_username TEXT;
BEGIN
    -- Check if profile already exists
    IF EXISTS (SELECT 1 FROM profiles WHERE id = user_id) THEN
        RETURN;
    END IF;
    
    -- Generate unique username
    generated_username := generate_unique_username(user_email, display_name);
    
    -- Insert the profile
    INSERT INTO profiles (
        id,
        full_name,
        username,
        created_at,
        updated_at
    ) VALUES (
        user_id,
        COALESCE(display_name, ''),
        generated_username,
        NOW(),
        NOW()
    );
END;
$$;

-- Function to calculate profile completion percentage
CREATE OR REPLACE FUNCTION calculate_profile_completion(profile_record profiles)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    completed_fields INTEGER := 0;
    total_fields INTEGER := 7;
BEGIN
    -- Count completed fields
    IF profile_record.full_name IS NOT NULL AND trim(profile_record.full_name) != '' THEN
        completed_fields := completed_fields + 1;
    END IF;
    
    IF profile_record.username IS NOT NULL AND trim(profile_record.username) != '' THEN
        completed_fields := completed_fields + 1;
    END IF;
    
    IF profile_record.gender IS NOT NULL THEN
        completed_fields := completed_fields + 1;
    END IF;
    
    IF profile_record.date_of_birth IS NOT NULL THEN
        completed_fields := completed_fields + 1;
    END IF;
    
    IF profile_record.state IS NOT NULL THEN
        completed_fields := completed_fields + 1;
    END IF;
    
    IF profile_record.tags IS NOT NULL AND trim(profile_record.tags) != '' THEN
        completed_fields := completed_fields + 1;
    END IF;
    
    IF profile_record.bio IS NOT NULL AND trim(profile_record.bio) != '' THEN
        completed_fields := completed_fields + 1;
    END IF;
    
    RETURN ROUND((completed_fields::NUMERIC / total_fields::NUMERIC) * 100);
END;
$$;

-- Function to update profile completion status and award points
CREATE OR REPLACE FUNCTION update_profile_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    completion_percentage INTEGER;
    was_complete BOOLEAN;
    is_now_complete BOOLEAN;
BEGIN
    -- Calculate current completion percentage
    completion_percentage := calculate_profile_completion(NEW);
    is_now_complete := (completion_percentage = 100);
    
    -- Check if profile was previously complete
    was_complete := COALESCE(OLD.is_profile_complete, FALSE);
    
    -- Update completion status
    NEW.is_profile_complete := is_now_complete;
    
    -- Award 50 points if profile just became complete (wasn't complete before)
    IF is_now_complete AND NOT was_complete THEN
        NEW.activity_points := COALESCE(NEW.activity_points, 0) + 50;
        RAISE NOTICE 'Profile completed! Awarded 50 points to user %', NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Function to award completion points (alternative approach for manual calls)
CREATE OR REPLACE FUNCTION award_completion_points()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    completion_percentage INTEGER;
    was_complete BOOLEAN;
    is_now_complete BOOLEAN;
BEGIN
    -- Only run after the main completion update
    completion_percentage := calculate_profile_completion(NEW);
    is_now_complete := (completion_percentage = 100);
    was_complete := COALESCE(OLD.is_profile_complete, FALSE);
    
    -- Award points if just completed
    IF is_now_complete AND NOT was_complete THEN
        UPDATE profiles 
        SET activity_points = COALESCE(activity_points, 0) + 50
        WHERE id = NEW.id;
        
        RAISE NOTICE 'Completion bonus: Added 50 points to user %', NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create triggers for profile completion
DROP TRIGGER IF EXISTS trigger_update_profile_completion ON profiles;
CREATE TRIGGER trigger_update_profile_completion
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_profile_completion();

-- RPC Functions for incrementing activity metrics
CREATE OR REPLACE FUNCTION increment_blog_count(user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE profiles 
    SET blog_count = blog_count + 1,
        updated_at = NOW()
    WHERE id = user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Profile not found for user %', user_id;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION increment_places_explored(user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE profiles 
    SET places_explored = places_explored + 1,
        updated_at = NOW()
    WHERE id = user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Profile not found for user %', user_id;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION increment_endorsements(user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE profiles 
    SET endorsements = endorsements + 1,
        updated_at = NOW()
    WHERE id = user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Profile not found for user %', user_id;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION add_activity_points(user_id UUID, points_to_add INTEGER)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE profiles 
    SET activity_points = activity_points + points_to_add,
        updated_at = NOW()
    WHERE id = user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Profile not found for user %', user_id;
    END IF;
END;
$$;

-- Endorsements table to track user-to-user endorsements
CREATE TABLE IF NOT EXISTS endorsements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    endorser_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    endorsed_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent self-endorsement and duplicate endorsements
    CONSTRAINT no_self_endorsement CHECK (endorser_id != endorsed_id),
    CONSTRAINT unique_endorsement UNIQUE (endorser_id, endorsed_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_endorsements_endorser ON endorsements(endorser_id);
CREATE INDEX IF NOT EXISTS idx_endorsements_endorsed ON endorsements(endorsed_id);

-- RLS policies for endorsements
ALTER TABLE endorsements ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (safe to run multiple times)
DROP POLICY IF EXISTS "Anyone can view endorsements" ON endorsements;
DROP POLICY IF EXISTS "Users can create endorsements as themselves" ON endorsements;
DROP POLICY IF EXISTS "Users can delete their own endorsements" ON endorsements;

-- Users can view all endorsements
CREATE POLICY "Anyone can view endorsements" ON endorsements
    FOR SELECT USING (true);

-- Users can only create endorsements as themselves
CREATE POLICY "Users can create endorsements as themselves" ON endorsements
    FOR INSERT WITH CHECK (auth.uid() = endorser_id);

-- Users can delete their own endorsements
CREATE POLICY "Users can delete their own endorsements" ON endorsements
    FOR DELETE USING (auth.uid() = endorser_id);

-- Function to handle endorsement creation with automatic counter update
CREATE OR REPLACE FUNCTION handle_endorsement_creation()
RETURNS TRIGGER AS $$
BEGIN
    -- Increment the endorsed user's endorsement count
    UPDATE profiles 
    SET endorsements = endorsements + 1, updated_at = NOW()
    WHERE id = NEW.endorsed_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to handle endorsement deletion with automatic counter update
CREATE OR REPLACE FUNCTION handle_endorsement_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Decrement the endorsed user's endorsement count
    UPDATE profiles 
    SET endorsements = GREATEST(0, endorsements - 1), updated_at = NOW()
    WHERE id = OLD.endorsed_id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers to automatically update endorsement counts
DROP TRIGGER IF EXISTS endorsement_creation_trigger ON endorsements;
CREATE TRIGGER endorsement_creation_trigger
    AFTER INSERT ON endorsements
    FOR EACH ROW EXECUTE FUNCTION handle_endorsement_creation();

DROP TRIGGER IF EXISTS endorsement_deletion_trigger ON endorsements;
CREATE TRIGGER endorsement_deletion_trigger
    AFTER DELETE ON endorsements
    FOR EACH ROW EXECUTE FUNCTION handle_endorsement_deletion();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON profiles TO anon, authenticated;
GRANT ALL ON endorsements TO anon, authenticated;
GRANT EXECUTE ON FUNCTION generate_unique_username(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION handle_new_user_manually(UUID, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION calculate_profile_completion(profiles) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION increment_blog_count(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION increment_places_explored(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION increment_endorsements(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION add_activity_points(UUID, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION handle_endorsement_creation() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION handle_endorsement_deletion() TO anon, authenticated;
