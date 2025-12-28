-- Migration 012: Push Notifications System
-- Device management for Firebase Cloud Messaging

-- Create user_devices table
CREATE TABLE IF NOT EXISTS user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_token VARCHAR(500) UNIQUE NOT NULL, -- FCM token
  device_type VARCHAR(20) NOT NULL CHECK (device_type IN ('ios', 'android', 'web')),
  device_info JSONB DEFAULT '{}', -- Device model, OS version, app version, etc.
  is_active BOOLEAN DEFAULT true,
  last_used_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_user_devices_user ON user_devices(user_id);
CREATE INDEX idx_user_devices_token ON user_devices(device_token);
CREATE INDEX idx_user_devices_active ON user_devices(is_active);

-- Create notification_preferences table
CREATE TABLE IF NOT EXISTS notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Notification toggles
  messages_enabled BOOLEAN DEFAULT true,
  workout_reminders_enabled BOOLEAN DEFAULT true,
  booking_reminders_enabled BOOLEAN DEFAULT true,
  progress_updates_enabled BOOLEAN DEFAULT true,
  nutrition_reminders_enabled BOOLEAN DEFAULT true,
  subscription_updates_enabled BOOLEAN DEFAULT true,
  marketing_enabled BOOLEAN DEFAULT false,
  
  -- Quiet hours
  quiet_hours_enabled BOOLEAN DEFAULT false,
  quiet_hours_start TIME DEFAULT '22:00',
  quiet_hours_end TIME DEFAULT '08:00',
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notification_prefs_user ON notification_preferences(user_id);

-- Create notification_history table (for tracking sent notifications)
CREATE TABLE IF NOT EXISTS notification_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  notification_type VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  status VARCHAR(20) DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'failed', 'clicked')),
  sent_at TIMESTAMP DEFAULT NOW(),
  delivered_at TIMESTAMP,
  clicked_at TIMESTAMP
);

CREATE INDEX idx_notification_history_user ON notification_history(user_id);
CREATE INDEX idx_notification_history_type ON notification_history(notification_type);
CREATE INDEX idx_notification_history_sent ON notification_history(sent_at DESC);

-- Create scheduled_notifications table (for future scheduled notifications)
CREATE TABLE IF NOT EXISTS scheduled_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  notification_type VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  scheduled_for TIMESTAMP NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'cancelled', 'failed')),
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_scheduled_notifications_user ON scheduled_notifications(user_id);
CREATE INDEX idx_scheduled_notifications_scheduled ON scheduled_notifications(scheduled_for);
CREATE INDEX idx_scheduled_notifications_status ON scheduled_notifications(status);

-- Function to update last_used_at for devices
CREATE OR REPLACE FUNCTION update_device_last_used()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_used_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_device_last_used
  BEFORE UPDATE ON user_devices
  FOR EACH ROW
  EXECUTE FUNCTION update_device_last_used();

-- Function to automatically create notification preferences for new users
CREATE OR REPLACE FUNCTION create_notification_preferences()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notification_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_notification_preferences
  AFTER INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION create_notification_preferences();

-- Update timestamp triggers
CREATE OR REPLACE FUNCTION update_notification_prefs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_notification_prefs_updated_at
  BEFORE UPDATE ON notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_notification_prefs_updated_at();

CREATE TRIGGER trigger_update_user_devices_updated_at
  BEFORE UPDATE ON user_devices
  FOR EACH ROW
  EXECUTE FUNCTION update_notification_prefs_updated_at();

-- Cleanup old notification history (older than 90 days)
CREATE OR REPLACE FUNCTION cleanup_old_notification_history()
RETURNS void AS $$
BEGIN
  DELETE FROM notification_history
  WHERE sent_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON TABLE user_devices IS 'FCM device tokens for push notifications';
COMMENT ON TABLE notification_preferences IS 'User notification settings and preferences';
COMMENT ON TABLE notification_history IS 'Log of all sent notifications';
COMMENT ON TABLE scheduled_notifications IS 'Notifications scheduled for future delivery';

COMMENT ON COLUMN user_devices.device_token IS 'Firebase Cloud Messaging (FCM) registration token';
COMMENT ON COLUMN user_devices.device_info IS 'JSON with device details: model, OS version, app version';
COMMENT ON COLUMN notification_preferences.quiet_hours_enabled IS 'Whether to respect quiet hours';
COMMENT ON COLUMN notification_preferences.quiet_hours_start IS 'Start of quiet hours (no notifications)';
COMMENT ON COLUMN notification_preferences.quiet_hours_end IS 'End of quiet hours';
