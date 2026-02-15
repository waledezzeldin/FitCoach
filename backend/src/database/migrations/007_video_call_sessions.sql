-- Migration: Video Call Sessions Table
-- Description: Create table for tracking video call sessions

CREATE TABLE IF NOT EXISTS video_call_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  channel_name VARCHAR(255) NOT NULL UNIQUE,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  duration_minutes INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_video_call_sessions_appointment_id ON video_call_sessions(appointment_id);
CREATE INDEX IF NOT EXISTS idx_video_call_sessions_status ON video_call_sessions(status);
CREATE INDEX IF NOT EXISTS idx_video_call_sessions_started_at ON video_call_sessions(started_at);

-- Comments
COMMENT ON TABLE video_call_sessions IS 'Stores video call session data for appointments';
COMMENT ON COLUMN video_call_sessions.channel_name IS 'Agora channel name for this call';
COMMENT ON COLUMN video_call_sessions.status IS 'Call status: active, completed, failed';
COMMENT ON COLUMN video_call_sessions.duration_minutes IS 'Actual call duration in minutes';
