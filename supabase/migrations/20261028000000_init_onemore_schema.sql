-- ============================================================================
-- One More - Supabase Database Schema & Business Logic Migrations
-- Tagline: One more step. One more day. One more you.
-- ============================================================================

-- 1. Enable UUID Extension if not already present
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. User Profiles Table
-- Linked 1:1 with Supabase auth.users
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL CHECK (char_length(trim(display_name)) >= 1 AND char_length(display_name) <= 60),
    avatar_url TEXT,
    total_xp INTEGER NOT NULL DEFAULT 0 CHECK (total_xp >= 0),
    current_streak INTEGER NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
    longest_streak INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),
    last_active_date DATE,
    timezone TEXT NOT NULL DEFAULT 'Asia/Jakarta',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Index for profiles
CREATE INDEX IF NOT EXISTS idx_profiles_last_active_date ON public.profiles(last_active_date);

-- 3. Habits Table
CREATE TABLE IF NOT EXISTS public.habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL CHECK (char_length(trim(title)) >= 1 AND char_length(title) <= 100),
    description TEXT CHECK (description IS NULL OR char_length(description) <= 300),
    category TEXT NOT NULL CHECK (category IN ('health', 'learning', 'mindfulness', 'productivity', 'routine')),
    icon_name TEXT NOT NULL DEFAULT 'check_circle',
    accent_color TEXT NOT NULL DEFAULT 'green',
    active_weekdays INTEGER[] NOT NULL DEFAULT '{1,2,3,4,5,6,7}', -- 1=Monday ... 7=Sunday
    reminder_time TEXT, -- 'HH:mm'
    is_archived BOOLEAN NOT NULL DEFAULT false,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_habits_user_archived ON public.habits(user_id, is_archived, sort_order);

-- 4. Habit Completions Table
-- Enforces strictly 1 completion per habit per date via UNIQUE constraint
CREATE TABLE IF NOT EXISTS public.habit_completions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    completion_date DATE NOT NULL,
    xp_awarded INTEGER NOT NULL DEFAULT 15 CHECK (xp_awarded >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_habit_date UNIQUE (habit_id, completion_date)
);

CREATE INDEX IF NOT EXISTS idx_completions_user_date ON public.habit_completions(user_id, completion_date);
CREATE INDEX IF NOT EXISTS idx_completions_habit_id ON public.habit_completions(habit_id);

-- 5. XP Events Table
-- Auditable history of all XP granted, preventing duplicate rewards for identical sources
CREATE TABLE IF NOT EXISTS public.xp_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN ('habit_completion', 'achievement_unlocked', 'streak_bonus', 'mission_bonus')),
    source_id TEXT NOT NULL,
    xp_delta INTEGER NOT NULL CHECK (xp_delta > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_event_source UNIQUE (user_id, event_type, source_id)
);

CREATE INDEX IF NOT EXISTS idx_xp_events_user ON public.xp_events(user_id, created_at DESC);

