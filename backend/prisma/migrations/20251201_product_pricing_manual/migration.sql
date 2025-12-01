-- Manual migration to align Product pricing schema with controller expectations
-- Adds SKU, priceCents, currency, and inventory columns with sane defaults

ALTER TABLE "Product"
    ALTER COLUMN "price" DROP NOT NULL,
    ADD COLUMN IF NOT EXISTS "sku" TEXT,
    ADD COLUMN IF NOT EXISTS "priceCents" INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS "currency" TEXT NOT NULL DEFAULT 'usd',
    ADD COLUMN IF NOT EXISTS "inventory" INTEGER NOT NULL DEFAULT 0;

-- Backfill SKU using existing identifiers when possible
UPDATE "Product"
SET "sku" = COALESCE("sku", CONCAT('SKU-', SUBSTR("id", 1, 12)))
WHERE "sku" IS NULL;

-- If legacy price data exists, translate to cents for consistency
UPDATE "Product"
SET "priceCents" = CASE
    WHEN "price" IS NOT NULL THEN ROUND("price" * 100)
    ELSE "priceCents"
END;

ALTER TABLE "Product"
    ALTER COLUMN "sku" SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "Product_sku_key" ON "Product" ("sku");
