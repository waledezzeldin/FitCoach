"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/:userId', async (req, res) => {
    try {
        const subscription = await prisma.subscription.findMany({
            where: { userId: req.params.userId },
            orderBy: { startDate: 'desc' }
        });
        res.json(subscription);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch subscription.' });
    }
});
router.post('/', async (req, res) => {
    try {
        const { userId, type, startDate, endDate, isActive, paymentId } = req.body;
        const subscription = await prisma.subscription.create({
            data: {
                userId,
                type,
                startDate: new Date(startDate),
                endDate: new Date(endDate),
                isActive,
                paymentId
            }
        });
        res.status(201).json(subscription);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to create subscription.' });
    }
});
exports.default = router;
//# sourceMappingURL=subscription.controller.js.map