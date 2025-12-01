"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const stripe_1 = require("stripe");
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const router = (0, express_1.Router)();
const stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY || '', { apiVersion: '2022-11-15' });
router.post('/stripe', async (req, res) => {
    const sig = req.headers['stripe-signature'];
    let event;
    try {
        if (!sig || !process.env.STRIPE_WEBHOOK_SECRET) {
            event = req.body;
        }
        else {
            event = stripe.webhooks.constructEvent(req.rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET);
        }
    }
    catch (err) {
        console.error('Webhook signature error', err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }
    const existing = await prisma.webhookEvent.findUnique({ where: { eventId: event.id } });
    if (existing && existing.processed) {
        return res.json({ received: true });
    }
    if (!existing) {
        await prisma.webhookEvent.create({ data: { provider: 'stripe', eventId: event.id, payload: event, processed: false } });
    }
    try {
        if (event.type === 'payment_intent.succeeded') {
            const pi = event.data.object;
            const pay = await prisma.payment.findUnique({ where: { providerId: pi.id } });
            if (pay && pay.status !== 'succeeded') {
                await prisma.payment.update({ where: { id: pay.id }, data: { status: 'succeeded', raw: pi } });
                const orderId = pi.metadata?.orderId;
                if (orderId) {
                    await prisma.order.update({ where: { id: orderId }, data: { status: 'paid' } });
                }
            }
        }
        else if (event.type === 'invoice.payment_succeeded') {
            const inv = event.data.object;
            const stripeSubId = inv.subscription;
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
        await prisma.webhookEvent.updateMany({ where: { eventId: event.id }, data: { processed: true } });
        res.json({ received: true });
    }
    catch (e) {
        console.error('processing webhook error', e.message);
        res.status(500).json({ error: e.message });
    }
});
exports.default = router;
//# sourceMappingURL=webhook.controller.js.map