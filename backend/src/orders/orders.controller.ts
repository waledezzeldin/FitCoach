import { Router } from 'express';
import Stripe from 'stripe';
import { PrismaClient } from '@prisma/client';
const router = Router();
const prisma = new PrismaClient();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', { apiVersion: '2022-11-15' });

// POST /v1/orders/create -> create DB order + Stripe PaymentIntent, return client_secret
router.post('/create', async (req, res) => {
  try {
    const { userId, items, currency='usd' } = req.body;
    if (!userId || !items?.length) return res.status(400).json({ error: 'invalid_payload' });

    // compute total
    let total = 0;
    const orderItemsData = [];
    for (const it of items) {
      const prod = await prisma.product.findUnique({ where: { sku: it.sku }});
      const price = prod ? prod.priceCents : (it.priceCents || 0);
      total += price * it.qty;
      orderItemsData.push({ sku: it.sku, qty: it.qty, priceCents: price });
    }

    // create Order
    const order = await prisma.order.create({
      data: {
        userId,
        totalCents: total,
        currency,
        status: 'pending',
        items: { create: orderItemsData },
      },
      include: { items: true },
    });

    // create Stripe PaymentIntent (idempotency: use order.id as idempotency key)
    const pi = await stripe.paymentIntents.create({
      amount: total,
      currency,
      automatic_payment_methods: { enabled: true },
      metadata: { orderId: order.id },
    }, { idempotencyKey: `order_${order.id}` });

    // create Payment record
    await prisma.payment.create({
      data: {
        provider: 'stripe',
        providerId: pi.id,
        orderId: order.id,
        amountCents: total,
        currency,
        status: pi.status,
        raw: pi as any,
      }
    });

    res.json({ orderId: order.id, clientSecret: pi.client_secret });
  } catch (e:any) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

// Cancel order
router.post('/:id/cancel', async (req, res) => {
  try {
    const orderId = req.params.id;
    const order = await prisma.order.update({
      where: { id: orderId },
      data: { status: 'cancelled' }
    });
    // TODO: Integrate with payment provider for refund if needed
    res.json({ success: true, order });
  } catch (err) {
    res.status(500).json({ error: 'Failed to cancel order.' });
  }
});

// Return order
router.post('/:id/return', async (req, res) => {
  try {
    const orderId = req.params.id;
    const order = await prisma.order.update({
      where: { id: orderId },
      data: { status: 'returned' }
    });
    // TODO: Integrate with payment provider for refund if needed
    res.json({ success: true, order });
  } catch (err) {
    res.status(500).json({ error: 'Failed to process return.' });
  }
});

export default router;
