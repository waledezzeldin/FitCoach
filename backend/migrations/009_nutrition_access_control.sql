-- Migration 009: Nutrition Access Control
-- Adds time-limited nutrition access for Freemium users

-- Add nutrition access tracking fields to users table
ALTER TABLE users
ADD COLUMN IF NOT EXISTS nutrition_access_unlocked_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS nutrition_access_expires_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS first_workout_completed_at TIMESTAMP;

-- Create index for nutrition access expiry checks (used by cron job)
CREATE INDEX IF NOT EXISTS idx_users_nutrition_expiry 
ON users(nutrition_access_expires_at) 
WHERE nutrition_access_expires_at IS NOT NULL;

-- Create index for freemium users with active trials
CREATE INDEX IF NOT EXISTS idx_users_freemium_trial 
ON users(subscription_tier, nutrition_access_unlocked_at) 
WHERE subscription_tier = 'freemium' AND nutrition_access_unlocked_at IS NOT NULL;

-- Add comments
COMMENT ON COLUMN users.nutrition_access_unlocked_at IS 'When nutrition access was first unlocked (trial start for freemium)';
COMMENT ON COLUMN users.nutrition_access_expires_at IS 'When nutrition trial expires (NULL for premium = unlimited)';
COMMENT ON COLUMN users.first_workout_completed_at IS 'When user completed their first workout (triggers nutrition trial)';

-- Create view for nutrition access monitoring
CREATE OR REPLACE VIEW nutrition_access_status AS
SELECT 
  u.id as user_id,
  u.full_name,
  u.subscription_tier,
  u.nutrition_access_unlocked_at,
  u.nutrition_access_expires_at,
  u.first_workout_completed_at,
  CASE 
    WHEN u.subscription_tier IN ('premium', 'smart_premium') THEN 'unlimited'
    WHEN u.subscription_tier = 'freemium' AND u.nutrition_access_unlocked_at IS NOT NULL 
         AND (u.nutrition_access_expires_at IS NULL OR u.nutrition_access_expires_at > NOW()) THEN 'trial_active'
    WHEN u.subscription_tier = 'freemium' AND u.nutrition_access_expires_at < NOW() THEN 'trial_expired'
    ELSE 'locked'
  END as access_status,
  CASE
    WHEN u.subscription_tier = 'freemium' AND u.nutrition_access_expires_at IS NOT NULL THEN
      GREATEST(0, EXTRACT(EPOCH FROM (u.nutrition_access_expires_at - NOW())) / 86400)
    ELSE NULL
  END as days_remaining
FROM users u;

COMMENT ON VIEW nutrition_access_status IS 'Real-time view of nutrition access status for all users';
