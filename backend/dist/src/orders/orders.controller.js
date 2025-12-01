"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const stripe_1 = require("stripe");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
const stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY || '', { apiVersion: '2022-11-15' });
router.post('/create', async (req, res) => {
    try {
        const { userId, items, currency = 'usd' } = req.body;
        if (!userId || !items?.length)
            return res.status(400).json({ error: 'invalid_payload' });
        let total = 0;
        const orderItemsData = [];
        for (const it of items) {
            const prod = await prisma.product.findUnique({ where: { sku: it.sku } });
            const price = prod ? prod.priceCents : (it.priceCents || 0);
            total += price * it.qty;
            orderItemsData.push({ sku: it.sku, qty: it.qty, priceCents: price });
        }
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
        const pi = await stripe.paymentIntents.create({
            amount: total,
            currency,
            automatic_payment_methods: { enabled: true },
            metadata: { orderId: order.id },
        }, { idempotencyKey: `order_${order.id}` });
        await prisma.payment.create({
            data: {
                userId,
                provider: 'stripe',
                providerId: pi.id,
                orderId: order.id,
                amount: total / 100,
                amountCents: total,
                currency,
                status: pi.status,
                raw: pi,
            },
        });
        res.json({ orderId: order.id, clientSecret: pi.client_secret });
    }
    catch (e) {
        console.error(e);
        res.status(500).json({ error: e.message });
    }
});
router.post('/:id/cancel', async (req, res) => {
    try {
        const orderId = req.params.id;
        const order = await prisma.order.update({
            where: { id: orderId },
            data: { status: 'cancelled' }
        });
        res.json({ success: true, order });
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to cancel order.' });
    }
});
router.post('/:id/return', async (req, res) => {
    try {
        const orderId = req.params.id;
        const order = await prisma.order.update({
            where: { id: orderId },
            data: { status: 'returned' }
        });
        res.json({ success: true, order });
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to process return.' });
    }
});
exports.default = router;
//# sourceMappingURL=orders.controller.js.map