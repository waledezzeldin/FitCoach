-- ============================================
-- MIGRATION: Exercise schema alignment
-- Adds ex_id and array-based fields for templates
-- ============================================

ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS ex_id VARCHAR(100),
  ADD COLUMN IF NOT EXISTS description_en TEXT,
  ADD COLUMN IF NOT EXISTS description_ar TEXT,
  ADD COLUMN IF NOT EXISTS muscle_groups TEXT[],
  ADD COLUMN IF NOT EXISTS common_mistakes_en TEXT,
  ADD COLUMN IF NOT EXISTS common_mistakes_ar TEXT,
  ADD COLUMN IF NOT EXISTS default_sets INTEGER,
  ADD COLUMN IF NOT EXISTS default_reps VARCHAR(50),
  ADD COLUMN IF NOT EXISTS default_rest_seconds INTEGER,
  ADD COLUMN IF NOT EXISTS location_type VARCHAR(50),
  ADD COLUMN IF NOT EXISTS is_compound BOOLEAN DEFAULT FALSE;

-- Convert single equipment column to array if not already array
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'exercises' AND column_name = 'equipment' AND data_type = 'character varying'
  ) THEN
    ALTER TABLE exercises
      ALTER COLUMN equipment TYPE TEXT[]
      USING CASE
        WHEN equipment IS NULL THEN NULL
        ELSE ARRAY[equipment]
      END;
  END IF;
END$$;

-- Backfill muscle_groups from muscle_group if present
UPDATE exercises
SET muscle_groups = CASE
  WHEN muscle_groups IS NULL AND muscle_group IS NOT NULL THEN ARRAY[muscle_group]
  ELSE muscle_groups
END
WHERE muscle_groups IS NULL AND muscle_group IS NOT NULL;

-- Backfill description_en from description if present
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'exercises' AND column_name = 'description'
  ) THEN
    UPDATE exercises
    SET description_en = COALESCE(description_en, description)
    WHERE description_en IS NULL AND description IS NOT NULL;
  END IF;
END$$;

-- Ensure ex_id is populated for existing rows
UPDATE exercises
SET ex_id = COALESCE(ex_id, id::text)
WHERE ex_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_exercises_ex_id ON exercises(ex_id);
CREATE INDEX IF NOT EXISTS idx_exercises_muscle_groups ON exercises USING GIN (muscle_groups);
CREATE INDEX IF NOT EXISTS idx_exercises_equipment_arr ON exercises USING GIN (equipment);
