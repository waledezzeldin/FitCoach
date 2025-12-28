const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const paymentController = require('../controllers/paymentController');

// Payment routes (require authentication)
router.post('/create-checkout', authMiddleware, paymentController.createCheckout);
router.post('/upgrade', authMiddleware, paymentController.upgradeSubscription);
router.post('/cancel', authMiddleware, paymentController.cancelSubscription);
router.get('/subscription', authMiddleware, paymentController.getSubscription);
router.get('/history', authMiddleware, paymentController.getPaymentHistory);
router.get('/invoice/:paymentId', authMiddleware, paymentController.generateInvoice);

// Webhook routes (NO authentication - webhooks come from payment providers)
router.post('/webhook/stripe', express.raw({ type: 'application/json' }), paymentController.stripeWebhook);
router.post('/webhook/tap', express.json(), paymentController.tapWebhook);

module.exports = router;
