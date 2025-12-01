CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

ALTER TABLE "Session"
    ADD COLUMN IF NOT EXISTS "coachId" TEXT,
    ADD COLUMN IF NOT EXISTS "scheduledAt" TIMESTAMP,
    ADD COLUMN IF NOT EXISTS "durationMin" INTEGER NOT NULL DEFAULT 30,
    ADD COLUMN IF NOT EXISTS "status" TEXT NOT NULL DEFAULT 'scheduled',
    ADD COLUMN IF NOT EXISTS "agoraChannel" TEXT,
    ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW();

UPDATE "Session"
SET "scheduledAt" = COALESCE("scheduledAt", "createdAt")
WHERE "scheduledAt" IS NULL;

ALTER TABLE "Session"
    ALTER COLUMN "scheduledAt" SET NOT NULL;

ALTER TABLE "Session"
    ADD CONSTRAINT IF NOT EXISTS "Session_coachId_fkey"
    FOREIGN KEY ("coachId") REFERENCES "Coach" ("id") ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS session_updated_at ON "Session";
CREATE TRIGGER session_updated_at
BEFORE UPDATE ON "Session"
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
