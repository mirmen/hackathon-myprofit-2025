-- Migration: Create events table
-- Description: Add events table for club events functionality

-- Create events table
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT,
  event_type TEXT NOT NULL DEFAULT 'meeting',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for better performance
CREATE INDEX idx_events_club_id ON events(club_id);
CREATE INDEX idx_events_date_time ON events(date_time);
CREATE INDEX idx_events_event_type ON events(event_type);