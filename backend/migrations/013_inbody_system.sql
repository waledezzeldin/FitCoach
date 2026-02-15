-- Migration 013: InBody Body Composition Analysis System
-- Complete body composition tracking with InBody machine data

-- Create inbody_scans table
CREATE TABLE IF NOT EXISTS inbody_scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Body Composition Analysis
  total_body_water DECIMAL(6, 3) NOT NULL, -- kg
  intracellular_water DECIMAL(6, 3) NOT NULL, -- kg
  extracellular_water DECIMAL(6, 3) NOT NULL, -- kg
  dry_lean_mass DECIMAL(6, 3) NOT NULL, -- kg (protein + minerals)
  body_fat_mass DECIMAL(6, 3) NOT NULL, -- kg
  weight DECIMAL(6, 3) NOT NULL, -- kg (total weight)
  
  -- Muscle-Fat Analysis
  skeletal_muscle_mass DECIMAL(6, 3) NOT NULL, -- kg (SMM)
  body_shape VARCHAR(1) CHECK (body_shape IN ('C', 'I', 'D')), -- C-shaped, I-shaped, D-shaped
  
  -- Obesity Analysis
  bmi DECIMAL(5, 3) NOT NULL, -- Body Mass Index
  percent_body_fat DECIMAL(5, 3) NOT NULL, -- %
  
  -- Segmental Lean Analysis (muscle distribution)
  -- Values represent % of sufficient muscle (0-150%)
  left_arm_muscle_percent INTEGER CHECK (left_arm_muscle_percent >= 0 AND left_arm_muscle_percent <= 200),
  right_arm_muscle_percent INTEGER CHECK (right_arm_muscle_percent >= 0 AND right_arm_muscle_percent <= 200),
  trunk_muscle_percent INTEGER CHECK (trunk_muscle_percent >= 0 AND trunk_muscle_percent <= 200),
  left_leg_muscle_percent INTEGER CHECK (left_leg_muscle_percent >= 0 AND left_leg_muscle_percent <= 200),
  right_leg_muscle_percent INTEGER CHECK (right_leg_muscle_percent >= 0 AND right_leg_muscle_percent <= 200),
  
  -- Other Important Parameters
  basal_metabolic_rate INTEGER NOT NULL, -- calories/day (BMR)
  visceral_fat_level INTEGER CHECK (visceral_fat_level >= 1 AND visceral_fat_level <= 20), -- 1-20 scale (VFL)
  ecw_tbw_ratio DECIMAL(5, 3), -- Extracellular Water / Total Body Water ratio (edema indicator)
  inbody_score INTEGER CHECK (inbody_score >= 0 AND inbody_score <= 100), -- 0-100 overall score
  
  -- Metadata
  scan_date TIMESTAMP DEFAULT NOW(),
  scan_location VARCHAR(200), -- Where the scan was performed
  notes TEXT,
  
  -- AI Extraction info (if applicable)
  extracted_via_ai BOOLEAN DEFAULT false,
  ai_confidence_score DECIMAL(3, 2), -- 0.00-1.00
  original_image_url TEXT, -- S3 URL of uploaded InBody printout
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_inbody_scans_user ON inbody_scans(user_id);
CREATE INDEX idx_inbody_scans_scan_date ON inbody_scans(scan_date DESC);
CREATE INDEX idx_inbody_scans_created ON inbody_scans(created_at DESC);

-- Create body composition goals table
CREATE TABLE IF NOT EXISTS body_composition_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Target values
  target_weight DECIMAL(6, 3),
  target_bmi DECIMAL(5, 3),
  target_body_fat_percent DECIMAL(5, 3),
  target_skeletal_muscle_mass DECIMAL(6, 3),
  target_visceral_fat_level INTEGER,
  
  -- Timeline
  target_date DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_body_comp_goals_user ON body_composition_goals(user_id);

-- Create body composition trends view
CREATE OR REPLACE VIEW inbody_trends AS
SELECT 
  user_id,
  scan_date,
  weight,
  bmi,
  percent_body_fat,
  skeletal_muscle_mass,
  visceral_fat_level,
  inbody_score,
  LAG(weight) OVER (PARTITION BY user_id ORDER BY scan_date) as prev_weight,
  LAG(percent_body_fat) OVER (PARTITION BY user_id ORDER BY scan_date) as prev_body_fat,
  LAG(skeletal_muscle_mass) OVER (PARTITION BY user_id ORDER BY scan_date) as prev_muscle_mass,
  weight - LAG(weight) OVER (PARTITION BY user_id ORDER BY scan_date) as weight_change,
  percent_body_fat - LAG(percent_body_fat) OVER (PARTITION BY user_id ORDER BY scan_date) as body_fat_change,
  skeletal_muscle_mass - LAG(skeletal_muscle_mass) OVER (PARTITION BY user_id ORDER BY scan_date) as muscle_mass_change
