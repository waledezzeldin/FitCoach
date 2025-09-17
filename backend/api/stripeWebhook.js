const express = require('express');
const router = express.Router();
const Stripe = require('stripe');
const prisma = require('../prismaClient');
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle payment intent events
  if (event.type === 'payment_intent.succeeded') {
    const paymentIntent = event.data.object;
    await prisma.payment.updateMany({
      where: { transactionId: paymentIntent.id },
      data: { status: 'completed' },
    });
  } else if (event.type === 'payment_intent.payment_failed') {
    const paymentIntent = event.data.object;
    await prisma.payment.updateMany({
      where: { transactionId: paymentIntent.id },
      data: { status: 'failed' },
    });
  }
  // Add more event types as needed

  res.json({ received: true });
});

module.exports = router;