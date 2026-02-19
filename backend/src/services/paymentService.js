const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const axios = require('axios');
const db = require('../database');
const logger = require('../utils/logger');
const { isBypassEnabled } = require('../utils/featureFlags');

/**
 * Payment Service
 * Handles both Stripe (international) and Tap Payments (Saudi Arabia)
 */

// Payment provider enum
const PROVIDERS = {
  STRIPE: 'stripe',
  TAP: 'tap'
};

// Subscription tier pricing (in SAR and USD)
const TIER_PRICING = {
  freemium: {
    sar: 0,
    usd: 0,
    monthly_sar: 0,
    monthly_usd: 0
  },
  premium: {
    sar: 299, // 299 SAR/month
    usd: 79, // $79/month
    monthly_sar: 299,
    monthly_usd: 79,
    yearly_sar: 2999, // ~16% discount
    yearly_usd: 799
  },
  smart_premium: {
    sar: 499, // 499 SAR/month
    usd: 133, // $133/month
    monthly_sar: 499,
    monthly_usd: 133,
    yearly_sar: 4999, // ~16% discount
    yearly_usd: 1333
  }
};

/**
 * Create Stripe checkout session
 */
exports.createStripeCheckout = async (userId, tier, billingCycle = 'monthly') => {
  try {
    const user = await db.query(
      'SELECT email, full_name FROM users WHERE id = $1',
      [userId]
    );

    if (user.rows.length === 0) {
      throw new Error('User not found');
    }

    const userData = user.rows[0];
    const pricing = TIER_PRICING[tier];

    if (!pricing) {
      throw new Error('Invalid subscription tier');
    }

    const amount = billingCycle === 'yearly' ? pricing.yearly_usd : pricing.monthly_usd;
    if (isBypassEnabled('BYPASS_STRIPE')) {
      const sessionId = `bypass_stripe_${Date.now()}`;
      const checkoutUrl = `${process.env.FRONTEND_URL}/payment/success?provider=stripe&bypass=1`;

      logger.info(`Stripe bypass enabled, returning mock checkout for user ${userId}`);

      await db.query(
        `INSERT INTO payment_transactions (
          user_id, provider, amount, currency, status, tier, billing_cycle,
          external_payment_id, checkout_url
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [userId, PROVIDERS.STRIPE, amount, 'usd', 'pending', tier, billingCycle, sessionId, checkoutUrl]
      );

      return {
        sessionId,
        checkoutUrl,
        bypassed: true
      };
    }

    const session = await stripe.checkout.sessions.create({
      customer_email: userData.email,
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: `عاش ${tier} - ${billingCycle}`,
              description: `${tier} subscription (${billingCycle} billing)`,
            },
            unit_amount: amount * 100, // Stripe expects cents
            recurring: {
              interval: billingCycle === 'yearly' ? 'year' : 'month',
            },
          },
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: `${process.env.FRONTEND_URL}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.FRONTEND_URL}/payment/cancelled`,
      metadata: {
        userId: userId,
        tier: tier,
        billingCycle: billingCycle,
        provider: PROVIDERS.STRIPE
      },
    });

    // Store pending payment
    await db.query(
      `INSERT INTO payment_transactions (
        user_id, provider, amount, currency, status, tier, billing_cycle, 
        external_payment_id, checkout_url
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [userId, PROVIDERS.STRIPE, amount, 'usd', 'pending', tier, billingCycle, session.id, session.url]
    );

    return {
      sessionId: session.id,
      checkoutUrl: session.url
    };

  } catch (error) {
    logger.error('Stripe checkout creation error:', error);
    throw error;
  }
};

/**
 * Create Tap Payments checkout (for Saudi Arabia)
 */
exports.createTapCheckout = async (userId, tier, billingCycle = 'monthly') => {
  try {
    const user = await db.query(
      'SELECT email, full_name, phone_number FROM users WHERE id = $1',
      [userId]
    );

    if (user.rows.length === 0) {
      throw new Error('User not found');
    }

    const userData = user.rows[0];
    const pricing = TIER_PRICING[tier];

    if (!pricing) {
      throw new Error('Invalid subscription tier');
    }

    const amount = billingCycle === 'yearly' ? pricing.yearly_sar : pricing.monthly_sar;
    if (isBypassEnabled('BYPASS_TAP')) {
      const chargeId = `bypass_tap_${Date.now()}`;
      const checkoutUrl = `${process.env.FRONTEND_URL}/payment/success?provider=tap&bypass=1`;

      logger.info(`Tap bypass enabled, returning mock checkout for user ${userId}`);

      await db.query(
        `INSERT INTO payment_transactions (
          user_id, provider, amount, currency, status, tier, billing_cycle,
          external_payment_id, checkout_url
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [userId, PROVIDERS.TAP, amount, 'sar', 'pending', tier, billingCycle, chargeId, checkoutUrl]
      );

      return {
        chargeId,
        checkoutUrl,
        bypassed: true
      };
    }

    // Tap Payments API
    const tapResponse = await axios.post(
      'https://api.tap.company/v2/charges',
      {
        amount: amount,
        currency: 'SAR',
        threeDSecure: true,
        save_card: false,
        description: `عاش ${tier} - ${billingCycle}`,
        statement_descriptor: 'عاش Subscription',
        metadata: {
          userId: userId,
          tier: tier,
          billingCycle: billingCycle,
          provider: PROVIDERS.TAP
        },
        reference: {
          transaction: `sub_${userId}_${Date.now()}`,
          order: `order_${userId}_${tier}`
        },
        receipt: {
          email: true,
          sms: true
        },
        customer: {
          first_name: userData.full_name.split(' ')[0] || 'User',
          last_name: userData.full_name.split(' ').slice(1).join(' ') || '',
          email: userData.email,
          phone: {
            country_code: '966',
            number: userData.phone_number.replace('+966', '')
          }
        },
        source: {
          id: 'src_all'
        },
        redirect: {
          url: `${process.env.FRONTEND_URL}/payment/callback`
        }
      },
      {
        headers: {
          'Authorization': `Bearer ${process.env.TAP_SECRET_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    const charge = tapResponse.data;

    // Store pending payment
    await db.query(
      `INSERT INTO payment_transactions (
        user_id, provider, amount, currency, status, tier, billing_cycle, 
        external_payment_id, checkout_url
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [userId, PROVIDERS.TAP, amount, 'sar', 'pending', tier, billingCycle, charge.id, charge.transaction.url]
    );

    return {
      chargeId: charge.id,
      checkoutUrl: charge.transaction.url
    };

  } catch (error) {
    logger.error('Tap checkout creation error:', error);
    throw error;
  }
};

/**
 * Handle Stripe webhook
 */
exports.handleStripeWebhook = async (event) => {
  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleStripeCheckoutCompleted(event.data.object);
        break;
      
      case 'invoice.payment_succeeded':
        await handleStripePaymentSucceeded(event.data.object);
        break;
      
      case 'invoice.payment_failed':
        await handleStripePaymentFailed(event.data.object);
        break;
      
      case 'customer.subscription.deleted':
        await handleStripeSubscriptionCancelled(event.data.object);
        break;
      
      default:
        logger.info(`Unhandled Stripe event: ${event.type}`);
    }
  } catch (error) {
    logger.error('Stripe webhook handling error:', error);
    throw error;
  }
};

/**
 * Handle Tap webhook
 */
exports.handleTapWebhook = async (payload) => {
  try {
    const { id, status, metadata } = payload;

    if (status === 'CAPTURED') {
      // Payment successful
      const { userId, tier, billingCycle } = metadata;
      await activateSubscription(userId, tier, billingCycle, PROVIDERS.TAP, id);
    } else if (status === 'FAILED') {
      // Payment failed
      await db.query(
        `UPDATE payment_transactions 
         SET status = 'failed', updated_at = NOW()
         WHERE external_payment_id = $1`,
        [id]
      );
    }
  } catch (error) {
    logger.error('Tap webhook handling error:', error);
    throw error;
  }
};

/**
 * Activate subscription after successful payment
 */
async function activateSubscription(userId, tier, billingCycle, provider, externalPaymentId) {
  const client = await db.pool.connect();
  
  try {
    await client.query('BEGIN');

    // Update user subscription
    const subscriptionEndDate = new Date();
    if (billingCycle === 'yearly') {
      subscriptionEndDate.setFullYear(subscriptionEndDate.getFullYear() + 1);
    } else {
      subscriptionEndDate.setMonth(subscriptionEndDate.getMonth() + 1);
    }

    await client.query(
      `UPDATE users 
       SET subscription_tier = $1,
           subscription_start_date = NOW(),
           subscription_end_date = $2,
           subscription_status = 'active',
           updated_at = NOW()
       WHERE id = $3`,
      [tier, subscriptionEndDate, userId]
    );

    // Update payment transaction
    await client.query(
      `UPDATE payment_transactions 
       SET status = 'completed', 
           completed_at = NOW(),
           updated_at = NOW()
       WHERE external_payment_id = $1`,
      [externalPaymentId]
    );

    // Reset monthly quotas
    await client.query(
      `UPDATE user_quotas
       SET messages_used = 0,
           calls_used = 0,
           last_reset = NOW()
       WHERE user_id = $1`,
      [userId]
    );

    await client.query('COMMIT');

    logger.info(`Subscription activated for user ${userId}: ${tier} (${billingCycle})`);

  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * Helper: Handle Stripe checkout completed
 */
async function handleStripeCheckoutCompleted(session) {
  const { metadata } = session;
  await activateSubscription(
    metadata.userId,
    metadata.tier,
    metadata.billingCycle,
    PROVIDERS.STRIPE,
    session.id
  );
}

/**
 * Helper: Handle Stripe payment succeeded
 */
async function handleStripePaymentSucceeded(invoice) {
  const subscriptionId = invoice.subscription;
  const customerId = invoice.customer;

  // Update subscription renewal
  logger.info(`Subscription renewed for Stripe customer: ${customerId}`);
}

/**
 * Helper: Handle Stripe payment failed
 */
async function handleStripePaymentFailed(invoice) {
  const subscriptionId = invoice.subscription;
  
  // Mark subscription as payment_failed
  await db.query(
    `UPDATE users 
     SET subscription_status = 'payment_failed'
     WHERE stripe_subscription_id = $1`,
    [subscriptionId]
  );

  logger.warn(`Payment failed for Stripe subscription: ${subscriptionId}`);
}

/**
 * Helper: Handle Stripe subscription cancelled
 */
async function handleStripeSubscriptionCancelled(subscription) {
  await db.query(
    `UPDATE users 
     SET subscription_status = 'cancelled',
         subscription_tier = 'freemium'
     WHERE stripe_subscription_id = $1`,
    [subscription.id]
  );

  logger.info(`Subscription cancelled: ${subscription.id}`);
}

/**
 * Cancel subscription
 */
exports.cancelSubscription = async (userId) => {
  try {
    const user = await db.query(
      'SELECT subscription_tier, stripe_subscription_id FROM users WHERE id = $1',
      [userId]
    );

    if (user.rows.length === 0) {
      throw new Error('User not found');
    }

    const { stripe_subscription_id } = user.rows[0];

    if (stripe_subscription_id && !isBypassEnabled('BYPASS_STRIPE')) {
      // Cancel Stripe subscription
      await stripe.subscriptions.update(stripe_subscription_id, {
        cancel_at_period_end: true
      });
    } else if (stripe_subscription_id) {
      logger.info(`Stripe bypass enabled, skipping Stripe cancel API for user ${userId}`);
    }

    // Update user status
    await db.query(
      `UPDATE users 
       SET subscription_status = 'cancelled'
       WHERE id = $1`,
      [userId]
    );

    return {
      success: true,
      message: 'Subscription will be cancelled at the end of the billing period'
    };

  } catch (error) {
    logger.error('Cancel subscription error:', error);
    throw error;
  }
};

/**
 * Get payment history
 */
exports.getPaymentHistory = async (userId) => {
  try {
    const result = await db.query(
      `SELECT 
        id,
        provider,
        amount,
        currency,
        status,
        tier,
        billing_cycle,
        created_at,
        completed_at
       FROM payment_transactions
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );

    return result.rows;
  } catch (error) {
    logger.error('Get payment history error:', error);
    throw error;
  }
};

/**
 * Get subscription status
 */
exports.getSubscriptionStatus = async (userId) => {
  try {
    const result = await db.query(
      `SELECT 
        subscription_tier,
        subscription_status,
        subscription_start_date,
        subscription_end_date
       FROM users
       WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      throw new Error('User not found');
    }

    const subscription = result.rows[0];
    const now = new Date();
    const endDate = new Date(subscription.subscription_end_date);
    const daysRemaining = Math.ceil((endDate - now) / (1000 * 60 * 60 * 24));

    return {
      tier: subscription.subscription_tier,
      status: subscription.subscription_status,
      startDate: subscription.subscription_start_date,
      endDate: subscription.subscription_end_date,
      daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
      isActive: subscription.subscription_status === 'active' && daysRemaining > 0
    };
  } catch (error) {
    logger.error('Get subscription status error:', error);
    throw error;
  }
};

module.exports = exports;
