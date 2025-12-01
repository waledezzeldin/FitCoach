"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/orders', async (req, res) => {
    try {
        const userId = req.query.userId || 'USER_ID';
        const orders = await prisma.order.findMany({
            where: { clientId: userId },
            orderBy: { createdAt: 'desc' },
            include: { items: true },
        });
        res.json(orders);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch orders' });
    }
});
router.get('/orders/:id', async (req, res) => {
    try {
        const orderId = req.params.id;
        const order = await prisma.order.findUnique({
            where: { id: orderId },
            include: { items: true },
        });
        if (!order)
            return res.status(404).json({ error: 'Order not found' });
        res.json(order);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch order details' });
    }
});
exports.default = router;
//# sourceMappingURL=orders.controller.js.map