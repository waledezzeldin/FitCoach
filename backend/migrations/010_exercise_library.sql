-- Migration 010: Complete Exercise Library
-- Comprehensive exercise database with all exercises from workout templates

-- Create exercises table
CREATE TABLE IF NOT EXISTS exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ex_id VARCHAR(100) UNIQUE NOT NULL, -- e.g., 'bench_press', 'lat_pulldown'
  name_en VARCHAR(200) NOT NULL,
  name_ar VARCHAR(200) NOT NULL,
  description_en TEXT,
  description_ar TEXT,
  muscle_groups TEXT[] NOT NULL, -- e.g., ['chest', 'triceps']
  equipment TEXT[] NOT NULL, -- e.g., ['barbell', 'bench']
  difficulty VARCHAR(20) CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  video_url TEXT,
  video_id VARCHAR(100), -- For internal video reference
  thumbnail_url TEXT,
  instructions_en TEXT[],
  instructions_ar TEXT[],
  common_mistakes_en TEXT[],
  common_mistakes_ar TEXT[],
  coaching_cues_en TEXT[],
  coaching_cues_ar TEXT[],
  default_sets INTEGER DEFAULT 3,
  default_reps VARCHAR(20) DEFAULT '8-12', -- Can be '8-12' or '30s' etc
  default_rest_seconds INTEGER DEFAULT 90,
  location_type VARCHAR(20) CHECK (location_type IN ('gym', 'home', 'both')) DEFAULT 'both',
  is_compound BOOLEAN DEFAULT false,
  alternatives TEXT[], -- Array of ex_ids for alternative exercises
  injury_contraindications TEXT[], -- e.g., ['shoulder', 'lower_back']
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_exercises_ex_id ON exercises(ex_id);
CREATE INDEX idx_exercises_muscle_groups ON exercises USING GIN(muscle_groups);
CREATE INDEX idx_exercises_equipment ON exercises USING GIN(equipment);
CREATE INDEX idx_exercises_difficulty ON exercises(difficulty);
CREATE INDEX idx_exercises_location ON exercises(location_type);

-- Create user favorite exercises table
CREATE TABLE IF NOT EXISTS user_favorite_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  added_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, exercise_id)
);

CREATE INDEX idx_user_favorites_user ON user_favorite_exercises(user_id);

-- Insert comprehensive exercise library
-- CHEST EXERCISES
INSERT INTO exercises (ex_id, name_en, name_ar, muscle_groups, equipment, difficulty, location_type, is_compound, default_sets, default_reps, default_rest_seconds, description_en, description_ar, alternatives, video_id) VALUES
('bench_press', 'Bench Press', 'ضغط البنش', ARRAY['chest', 'triceps', 'shoulders'], ARRAY['barbell', 'bench'], 'intermediate', 'gym', true, 4, '6-10', 150, 'The king of chest exercises', 'ملك تمارين الصدر', ARRAY['dumbbell_press', 'push_ups'], 'vid_bench_press'),
('dumbbell_press', 'Dumbbell Press', 'ضغط دمبل', ARRAY['chest', 'triceps', 'shoulders'], ARRAY['dumbbell', 'bench'], 'intermediate', 'both', true, 4, '8-12', 120, 'Great for muscle balance', 'ممتاز لتوازن العضلات', ARRAY['bench_press', 'push_ups'], 'vid_dumbbell_press'),
('incline_db_press', 'Incline Dumbbell Press', 'ضغط دمبل مائل', ARRAY['chest', 'shoulders'], ARRAY['dumbbell', 'bench'], 'intermediate', 'both', true, 4, '8-12', 120, 'Targets upper chest', 'يستهدف الصدر العلوي', ARRAY['incline_press', 'dumbbell_press'], 'vid_incline_db_press'),
('incline_press', 'Incline Barbell Press', 'ضغط بار مائل', ARRAY['chest', 'shoulders'], ARRAY['barbell', 'bench'], 'intermediate', 'gym', true, 4, '6-10', 150, 'Upper chest focus', 'تركيز الصدر العلوي', ARRAY['incline_db_press', 'bench_press'], 'vid_incline_press'),
('push_ups', 'Push-ups', 'تمرين الضغط', ARRAY['chest', 'triceps', 'core'], ARRAY['bodyweight'], 'beginner', 'both', true, 3, '10-20', 60, 'Classic bodyweight exercise', 'تمرين وزن الجسم الكلاسيكي', ARRAY['knee_push_ups', 'bench_press'], 'vid_push_ups'),
('flies', 'Dumbbell Flyes', 'فتح دمبل', ARRAY['chest'], ARRAY['dumbbell', 'bench'], 'intermediate', 'both', false, 3, '10-15', 90, 'Chest isolation', 'عزل الصدر', ARRAY['cable_flies', 'push_ups'], 'vid_flies'),
('cable_flies', 'Cable Flyes', 'فتح كابل', ARRAY['chest'], ARRAY['cable'], 'intermediate', 'gym', false, 3, '12-15', 75, 'Constant tension on chest', 'توتر مستمر على الصدر', ARRAY['flies', 'push_ups'], 'vid_cable_flies');