-- 6. Canonical Achievements Registry Table
CREATE TABLE IF NOT EXISTS public.achievements (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    xp_reward INTEGER NOT NULL DEFAULT 25 CHECK (xp_reward >= 0),
    target_type TEXT NOT NULL CHECK (target_type IN ('total_completions', 'streak_days', 'total_xp', 'level')),
    target_value INTEGER NOT NULL CHECK (target_value > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Seed Canonical Achievements
INSERT INTO public.achievements (id, title, description, icon_name, xp_reward, target_type, target_value)
VALUES 
    ('first_step', 'First Step', 'Selesaikan kebiasaan pertama Anda.', 'directions_walk', 25, 'total_completions', 1),
    ('getting_started', 'Getting Started', 'Raih total akumulasi 100 XP pertamamu.', 'military_tech', 30, 'total_xp', 100),
    ('three_in_a_row', 'Three in a Row', 'Pertahankan streak selama 3 hari berturut-turut.', 'local_fire_department', 35, 'streak_days', 3),
    ('full_week', 'A Full Week', 'Tuntaskan streak konsisten selama 7 hari berturut-turut.', 'stars', 50, 'streak_days', 7),
    ('consistent_10', 'Consistent Action', 'Selesaikan total 10 misi kebiasaan harian.', 'verified', 40, 'total_completions', 10),
    ('master_of_habit', 'Master of Habit', 'Raih Level 5 dengan total minimal 400 XP.', 'workspace_premium', 100, 'level', 5)
ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    icon_name = EXCLUDED.icon_name,
    xp_reward = EXCLUDED.xp_reward,
    target_type = EXCLUDED.target_type,
    target_value = EXCLUDED.target_value;

-- 7. User Unlocked Achievements Table
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_id TEXT NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_achievement UNIQUE (user_id, achievement_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON public.user_achievements(user_id);

-- ============================================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can view and update only their own profile
CREATE POLICY "Users can view own profile" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = id) 
    WITH CHECK (auth.uid() = id);

-- Habits: Users have full access only to their own habits
CREATE POLICY "Users can view own habits" 
    ON public.habits FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habits" 
    ON public.habits FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits" 
    ON public.habits FOR UPDATE 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits" 
    ON public.habits FOR DELETE 
    USING (auth.uid() = user_id);

-- Habit Completions: Users can only read their own completions
CREATE POLICY "Users can view own habit completions" 
    ON public.habit_completions FOR SELECT 
    USING (auth.uid() = user_id);

-- Direct client inserts into completions are blocked from forging arbitrary XP;
-- insertions are handled authoritatively via complete_habit() function or checked strictly
CREATE POLICY "Users can insert own habit completions" 
    ON public.habit_completions FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- XP Events: Users can view their own XP history (no direct insert/update from client)
CREATE POLICY "Users can view own xp events" 
    ON public.xp_events FOR SELECT 
    USING (auth.uid() = user_id);

-- Achievements: Publicly readable for all authenticated users
CREATE POLICY "Authenticated users can read achievements" 
    ON public.achievements FOR SELECT 
    TO authenticated 
    USING (true);

-- User Achievements: Users can view their own unlocked achievements
CREATE POLICY "Users can view own user achievements" 
    ON public.user_achievements FOR SELECT 
    USING (auth.uid() = user_id);

-- ============================================================================
-- 9. TRIGGERS: Automatic Profile Initialization & Timestamps
-- ============================================================================

-- Function to handle new user registration from Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public
AS $$
DECLARE
    v_display_name TEXT;
BEGIN
    v_display_name := COALESCE(
        NEW.raw_user_meta_data->>'display_name',
        split_part(NEW.email, '@', 1),
        'Teman One More'
    );

    INSERT INTO public.profiles (id, display_name, avatar_url, timezone)
    VALUES (NEW.id, v_display_name, NULL, 'Asia/Jakarta')
    ON CONFLICT (id) DO NOTHING;

    RETURN NEW;
END;
$$;

-- Trigger on auth.users after insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_profiles_updated_at ON public.profiles;
CREATE TRIGGER tr_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS tr_habits_updated_at ON public.habits;
CREATE TRIGGER tr_habits_updated_at 
    BEFORE UPDATE ON public.habits 
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================================
-- 10. AUTHORITATIVE COMPLETION TRANSACTION & STREAK / XP / ACHIEVEMENT LOGIC
-- ============================================================================

CREATE OR REPLACE FUNCTION public.complete_habit(
    p_habit_id UUID,
    p_local_date DATE
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID;
    v_habit RECORD;
    v_completion_id UUID;
    v_existing_completion RECORD;
    v_xp_reward INTEGER := 15; -- Standard authoritative XP reward per habit mission
    v_profile RECORD;
    v_new_total_xp INTEGER;
    v_new_streak INTEGER;
    v_new_longest INTEGER;
    v_dow INTEGER; -- ISO day of week 1..7 (1=Mon, 7=Sun)
    v_unlocked_achievements JSONB := '[]'::jsonb;
    v_ach RECORD;
    v_total_completions INTEGER;
    v_curr_level INTEGER;
BEGIN
    -- 1. Validate authenticated caller
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Akses ditolak: Pengguna belum terautentikasi.' USING ERRCODE = '42501';
    END IF;

    -- 2. Verify habit ownership & status
    SELECT * INTO v_habit 
    FROM public.habits 
    WHERE id = p_habit_id AND user_id = v_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kebiasaan tidak ditemukan atau bukan milik pengguna.' USING ERRCODE = 'P0002';
    END IF;

    IF v_habit.is_archived THEN
        RAISE EXCEPTION 'Kebiasaan yang diarsipkan tidak dapat diselesaikan.' USING ERRCODE = '22023';
    END IF;

    -- 3. Verify weekday schedule
    -- EXTRACT(ISODOW FROM date) returns 1 (Mon) to 7 (Sun)
    v_dow := EXTRACT(ISODOW FROM p_local_date)::INTEGER;
    IF NOT (v_dow = ANY(v_habit.active_weekdays)) THEN
        RAISE EXCEPTION 'Kebiasaan tidak dijadwalkan untuk hari ini.' USING ERRCODE = '22023';
    END IF;

    -- 4. Check if already completed for this date (Idempotent return)
    SELECT * INTO v_existing_completion 
    FROM public.habit_completions 
    WHERE habit_id = p_habit_id AND completion_date = p_local_date;

    IF FOUND THEN
        -- Fetch current profile totals to return consistent state without double-rewarding
        SELECT total_xp, current_streak, longest_streak 
        INTO v_profile 
        FROM public.profiles 
        WHERE id = v_user_id;

        RETURN jsonb_build_object(
            'success', true,
            'already_completed', true,
            'completion_id', v_existing_completion.id,
            'xp_awarded', 0,
            'total_xp', COALESCE(v_profile.total_xp, 0),
            'current_level', floor(COALESCE(v_profile.total_xp, 0) / 100) + 1,
            'current_streak', COALESCE(v_profile.current_streak, 0),
            'longest_streak', COALESCE(v_profile.longest_streak, 0),
            'unlocked_achievements', '[]'::jsonb
        );
    END IF;

    -- 5. Insert habit completion atomically
    INSERT INTO public.habit_completions (habit_id, user_id, completion_date, xp_awarded)
    VALUES (p_habit_id, v_user_id, p_local_date, v_xp_reward)
    RETURNING id INTO v_completion_id;

    -- 6. Record XP event
    INSERT INTO public.xp_events (user_id, event_type, source_id, xp_delta)
    VALUES (v_user_id, 'habit_completion', v_completion_id::text, v_xp_reward);

    -- 7. Lock and fetch profile for streak and XP calculation
    SELECT * INTO v_profile 
    FROM public.profiles 
    WHERE id = v_user_id 
    FOR UPDATE;

    v_new_total_xp := v_profile.total_xp + v_xp_reward;
    v_new_streak := v_profile.current_streak;
    v_new_longest := v_profile.longest_streak;

    -- Streak logic:
    -- If already completed something today (last_active_date = p_local_date), streak stays same
    -- If completed yesterday (last_active_date = p_local_date - 1), streak increments by 1
    -- If missed a day or first time (last_active_date < p_local_date - 1 or null), streak resets to 1
    IF v_profile.last_active_date IS NULL THEN
        v_new_streak := 1;
    ELSIF v_profile.last_active_date = p_local_date THEN
        -- Already active today, streak unchanged
        v_new_streak := v_profile.current_streak;
    ELSIF v_profile.last_active_date = (p_local_date - INTERVAL '1 day')::DATE THEN
        v_new_streak := v_profile.current_streak + 1;
    ELSIF v_profile.last_active_date < (p_local_date - INTERVAL '1 day')::DATE THEN
        -- Missed at least one calendar day
        v_new_streak := 1;
    END IF;

    IF v_new_streak > v_new_longest THEN
        v_new_longest := v_new_streak;
    END IF;

    -- Update profile with new XP and streak
    UPDATE public.profiles
    SET 
        total_xp = v_new_total_xp,
        current_streak = v_new_streak,
        longest_streak = v_new_longest,
        last_active_date = CASE 
            WHEN v_profile.last_active_date IS NULL OR p_local_date > v_profile.last_active_date 
            THEN p_local_date 
            ELSE v_profile.last_active_date 
        END
    WHERE id = v_user_id;

    -- 8. Check and unlock achievements
    -- Count total completions for user
    SELECT COUNT(*) INTO v_total_completions 
    FROM public.habit_completions 
    WHERE user_id = v_user_id;

    v_curr_level := floor(v_new_total_xp / 100) + 1;

    FOR v_ach IN 
        SELECT a.* 
        FROM public.achievements a
        WHERE a.id NOT IN (
            SELECT ua.achievement_id 
            FROM public.user_achievements ua 
            WHERE ua.user_id = v_user_id
        )
    LOOP
        IF (v_ach.target_type = 'total_completions' AND v_total_completions >= v_ach.target_value) OR
           (v_ach.target_type = 'streak_days' AND v_new_streak >= v_ach.target_value) OR
           (v_ach.target_type = 'total_xp' AND v_new_total_xp >= v_ach.target_value) OR
           (v_ach.target_type = 'level' AND v_curr_level >= v_ach.target_value)
        THEN
            -- Unlock achievement
            INSERT INTO public.user_achievements (user_id, achievement_id)
            VALUES (v_user_id, v_ach.id)
            ON CONFLICT (user_id, achievement_id) DO NOTHING;

            -- Award achievement XP bonus
            IF v_ach.xp_reward > 0 THEN
                INSERT INTO public.xp_events (user_id, event_type, source_id, xp_delta)
                VALUES (v_user_id, 'achievement_unlocked', v_ach.id, v_ach.xp_reward)
                ON CONFLICT (user_id, event_type, source_id) DO NOTHING;

                v_new_total_xp := v_new_total_xp + v_ach.xp_reward;
                UPDATE public.profiles SET total_xp = v_new_total_xp WHERE id = v_user_id;
                v_curr_level := floor(v_new_total_xp / 100) + 1;
            END IF;

            v_unlocked_achievements := v_unlocked_achievements || jsonb_build_object(
                'id', v_ach.id,
                'title', v_ach.title,
                'description', v_ach.description,
                'icon_name', v_ach.icon_name,
                'xp_reward', v_ach.xp_reward
            );
        END IF;
    END LOOP;

    -- 9. Return full authoritative response
    RETURN jsonb_build_object(
        'success', true,
        'already_completed', false,
        'completion_id', v_completion_id,
        'xp_awarded', v_xp_reward,
        'total_xp', v_new_total_xp,
        'current_level', v_curr_level,
        'current_streak', v_new_streak,
        'longest_streak', v_new_longest,
        'unlocked_achievements', v_unlocked_achievements
    );
END;
$$;

