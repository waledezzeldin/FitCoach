-- ============================================
-- MIGRATION: Workout Templates Support
-- Adds support for starter/advanced template system
-- ============================================

-- Add new columns to workout_plans
ALTER TABLE workout_plans 
  ADD COLUMN IF NOT EXISTS name_ar VARCHAR(255),
  ADD COLUMN IF NOT EXISTS description_ar TEXT,
  ADD COLUMN IF NOT EXISTS goal VARCHAR(50),
  ADD COLUMN IF NOT EXISTS duration_weeks INTEGER,
  ADD COLUMN IF NOT EXISTS days_per_week INTEGER,
  ADD COLUMN IF NOT EXISTS template_id VARCHAR(100),
  ADD COLUMN IF NOT EXISTS template_type VARCHAR(20) CHECK (template_type IN ('starter', 'advanced'));

-- Create workout_weeks table
CREATE TABLE IF NOT EXISTS workout_weeks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_plan_id UUID NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
    week_number INTEGER NOT NULL,
    notes TEXT,
    notes_ar TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workout_plan_id, week_number)
);

CREATE INDEX IF NOT EXISTS idx_workout_weeks_plan ON workout_weeks(workout_plan_id);

-- Update workout_days to reference weeks
ALTER TABLE workout_days 
  ADD COLUMN IF NOT EXISTS workout_week_id UUID REFERENCES workout_weeks(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS day_name_ar VARCHAR(50),
  ADD COLUMN IF NOT EXISTS focus VARCHAR(255),
  ADD COLUMN IF NOT EXISTS focus_ar VARCHAR(255);

-- Rename workout_exercises to workout_day_exercises (more accurate)
CREATE TABLE IF NOT EXISTS workout_day_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_day_id UUID NOT NULL REFERENCES workout_days(id) ON DELETE CASCADE,
    
    -- Exercise reference (can be null for template exercises not in DB)
    exercise_id VARCHAR(100), -- ex_id from template
    exercise_name VARCHAR(255) NOT NULL,
    exercise_name_ar VARCHAR(255),
    
    -- Sets/Reps
    sets INTEGER NOT NULL,
    reps VARCHAR(50) NOT NULL,
    rest_seconds INTEGER,
    
    -- Additional fields from template
    rpe DECIMAL(3,1), -- Rate of Perceived Exertion
    tempo VARCHAR(20),
    notes TEXT,
    notes_ar TEXT,
    
    -- Template data
    equipment JSONB, -- Array of equipment needed
    muscles JSONB, -- Array of muscles worked
    video_id VARCHAR(100),
    
    -- Order
    exercise_order INTEGER NOT NULL,
    
    -- Substitution
    was_substituted BOOLEAN DEFAULT FALSE,
    original_exercise_id VARCHAR(100),
    substitution_reason TEXT,
    
    -- Completion
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    actual_sets INTEGER,
    actual_reps VARCHAR(50),
    actual_weight DECIMAL(6,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workout_day_exercises_day ON workout_day_exercises(workout_day_id);
CREATE INDEX IF NOT EXISTS idx_workout_day_exercises_exercise ON workout_day_exercises(exercise_id);

-- Create conditioning table for cardio/conditioning work
CREATE TABLE IF NOT EXISTS workout_day_conditioning (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_day_id UUID NOT NULL REFERENCES workout_days(id) ON DELETE CASCADE,
    
    type VARCHAR(50), -- 'intervals', 'steady', etc.
    type_ar VARCHAR(50),
    protocol TEXT,
    protocol_ar TEXT,
    intensity VARCHAR(50),
    target_heart_rate VARCHAR(50),
    duration_min INTEGER,
    machine_options JSONB, -- Array of machine options
    
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    actual_duration_min INTEGER,
    average_heart_rate INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workout_day_conditioning_day ON workout_day_conditioning(workout_day_id);

-- Create workout plan metadata table for template-specific data
CREATE TABLE IF NOT EXISTS workout_plan_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_plan_id UUID NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE UNIQUE,
    
    location VARCHAR(50), -- 'gym', 'home', 'outdoors', 'hybrid'
    blocks JSONB, -- Periodization blocks
    fitness_score_projection JSONB, -- Expected fitness score progression
    routing_config JSONB, -- Injury swaps, equipment swaps config
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workout_plan_metadata_plan ON workout_plan_metadata(workout_plan_id);

-- Add intake stage to users table
ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS intake_completed_stage VARCHAR(20) CHECK (intake_completed_stage IN ('basic', 'full', NULL));

-- Add template-related fields to user_intake
ALTER TABLE user_intake
  ADD COLUMN IF NOT EXISTS workout_location VARCHAR(50),
  ADD COLUMN IF NOT EXISTS available_days INTEGER,
  ADD COLUMN IF NOT EXISTS training_days_per_week INTEGER;

-- Create view for active workout plans with progress
CREATE OR REPLACE VIEW active_workout_plans_with_progress AS
SELECT 
    wp.id,
    wp.user_id,
    wp.coach_id,
    wp.name,
    wp.name_ar,
    wp.description,
    wp.description_ar,
    wp.goal,
    wp.duration_weeks,
    wp.days_per_week,
    wp.start_date,
    wp.end_date,
    wp.template_id,
    wp.template_type,
    wp.is_active,
    COUNT(DISTINCT ww.id) as total_weeks,
    COUNT(DISTINCT wd.id) as total_days,
    COUNT(DISTINCT wde.id) as total_exercises,
    COUNT(DISTINCT CASE WHEN wde.is_completed THEN wde.id END) as completed_exercises,
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT wde.id) > 0 
            THEN (COUNT(DISTINCT CASE WHEN wde.is_completed THEN wde.id END)::DECIMAL / COUNT(DISTINCT wde.id)::DECIMAL) * 100 
            ELSE 0 
        END, 
        2
    ) as completion_percentage
FROM workout_plans wp
LEFT JOIN workout_weeks ww ON wp.id = ww.workout_plan_id
LEFT JOIN workout_days wd ON ww.id = wd.workout_week_id
LEFT JOIN workout_day_exercises wde ON wd.id = wde.workout_day_id
WHERE wp.is_active = TRUE
GROUP BY wp.id;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_workout_plans_template_type ON workout_plans(template_type);
CREATE INDEX IF NOT EXISTS idx_workout_plans_goal ON workout_plans(goal);
CREATE INDEX IF NOT EXISTS idx_users_intake_stage ON users(intake_completed_stage);

COMMENT ON TABLE workout_weeks IS 'Workout weeks within a plan (supports multi-week programs)';
COMMENT ON TABLE workout_day_exercises IS 'Individual exercises within a workout day';
COMMENT ON TABLE workout_day_conditioning IS 'Conditioning/cardio work for a workout day';
COMMENT ON TABLE workout_plan_metadata IS 'Additional metadata for template-based workout plans';
COMMENT ON COLUMN workout_plans.template_type IS 'starter = based on 3 basic intake questions, advanced = based on full intake';
COMMENT ON COLUMN workout_day_exercises.rpe IS 'Rate of Perceived Exertion (1-10 scale)';
COMMENT ON COLUMN users.intake_completed_stage IS 'basic = first 3 questions only, full = complete intake questionnaire';
