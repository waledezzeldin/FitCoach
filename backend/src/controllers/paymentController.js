const paymentService = require('../services/paymentService');
const logger = require('../utils/logger');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const crypto = require('crypto');

const normalizeSignature = (signature) => {
  if (!signature || typeof signature !== 'string') return '';
  return signature.trim().replace(/^sha256=/i, '');
};

const matchesTapSignature = (rawPayload, signature, secret) => {
  if (!signature || !secret) return false;

  const expectedHex = crypto
    .createHmac('sha256', secret)
    .update(rawPayload)
    .digest('hex');
  const expectedBase64 = crypto
    .createHmac('sha256', secret)
    .update(rawPayload)
    .digest('base64');

  const provided = normalizeSignature(signature);
  return [expectedHex, expectedBase64].some((candidate) => {
    const candidateNormalized = normalizeSignature(candidate);
    if (candidateNormalized.length !== provided.length) return false;
    return crypto.timingSafeEqual(
      Buffer.from(candidateNormalized),
      Buffer.from(provided)
    );
  });
};

/**
 * Payment Controller
 * Handles payment operations and webhooks
 */

/**
 * Create checkout session (Stripe or Tap)
 */
exports.createCheckout = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { tier, billingCycle = 'monthly', provider = 'stripe' } = req.body;

    // Validate tier
    const validTiers = ['premium', 'smart_premium'];
    if (!validTiers.includes(tier)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid subscription tier'
      });
    }

    // Validate billing cycle
    if (!['monthly', 'yearly'].includes(billingCycle)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid billing cycle'
      });
    }

    let checkoutData;

    if (provider === 'tap') {
      // Tap Payments (Saudi Arabia)
      checkoutData = await paymentService.createTapCheckout(userId, tier, billingCycle);
    } else {
      // Stripe (International)
      checkoutData = await paymentService.createStripeCheckout(userId, tier, billingCycle);
    }

    res.json({
      success: true,
      checkout: checkoutData
    });

  } catch (error) {
    logger.error('Create checkout error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create checkout session'
    });
  }
};

/**
 * Stripe webhook handler
 */
exports.stripeWebhook = async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    logger.error('Stripe webhook signature verification failed:', err);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    await paymentService.handleStripeWebhook(event);
    res.json({ received: true });
  } catch (error) {
    logger.error('Stripe webhook handling error:', error);
    res.status(500).json({ error: 'Webhook handling failed' });
  }
};

/**
 * Tap Payments webhook handler
 */
exports.tapWebhook = async (req, res) => {
  try {
    const payload = req.body;
    const tapSignature = req.headers['tap-signature'] || req.headers['x-tap-signature'];
    const webhookSecret = process.env.TAP_WEBHOOK_SECRET || process.env.TAP_SECRET_KEY;
    const rawPayload = req.rawBody || JSON.stringify(payload || {});

    if (!webhookSecret) {
      logger.error('Tap webhook secret is not configured');
      return res.status(500).json({ error: 'Webhook secret not configured' });
    }

    if (!matchesTapSignature(rawPayload, tapSignature, webhookSecret)) {
      logger.warn('Tap webhook signature verification failed');
      return res.status(401).json({ error: 'Invalid webhook signature' });
    }

    await paymentService.handleTapWebhook(payload);
    
    res.json({ received: true });
  } catch (error) {
    logger.error('Tap webhook handling error:', error);
    res.status(500).json({ error: 'Webhook handling failed' });
  }
};

/**
 * Get subscription status
 */
exports.getSubscription = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const subscription = await paymentService.getSubscriptionStatus(userId);

    res.json({
      success: true,
      subscription
    });

  } catch (error) {
    logger.error('Get subscription error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get subscription status'
    });
  }
};

/**
 * Cancel subscription
 */
exports.cancelSubscription = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await paymentService.cancelSubscription(userId);

    res.json({
      success: true,
      message: result.message
    });

  } catch (error) {
    logger.error('Cancel subscription error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to cancel subscription'
    });
  }
};

/**
 * Get payment history
 */
exports.getPaymentHistory = async (req, res) => {
  try {
    const userId = req.user.userId;

    const history = await paymentService.getPaymentHistory(userId);

    res.json({
      success: true,
      payments: history
    });

  } catch (error) {
    logger.error('Get payment history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get payment history'
    });
  }
};

/**
 * Upgrade subscription
 */
exports.upgradeSubscription = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { newTier, billingCycle = 'monthly', provider = 'stripe' } = req.body;

    // Validate new tier
    if (!['premium', 'smart_premium'].includes(newTier)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid subscription tier'
      });
    }

    // Create new checkout for upgraded tier
    let checkoutData;

    if (provider === 'tap') {
      checkoutData = await paymentService.createTapCheckout(userId, newTier, billingCycle);
    } else {
      checkoutData = await paymentService.createStripeCheckout(userId, newTier, billingCycle);
    }

    res.json({
      success: true,
      checkout: checkoutData,
      message: 'Upgrade checkout created. Complete payment to activate new tier.'
    });

  } catch (error) {
    logger.error('Upgrade subscription error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to upgrade subscription'
    });
  }
};

/**
 * Generate invoice (for completed payments)
 */
exports.generateInvoice = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { paymentId } = req.params;

    // Get payment details
    const payment = await db.query(
      `SELECT 
        pt.*,
        u.full_name,
        u.email,
        u.phone_number
       FROM payment_transactions pt
       JOIN users u ON pt.user_id = u.id
       WHERE pt.id = $1 AND pt.user_id = $2`,
      [paymentId, userId]
    );

    if (payment.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    const paymentData = payment.rows[0];

    // Generate invoice data
    const invoice = {
      invoiceNumber: `INV-${paymentData.id.substring(0, 8).toUpperCase()}`,
      date: paymentData.completed_at || paymentData.created_at,
      customer: {
        name: paymentData.full_name,
        email: paymentData.email,
        phone: paymentData.phone_number
      },
      items: [
        {
          description: `عاش ${paymentData.tier} Subscription (${paymentData.billing_cycle})`,
          amount: paymentData.amount,
          currency: paymentData.currency.toUpperCase()
        }
      ],
      total: paymentData.amount,
      currency: paymentData.currency.toUpperCase(),
      status: paymentData.status
    };

    res.json({
      success: true,
      invoice
    });

  } catch (error) {
    logger.error('Generate invoice error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate invoice'
    });
  }
};

module.exports = exports;
