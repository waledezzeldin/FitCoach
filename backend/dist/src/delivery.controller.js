"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/', async (req, res) => {
    try {
        const { orderId } = req.query;
        if (!orderId)
            return res.status(400).json({ error: 'orderId required.' });
        const delivery = await prisma.delivery.findUnique({
            where: { orderId: String(orderId) }
        });
        if (!delivery) {
            return res.status(404).json({ error: 'Delivery info not found.' });
        }
        res.json(delivery);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch delivery info.' });
    }
});
exports.default = router;
//# sourceMappingURL=delivery.controller.js.map