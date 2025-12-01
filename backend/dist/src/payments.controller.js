"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.post('/', async (req, res) => {
    try {
        const { userId, orderId, amount, provider, currency, subscriptionId } = req.body;
        if (req.isDemoMode) {
            const simulated = {
                id: `demo_payment_${Date.now()}`,
                userId,
                orderId,
                subscriptionId,
                amount,
                currency: currency || 'USD',
                status: 'simulated',
                provider,
                createdAt: new Date().toISOString(),
                demo: true,
            };
            return res.status(200).json(simulated);
        }
        const payment = await prisma.payment.create({
            data: {
                userId,
                orderId,
                subscriptionId,
                amount,
                currency: currency || 'USD',
                status: 'pending',
                provider,
            }
        });
        res.status(201).json(payment);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to initiate payment.' });
    }
});
router.get('/:userId', async (req, res) => {
    try {
        const payments = await prisma.payment.findMany({
            where: { userId: req.params.userId },
            orderBy: { createdAt: 'desc' }
        });
        res.json(payments);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch payment history.' });
    }
});
exports.default = router;
//# sourceMappingURL=payments.controller.js.map