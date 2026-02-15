-- Migration 008: Coach Customization Support
-- Adds support for coaches to customize workout plans per user

-- Add custom flags to workout_plans table
ALTER TABLE workout_plans
ADD COLUMN IF NOT EXISTS is_custom BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS custom_notes TEXT,
ADD COLUMN IF NOT EXISTS original_template_id UUID;

-- Create coach customization log table
CREATE TABLE IF NOT EXISTS coach_customization_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coach_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  workout_plan_id UUID REFERENCES workout_plans(id) ON DELETE CASCADE,
  original_plan_id UUID REFERENCES workout_plans(id) ON DELETE SET NULL,
  workout_day_id UUID REFERENCES workout_days(id) ON DELETE SET NULL,
  exercise_id UUID REFERENCES workout_exercises(id) ON DELETE SET NULL,
  customization_type VARCHAR(50) NOT NULL, -- 'clone', 'exercise_update', 'day_note', 'substitute', etc.
  changes JSONB, -- Store the actual changes made
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_coach_customization_log_coach ON coach_customization_log(coach_id);
CREATE INDEX IF NOT EXISTS idx_coach_customization_log_user ON coach_customization_log(user_id);
CREATE INDEX IF NOT EXISTS idx_coach_customization_log_plan ON coach_customization_log(workout_plan_id);
CREATE INDEX IF NOT EXISTS idx_coach_customization_log_created ON coach_customization_log(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_workout_plans_custom ON workout_plans(is_custom) WHERE is_custom = true;
CREATE INDEX IF NOT EXISTS idx_workout_plans_coach ON workout_plans(coach_id) WHERE coach_id IS NOT NULL;

-- Add comments
COMMENT ON TABLE coach_customization_log IS 'Tracks all coach customizations to workout plans for specific users';
COMMENT ON COLUMN workout_plans.is_custom IS 'True if this plan has been customized by a coach for a specific user';
COMMENT ON COLUMN workout_plans.custom_notes IS 'Notes from coach about customizations';
COMMENT ON COLUMN workout_plans.original_template_id IS 'Reference to original template if this is a customized copy';
