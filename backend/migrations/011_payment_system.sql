-- Migration 011: Payment System
-- Complete payment integration with Stripe and Tap Payments

-- Create payment transactions table
CREATE TABLE IF NOT EXISTS payment_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider VARCHAR(20) NOT NULL CHECK (provider IN ('stripe', 'tap')),
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) NOT NULL CHECK (currency IN ('usd', 'sar', 'USD', 'SAR')),
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded', 'cancelled')),
  tier VARCHAR(20) NOT NULL CHECK (tier IN ('premium', 'smart_premium')),
  billing_cycle VARCHAR(10) NOT NULL CHECK (billing_cycle IN ('monthly', 'yearly')),
  external_payment_id VARCHAR(255), -- Stripe session ID or Tap charge ID
  checkout_url TEXT,
  invoice_url TEXT,
  refund_id VARCHAR(255),
  refund_amount DECIMAL(10, 2),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_payment_transactions_user ON payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_status ON payment_transactions(status);
CREATE INDEX idx_payment_transactions_external_id ON payment_transactions(external_payment_id);
CREATE INDEX idx_payment_transactions_created ON payment_transactions(created_at DESC);

-- Add payment-related columns to users table (if not exists)
ALTER TABLE users ADD COLUMN IF NOT EXISTS stripe_customer_id VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS stripe_subscription_id VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS tap_customer_id VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_status VARCHAR(20) DEFAULT 'active' 
  CHECK (subscription_status IN ('active', 'cancelled', 'expired', 'payment_failed'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP;
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP;

-- Create indexes on new user columns
CREATE INDEX IF NOT EXISTS idx_users_stripe_customer ON users(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_users_subscription_status ON users(subscription_status);
CREATE INDEX IF NOT EXISTS idx_users_subscription_end ON users(subscription_end_date);

-- Create payment webhooks log table (for debugging)
CREATE TABLE IF NOT EXISTS payment_webhook_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider VARCHAR(20) NOT NULL,
  event_type VARCHAR(100),
  event_id VARCHAR(255),
  payload JSONB NOT NULL,
  processed BOOLEAN DEFAULT false,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_webhook_logs_provider ON payment_webhook_logs(provider);
CREATE INDEX idx_webhook_logs_processed ON payment_webhook_logs(processed);
CREATE INDEX idx_webhook_logs_created ON payment_webhook_logs(created_at DESC);

-- Create subscription history table
CREATE TABLE IF NOT EXISTS subscription_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  from_tier VARCHAR(20),
  to_tier VARCHAR(20) NOT NULL,
  action VARCHAR(20) NOT NULL CHECK (action IN ('upgrade', 'downgrade', 'cancel', 'renew', 'expire')),
  effective_date TIMESTAMP DEFAULT NOW(),
  payment_transaction_id UUID REFERENCES payment_transactions(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_subscription_history_user ON subscription_history(user_id);
CREATE INDEX idx_subscription_history_date ON subscription_history(effective_date DESC);

-- Create refunds table
CREATE TABLE IF NOT EXISTS payment_refunds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_transaction_id UUID NOT NULL REFERENCES payment_transactions(id),
  user_id UUID NOT NULL REFERENCES users(id),
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) NOT NULL,
  reason TEXT,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
  external_refund_id VARCHAR(255),
  processed_by UUID REFERENCES users(id), -- Admin who processed refund
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);

CREATE INDEX idx_refunds_transaction ON payment_refunds(payment_transaction_id);
CREATE INDEX idx_refunds_user ON payment_refunds(user_id);
CREATE INDEX idx_refunds_status ON payment_refunds(status);

-- Function to automatically update subscription history
CREATE OR REPLACE FUNCTION log_subscription_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.subscription_tier != NEW.subscription_tier THEN
    INSERT INTO subscription_history (user_id, from_tier, to_tier, action)
    VALUES (
      NEW.id,
      OLD.subscription_tier,
      NEW.subscription_tier,
      CASE 
        WHEN NEW.subscription_tier = 'freemium' THEN 'cancel'
        WHEN OLD.subscription_tier = 'freemium' THEN 'upgrade'
        WHEN NEW.subscription_tier > OLD.subscription_tier THEN 'upgrade'
        ELSE 'downgrade'
      END
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for subscription changes
DROP TRIGGER IF EXISTS trigger_log_subscription_change ON users;
CREATE TRIGGER trigger_log_subscription_change
  AFTER UPDATE OF subscription_tier ON users
  FOR EACH ROW
  WHEN (OLD.subscription_tier IS DISTINCT FROM NEW.subscription_tier)
  EXECUTE FUNCTION log_subscription_change();

-- Function to check expired subscriptions (run daily via cron)
CREATE OR REPLACE FUNCTION expire_old_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE users
  SET subscription_tier = 'freemium',
      subscription_status = 'expired'
  WHERE subscription_end_date < NOW()
    AND subscription_status = 'active'
    AND subscription_tier != 'freemium';
END;
$$ LANGUAGE plpgsql;

-- Update timestamp trigger for payment_transactions
CREATE OR REPLACE FUNCTION update_payment_transactions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_payment_transactions_updated_at
  BEFORE UPDATE ON payment_transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_payment_transactions_updated_at();

-- Comments
COMMENT ON TABLE payment_transactions IS 'All payment transactions (Stripe and Tap)';
COMMENT ON TABLE subscription_history IS 'Audit log of subscription tier changes';
COMMENT ON TABLE payment_webhook_logs IS 'Log of all payment webhook events for debugging';
COMMENT ON TABLE payment_refunds IS 'Refund requests and processing';

COMMENT ON COLUMN payment_transactions.provider IS 'Payment provider: stripe or tap';
COMMENT ON COLUMN payment_transactions.external_payment_id IS 'Stripe session ID or Tap charge ID';
COMMENT ON COLUMN users.subscription_status IS 'Current status: active, cancelled, expired, payment_failed';
COMMENT ON COLUMN users.stripe_subscription_id IS 'Stripe subscription ID for recurring billing';

-- Insert sample pricing data (for reference)
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('pricing_premium_monthly_sar', '299', 'Premium tier monthly price in SAR'),
('pricing_premium_monthly_usd', '79', 'Premium tier monthly price in USD'),
('pricing_premium_yearly_sar', '2999', 'Premium tier yearly price in SAR (discounted)'),
('pricing_premium_yearly_usd', '799', 'Premium tier yearly price in USD (discounted)'),
('pricing_smart_premium_monthly_sar', '499', 'Smart Premium tier monthly price in SAR'),
('pricing_smart_premium_monthly_usd', '133', 'Smart Premium tier monthly price in USD'),
('pricing_smart_premium_yearly_sar', '4999', 'Smart Premium tier yearly price in SAR (discounted)'),
('pricing_smart_premium_yearly_usd', '1333', 'Smart Premium tier yearly price in USD (discounted)')
ON CONFLICT (setting_key) DO NOTHING;

-- Create system_settings table if it doesn't exist
CREATE TABLE IF NOT EXISTS system_settings (
  id SERIAL PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