-- BACK EXERCISES
INSERT INTO exercises (ex_id, name_en, name_ar, muscle_groups, equipment, difficulty, location_type, is_compound, default_sets, default_reps, default_rest_seconds, description_en, description_ar, alternatives, video_id) VALUES
('pull_up', 'Pull-ups', 'عقلة', ARRAY['lats', 'biceps', 'back'], ARRAY['pullup_bar'], 'intermediate', 'both', true, 3, '6-10', 150, 'Ultimate back builder', 'الأفضل لبناء الظهر', ARRAY['lat_pulldown', 'assisted_pullup'], 'vid_pull_up'),
('lat_pulldown', 'Lat Pulldown', 'سحب عريض', ARRAY['lats', 'biceps'], ARRAY['machine', 'cable'], 'beginner', 'gym', true, 4, '8-12', 120, 'Great lat developer', 'ممتاز لتطوير اللاتس', ARRAY['pull_up', 'cable_row'], 'vid_lat_pulldown'),
('barbell_row', 'Barbell Row', 'تجديف بار', ARRAY['back', 'lats', 'traps'], ARRAY['barbell'], 'intermediate', 'gym', true, 4, '6-10', 150, 'Thick back builder', 'بناء ظهر سميك', ARRAY['dumbbell_row', 'cable_row'], 'vid_barbell_row'),
('dumbbell_row', 'Dumbbell Row', 'تجديف دمبل', ARRAY['back', 'lats'], ARRAY['dumbbell', 'bench'], 'beginner', 'both', true, 4, '8-12', 120, 'Unilateral back work', 'عمل ظهر أحادي', ARRAY['barbell_row', 'cable_row'], 'vid_dumbbell_row'),
('cable_row', 'Cable Row', 'تجديف كابل', ARRAY['back', 'lats'], ARRAY['cable'], 'beginner', 'gym', true, 3, '10-12', 90, 'Constant tension rows', 'تجديف بتوتر مستمر', ARRAY['barbell_row', 'dumbbell_row'], 'vid_cable_row'),
('deadlift', 'Deadlift', 'رفعة ميتة', ARRAY['back', 'glutes', 'hamstrings', 'traps'], ARRAY['barbell'], 'advanced', 'gym', true, 3, '5-8', 210, 'The king of exercises', 'ملك التمارين', ARRAY['romanian_deadlift', 'trap_bar_deadlift'], 'vid_deadlift'),
('romanian_deadlift', 'Romanian Deadlift', 'رفعة رومانية', ARRAY['hamstrings', 'glutes', 'lower_back'], ARRAY['barbell'], 'intermediate', 'gym', true, 4, '8-12', 150, 'Hamstring focus', 'تركيز على الأوتار', ARRAY['deadlift', 'leg_curl'], 'vid_rdl');

-- SHOULDER EXERCISES
INSERT INTO exercises (ex_id, name_en, name_ar, muscle_groups, equipment, difficulty, location_type, is_compound, default_sets, default_reps, default_rest_seconds, description_en, description_ar, alternatives, video_id) VALUES
('overhead_press', 'Overhead Press', 'ضغط فوق الرأس', ARRAY['shoulders', 'triceps'], ARRAY['barbell'], 'intermediate', 'gym', true, 3, '6-10', 150, 'Build strong shoulders', 'بناء أكتاف قوية', ARRAY['dumbbell_press', 'arnold_press'], 'vid_ohp'),
('dumbbell_shoulder_press', 'Dumbbell Shoulder Press', 'ضغط أكتاف دمبل', ARRAY['shoulders', 'triceps'], ARRAY['dumbbell'], 'beginner', 'both', true, 3, '8-12', 120, 'Shoulder mass builder', 'بناء كتلة الأكتاف', ARRAY['overhead_press', 'arnold_press'], 'vid_db_shoulder_press'),
('lateral_raise', 'Lateral Raise', 'رفع جانبي', ARRAY['shoulders'], ARRAY['dumbbell'], 'beginner', 'both', false, 3, '12-15', 60, 'Side delt focus', 'تركيز الكتف الجانبي', ARRAY['cable_lateral_raise'], 'vid_lateral_raise'),
('front_raise', 'Front Raise', 'رفع أمامي', ARRAY['shoulders'], ARRAY['dumbbell'], 'beginner', 'both', false, 3, '12-15', 60, 'Front delt isolation', 'عزل الكتف الأمامي', ARRAY['overhead_press'], 'vid_front_raise'),
('rear_delt_fly', 'Rear Delt Fly', 'فتح خلفي', ARRAY['shoulders', 'back'], ARRAY['dumbbell'], 'beginner', 'both', false, 3, '12-15', 60, 'Rear delt development', 'تطوير الكتف الخلفي', ARRAY['face_pulls'], 'vid_rear_delt_fly'),
('arnold_press', 'Arnold Press', 'ضغط أرنولد', ARRAY['shoulders', 'triceps'], ARRAY['dumbbell'], 'intermediate', 'both', true, 3, '8-12', 120, 'Complete shoulder workout', 'تمرين كتف كامل', ARRAY['dumbbell_shoulder_press'], 'vid_arnold_press');

