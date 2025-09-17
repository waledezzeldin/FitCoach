const express = require('express');
const router = express.Router();
const Stripe = require('stripe');
const prisma = require('../prismaClient'); // your Prisma client
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

router.post('/', async (req, res) => {
  const { userId, orderId, amount, provider } = req.body;
  try {
    if (provider === 'stripe') {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Stripe expects cents
        currency: 'usd',
        metadata: { userId, orderId },
      });
      // Save payment record in DB
      await prisma.payment.create({
        data: {
          userId,
          orderId,
          amount,
          currency: 'USD',
          status: 'pending',
          provider: 'stripe',
          transactionId: paymentIntent.id,
        },
      });
      res.json({ status: 'pending', clientSecret: paymentIntent.client_secret });
    } else {
      // Handle other providers (e.g., STC Pay)
      res.status(400).json({ error: 'Provider not supported yet.' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

const paymentsRouter = require('./api/payments');
app.use('/api/payments', paymentsRouter);