FROM inbody_scans;

-- Function to get latest inbody scan
CREATE OR REPLACE FUNCTION get_latest_inbody_scan(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  weight DECIMAL,
  bmi DECIMAL,
  percent_body_fat DECIMAL,
  skeletal_muscle_mass DECIMAL,
  inbody_score INTEGER,
  scan_date TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.weight,
    s.bmi,
    s.percent_body_fat,
    s.skeletal_muscle_mass,
    s.inbody_score,
    s.scan_date
  FROM inbody_scans s
  WHERE s.user_id = p_user_id
  ORDER BY s.scan_date DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate body composition progress
CREATE OR REPLACE FUNCTION calculate_body_comp_progress(p_user_id UUID)
RETURNS TABLE (
  days_elapsed INTEGER,
  weight_lost DECIMAL,
  body_fat_reduced DECIMAL,
  muscle_gained DECIMAL,
  progress_percentage DECIMAL
) AS $$
DECLARE
  first_scan RECORD;
  latest_scan RECORD;
  goal RECORD;
BEGIN
  -- Get first and latest scans
  SELECT * INTO first_scan FROM inbody_scans WHERE user_id = p_user_id ORDER BY scan_date ASC LIMIT 1;
  SELECT * INTO latest_scan FROM inbody_scans WHERE user_id = p_user_id ORDER BY scan_date DESC LIMIT 1;
  SELECT * INTO goal FROM body_composition_goals WHERE user_id = p_user_id;
  
  IF first_scan IS NULL OR latest_scan IS NULL THEN
    RETURN;
  END IF;
  
  RETURN QUERY SELECT
    EXTRACT(DAY FROM (latest_scan.scan_date - first_scan.scan_date))::INTEGER as days_elapsed,
    (first_scan.weight - latest_scan.weight) as weight_lost,
    (first_scan.percent_body_fat - latest_scan.percent_body_fat) as body_fat_reduced,
    (latest_scan.skeletal_muscle_mass - first_scan.skeletal_muscle_mass) as muscle_gained,
    CASE 
      WHEN goal.target_weight IS NOT NULL 
      THEN ((first_scan.weight - latest_scan.weight) / (first_scan.weight - goal.target_weight) * 100)
      ELSE NULL
    END as progress_percentage;
END;
$$ LANGUAGE plpgsql;

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_inbody_scans_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_inbody_scans_updated_at
  BEFORE UPDATE ON inbody_scans
  FOR EACH ROW
  EXECUTE FUNCTION update_inbody_scans_updated_at();

CREATE TRIGGER trigger_update_body_comp_goals_updated_at
  BEFORE UPDATE ON body_composition_goals
  FOR EACH ROW
  EXECUTE FUNCTION update_inbody_scans_updated_at();

-- Comments
COMMENT ON TABLE inbody_scans IS 'InBody body composition scan data';
COMMENT ON TABLE body_composition_goals IS 'User body composition goals and targets';
COMMENT ON VIEW inbody_trends IS 'Body composition changes over time with calculations';

COMMENT ON COLUMN inbody_scans.body_shape IS 'Body shape type: C (needs muscle), I (balanced), D (athletic)';
COMMENT ON COLUMN inbody_scans.ecw_tbw_ratio IS 'Edema indicator: >0.390 indicates fluid retention';
COMMENT ON COLUMN inbody_scans.visceral_fat_level IS 'Visceral fat: <10 normal, 10-14 elevated, >15 high risk';
COMMENT ON COLUMN inbody_scans.inbody_score IS 'Overall fitness score: 90+ excellent, 80+ good, 70+ average';
COMMENT ON COLUMN inbody_scans.skeletal_muscle_mass IS 'Total skeletal muscle mass in kg';
COMMENT ON COLUMN inbody_scans.extracted_via_ai IS 'Whether data was extracted via AI from photo';

-- Sample data (for testing)
-- INSERT INTO inbody_scans (user_id, total_body_water, intracellular_water, extracellular_water, 
--   dry_lean_mass, body_fat_mass, weight, skeletal_muscle_mass, body_shape, bmi, percent_body_fat,
--   basal_metabolic_rate, visceral_fat_level, ecw_tbw_ratio, inbody_score,
--   left_arm_muscle_percent, right_arm_muscle_percent, trunk_muscle_percent, 
--   left_leg_muscle_percent, right_leg_muscle_percent)
-- VALUES 
--   ('user-uuid-here', 42.5, 26.5, 16.0, 12.8, 14.2, 75.5, 32.5, 'I', 23.5, 18.8,
--    1650, 8, 0.376, 82, 95, 97, 98, 102, 103);