-- LEG EXERCISES
INSERT INTO exercises (ex_id, name_en, name_ar, muscle_groups, equipment, difficulty, location_type, is_compound, default_sets, default_reps, default_rest_seconds, description_en, description_ar, alternatives, video_id) VALUES
('back_squat', 'Back Squat', 'سكوات خلفي', ARRAY['quads', 'glutes', 'hamstrings'], ARRAY['barbell', 'rack'], 'intermediate', 'gym', true, 4, '6-10', 180, 'Leg mass builder', 'بناء كتلة الأرجل', ARRAY['front_squat', 'leg_press'], 'vid_back_squat'),
('front_squat', 'Front Squat', 'سكوات أمامي', ARRAY['quads', 'core'], ARRAY['barbell', 'rack'], 'advanced', 'gym', true, 4, '6-10', 180, 'Quad dominant squat', 'سكوات مهيمن على الكواد', ARRAY['back_squat', 'goblet_squat'], 'vid_front_squat'),
('goblet_squat', 'Goblet Squat', 'سكوات غوبلت', ARRAY['quads', 'glutes'], ARRAY['dumbbell'], 'beginner', 'both', true, 3, '12-15', 90, 'Great beginner squat', 'سكوات رائع للمبتدئين', ARRAY['back_squat', 'bodyweight_squat'], 'vid_goblet_squat'),
('leg_press', 'Leg Press', 'ضغط الساق', ARRAY['quads', 'glutes'], ARRAY['machine'], 'beginner', 'gym', true, 3, '12-15', 120, 'Quad mass builder', 'بناء كتلة الكواد', ARRAY['back_squat', 'hack_squat'], 'vid_leg_press'),
('leg_curl', 'Leg Curl', 'ثني الساق', ARRAY['hamstrings'], ARRAY['machine'], 'beginner', 'gym', false, 3, '12-15', 90, 'Hamstring isolation', 'عزل الأوتار الخلفية', ARRAY['romanian_deadlift'], 'vid_leg_curl'),
('leg_extension', 'Leg Extension', 'تمديد الساق', ARRAY['quads'], ARRAY['machine'], 'beginner', 'gym', false, 3, '12-15', 90, 'Quad isolation', 'عزل الكواد', ARRAY['leg_press', 'squats'], 'vid_leg_extension'),
('lunges', 'Lunges', 'اندفاع', ARRAY['quads', 'glutes'], ARRAY['dumbbell'], 'beginner', 'both', true, 3, '10-12', 90, 'Unilateral leg work', 'عمل أرجل أحادي', ARRAY['split_squat', 'goblet_squat'], 'vid_lunges'),
('bulgarian_split_squat', 'Bulgarian Split Squat', 'سكوات بلغاري', ARRAY['quads', 'glutes'], ARRAY['dumbbell'], 'intermediate', 'both', true, 3, '10-12', 90, 'Advanced unilateral', 'أحادي متقدم', ARRAY['lunges', 'goblet_squat'], 'vid_bulgarian_split'),
('calf_raise', 'Calf Raise', 'رفع السمانة', ARRAY['calves'], ARRAY['machine'], 'beginner', 'gym', false, 4, '15-20', 60, 'Calf development', 'تطوير السمانة', ARRAY['seated_calf_raise'], 'vid_calf_raise');

