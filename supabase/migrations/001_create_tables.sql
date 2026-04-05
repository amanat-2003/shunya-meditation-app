-- Shunya Database Schema
-- Run this in the Supabase SQL Editor (Dashboard > SQL Editor)

-- ========================
-- 1. MEDITATION SESSIONS
-- ========================
CREATE TABLE IF NOT EXISTS public.meditation_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  total_taps INT NOT NULL DEFAULT 0,
  duration_seconds INT NOT NULL DEFAULT 0,
  goal_reached BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  sync_status TEXT NOT NULL DEFAULT 'synced' CHECK (sync_status IN ('synced', 'pending'))
);

-- Enable Row Level Security
ALTER TABLE public.meditation_sessions ENABLE ROW LEVEL SECURITY;

-- Users can only see their own sessions
CREATE POLICY "Users can view own sessions"
  ON public.meditation_sessions FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own sessions
CREATE POLICY "Users can insert own sessions"
  ON public.meditation_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own sessions
CREATE POLICY "Users can update own sessions"
  ON public.meditation_sessions FOR UPDATE
  USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_sessions_user_created 
  ON public.meditation_sessions(user_id, created_at DESC);


-- ========================
-- 2. USER SETTINGS
-- ========================
CREATE TABLE IF NOT EXISTS public.user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  daily_tap_goal INT DEFAULT 1080,
  daily_time_goal_seconds INT DEFAULT 600,
  haptic_interval INT DEFAULT 1,
  audio_reminder_enabled BOOLEAN DEFAULT FALSE,
  audio_reminder_sound TEXT DEFAULT 'om',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- Users can manage their own settings (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY "Users can manage own settings"
  ON public.user_settings FOR ALL
  USING (auth.uid() = user_id);
