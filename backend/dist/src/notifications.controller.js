"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const push_service_1 = require("./notifications/push.service");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/', async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId)
            return res.status(400).json({ error: 'userId required.' });
        const notifications = await prisma.notification.findMany({
            where: { userId: String(userId) },
            orderBy: { createdAt: 'desc' }
        });
        res.json(notifications);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch notifications.' });
    }
});
router.post('/', async (req, res) => {
    try {
        const { userId, title, message, deviceToken } = req.body;
        const notification = await prisma.notification.create({
            data: { userId, title, message }
        });
        if (deviceToken) {
            await (0, push_service_1.sendPushNotification)(deviceToken, title, message);
        }
        res.status(201).json(notification);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to create notification.' });
    }
});
router.put('/:id/read', async (req, res) => {
    try {
        const notification = await prisma.notification.update({
            where: { id: req.params.id },
            data: { read: true }
        });
        res.json(notification);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to mark notification as read.' });
    }
});
exports.default = router;
//# sourceMappingURL=notifications.controller.js.map