-- ARM EXERCISES
INSERT INTO exercises (ex_id, name_en, name_ar, muscle_groups, equipment, difficulty, location_type, is_compound, default_sets, default_reps, default_rest_seconds, description_en, description_ar, alternatives, video_id) VALUES
('db_curl', 'Dumbbell Curl', 'تمرين البايسبس', ARRAY['biceps'], ARRAY['dumbbell'], 'beginner', 'both', false, 3, '10-12', 60, 'Classic bicep builder', 'بناء بايسبس كلاسيكي', ARRAY['barbell_curl', 'hammer_curl'], 'vid_db_curl'),
('barbell_curl', 'Barbell Curl', 'باي بار', ARRAY['biceps'], ARRAY['barbell'], 'beginner', 'both', false, 3, '8-12', 60, 'Mass bicep builder', 'بناء كتلة البايسبس', ARRAY['db_curl', 'ez_bar_curl'], 'vid_barbell_curl'),
('hammer_curl', 'Hammer Curl', 'مطرقة', ARRAY['biceps', 'forearms'], ARRAY['dumbbell'], 'beginner', 'both', false, 3, '10-12', 60, 'Builds forearm thickness', 'يبني سمك الساعد', ARRAY['db_curl'], 'vid_hammer_curl'),
('tricep_pushdown', 'Tricep Pushdown', 'دفع التراي', ARRAY['triceps'], ARRAY['cable'], 'beginner', 'gym', false, 3, '12-15', 60, 'Tricep isolation', 'عزل التراي', ARRAY['overhead_extension', 'dips'], 'vid_tricep_pushdown'),
('overhead_extension', 'Overhead Extension', 'مد فوق الرأس', ARRAY['triceps'], ARRAY['dumbbell'], 'beginner', 'both', false, 3, '10-12', 60, 'Long head tricep focus', 'تركيز الرأس الطويل', ARRAY['tricep_pushdown'], 'vid_overhead_ext'),
('dips', 'Dips', 'تمرين البار الموازي', ARRAY['triceps', 'chest', 'shoulders'], ARRAY['dip_bars'], 'intermediate', 'both', true, 3, '8-12', 90, 'Great tricep mass builder', 'بناء كتلة التراي ممتاز', ARRAY['tricep_pushdown', 'close_grip_bench'], 'vid_dips');

-- CORE EXERCISES
INSERT INTO exercises (ex_id, name_en, name_ar, muscle_groups, equipment, difficulty, location_type, is_compound, default_sets, default_reps, default_rest_seconds, description_en, description_ar, alternatives, video_id) VALUES
('plank', 'Plank', 'بلانك', ARRAY['core', 'abs'], ARRAY['bodyweight'], 'beginner', 'both', false, 3, '45-60s', 60, 'Core stability', 'ثبات الجذع', ARRAY['dead_bug', 'side_plank'], 'vid_plank'),
('crunches', 'Crunches', 'تكسير', ARRAY['abs'], ARRAY['bodyweight'], 'beginner', 'both', false, 3, '15-20', 45, 'Basic ab exercise', 'تمرين بطن أساسي', ARRAY['sit_ups', 'leg_raises'], 'vid_crunches'),
('leg_raises', 'Leg Raises', 'رفع الأرجل', ARRAY['abs', 'hip_flexors'], ARRAY['bodyweight'], 'intermediate', 'both', false, 3, '12-15', 60, 'Lower ab focus', 'تركيز البطن السفلي', ARRAY['hanging_leg_raises', 'crunches'], 'vid_leg_raises'),
('russian_twist', 'Russian Twist', 'التواء روسي', ARRAY['obliques', 'core'], ARRAY['bodyweight'], 'beginner', 'both', false, 3, '20-30', 45, 'Oblique training', 'تدريب الجوانب', ARRAY['side_plank', 'wood_chop'], 'vid_russian_twist'),
('dead_bug', 'Dead Bug', 'الحشرة الميتة', ARRAY['core', 'abs'], ARRAY['bodyweight'], 'beginner', 'both', false, 3, '10-12', 60, 'Core stability and control', 'ثبات وتحكم الجذع', ARRAY['plank', 'bird_dog'], 'vid_dead_bug');

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_exercises_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_exercises_updated_at
  BEFORE UPDATE ON exercises
  FOR EACH ROW
  EXECUTE FUNCTION update_exercises_updated_at();

-- Comments
COMMENT ON TABLE exercises IS 'Complete exercise library with bilingual support';
COMMENT ON COLUMN exercises.ex_id IS 'Unique exercise identifier used in workout templates';
COMMENT ON COLUMN exercises.muscle_groups IS 'Array of muscle groups targeted';
COMMENT ON COLUMN exercises.equipment IS 'Array of required equipment';
COMMENT ON COLUMN exercises.alternatives IS 'Array of ex_ids for alternative exercises';
COMMENT ON COLUMN exercises.is_compound IS 'Whether this is a compound (multi-joint) exercise';
COMMENT ON COLUMN exercises.injury_contraindications IS 'Injuries that contraindicate this exercise';
