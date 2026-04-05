-- Shunya Database Schema Migration 002
-- Adds new columns for advanced settings
-- Run this in the Supabase SQL Editor (Dashboard > SQL Editor)

ALTER TABLE public.user_settings 
ADD COLUMN IF NOT EXISTS haptic_intensity TEXT DEFAULT 'light',
ADD COLUMN IF NOT EXISTS continuous_audio_enabled BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS custom_audio_path TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS custom_audio_name TEXT DEFAULT '';
