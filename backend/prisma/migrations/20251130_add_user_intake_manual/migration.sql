CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create table to store staged intake data
CREATE TABLE IF NOT EXISTS "UserIntake" (
    "id" TEXT PRIMARY KEY DEFAULT uuid_generate_v4(),
    "userId" TEXT NOT NULL UNIQUE,
    "gender" TEXT,
    "mainGoal" TEXT,
    "workoutLocation" TEXT,
    "firstCompletedAt" TIMESTAMP,
    "age" INTEGER,
    "weightKg" DOUBLE PRECISION,
    "heightCm" DOUBLE PRECISION,
    "experienceLevel" TEXT,
    "workoutFrequency" INTEGER,
    "injuries" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "secondCompletedAt" TIMESTAMP,
    "skippedSecond" BOOLEAN NOT NULL DEFAULT FALSE,
    "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Ensure the timestamp updates on every row change
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS user_intake_updated_at ON "UserIntake";
CREATE TRIGGER user_intake_updated_at
BEFORE UPDATE ON "UserIntake"
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Maintain referential integrity back to users
ALTER TABLE "UserIntake"
    ADD CONSTRAINT "UserIntake_userId_fkey"
    FOREIGN KEY ("userId")
    REFERENCES "User" ("id")
    ON DELETE CASCADE
    ON UPDATE CASCADE;
