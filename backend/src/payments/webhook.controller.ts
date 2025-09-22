import { Router } from 'express';
import Stripe from 'stripe';
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
const router = Router();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', { apiVersion: '2022-11-15' });

router.post('/stripe', async (req, res) => {
  const sig = req.headers['stripe-signature'] as string | undefined;
  let event: Stripe.Event;
  try {
    if (!sig || !process.env.STRIPE_WEBHOOK_SECRET) {
      // fallback without signature (dev)
      event = req.body;
    } else {
      event = stripe.webhooks.constructEvent((req as any).rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET);
    }
  } catch (err:any) {
    console.error('Webhook signature error', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Idempotency: store event id
  const existing = await prisma.webhookEvent.findUnique({ where: { eventId: event.id }});
  if (existing && existing.processed) {
    return res.json({ received: true });
  }
  if (!existing) {
    await prisma.webhookEvent.create({ data: { provider: 'stripe', eventId: event.id, payload: event as any, processed: false }});
  }

  // handle events
  try {
    if (event.type === 'payment_intent.succeeded') {
      const pi = event.data.object as Stripe.PaymentIntent;
      // update payment row
      const pay = await prisma.payment.findUnique({ where: { providerId: pi.id }});
      if (pay && pay.status !== 'succeeded') {
        await prisma.payment.update({ where: { id: pay.id }, data: { status: 'succeeded', raw: pi as any }});
        // mark order paid if metadata.orderId exists
        const orderId = pi.metadata?.orderId;
        if (orderId) {
          await prisma.order.update({ where: { id: orderId }, data: { status: 'paid', paymentId: pi.id }});
        }
      }
    } else if (event.type === 'invoice.payment_succeeded') {
      const inv = event.data.object as Stripe.Invoice;
      const stripeSubId = inv.subscription as string;
      if (stripeSubId) {
        await prisma.subscription.updateMany({
          where: { stripeSubscriptionId: stripeSubId },
          data: { 
            status: 'active', 
            currentPeriodEnd: inv.lines?.data?.[0]?.period?.end 
              ? new Date(inv.lines.data[0].period.end * 1000) 
              : undefined 
          }
        });
      }
    }

    // mark event processed
    await prisma.webhookEvent.updateMany({ where: { eventId: event.id }, data: { processed: true }});
    res.json({ received: true });
  } catch (e:any) {
    console.error('processing webhook error', e.message);
    res.status(500).json({ error: e.message });
  }
});

export default router;
