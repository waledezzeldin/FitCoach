import { Router } from 'express';
import Stripe from 'stripe';
const router = Router();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', { apiVersion: '2024-08-01' });

router.post('/stripe', (req, res) => {
  // NOTE: in production verify stripe signature header with raw body
  const event = req.body;
  console.log('stripe webhook', event.type);
  res.json({ received: true });
});

export default router;
