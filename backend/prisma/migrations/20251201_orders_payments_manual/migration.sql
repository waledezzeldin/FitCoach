CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Extend orders with pricing + status metadata
ALTER TABLE "Order"
    ADD COLUMN IF NOT EXISTS "totalCents" INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS "currency" TEXT NOT NULL DEFAULT 'usd',
    ADD COLUMN IF NOT EXISTS "status" TEXT NOT NULL DEFAULT 'pending',
    ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW();

-- Track individual order line items
CREATE TABLE IF NOT EXISTS "OrderItem" (
    "id" TEXT PRIMARY KEY DEFAULT uuid_generate_v4(),
    "orderId" TEXT NOT NULL,
    "sku" TEXT NOT NULL,
    "qty" INTEGER NOT NULL DEFAULT 1,
    "priceCents" INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT "OrderItem_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE CASCADE
);

-- Reuse generic updated_at trigger helper
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS order_updated_at ON "Order";
CREATE TRIGGER order_updated_at
BEFORE UPDATE ON "Order"
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Enrich payments with metadata coming from Stripe
ALTER TABLE "Payment"
    ALTER COLUMN "amount" DROP NOT NULL,
    ADD COLUMN IF NOT EXISTS "amountCents" INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS "providerId" TEXT,
    ADD COLUMN IF NOT EXISTS "raw" JSONB;

CREATE UNIQUE INDEX IF NOT EXISTS "Payment_providerId_key" ON "Payment" ("providerId") WHERE "providerId" IS NOT NULL;

-- Persist raw webhook events for idempotency
CREATE TABLE IF NOT EXISTS "WebhookEvent" (
    "id" TEXT PRIMARY KEY DEFAULT uuid_generate_v4(),
    "provider" TEXT NOT NULL,
    "eventId" TEXT NOT NULL UNIQUE,
    "payload" JSONB NOT NULL,
    "processed" BOOLEAN NOT NULL DEFAULT FALSE,
    "createdAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Store subscription state mirrored from Stripe
ALTER TABLE "Subscription"
    ADD COLUMN IF NOT EXISTS "stripeSubscriptionId" TEXT,
    ADD COLUMN IF NOT EXISTS "status" TEXT NOT NULL DEFAULT 'inactive',
    ADD COLUMN IF NOT EXISTS "currentPeriodEnd" TIMESTAMP,
    ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW();

CREATE UNIQUE INDEX IF NOT EXISTS "Subscription_stripeSubscriptionId_key"
ON "Subscription" ("stripeSubscriptionId") WHERE "stripeSubscriptionId" IS NOT NULL;
