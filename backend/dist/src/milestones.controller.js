"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/:userId', async (req, res) => {
    try {
        const milestones = await prisma.milestone.findMany({
            where: { userId: req.params.userId },
            orderBy: { achievedAt: 'desc' }
        });
        res.json(milestones);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch milestones.' });
    }
});
router.post('/', async (req, res) => {
    try {
        const { userId, type, description } = req.body;
        const milestone = await prisma.milestone.create({
            data: { userId, type, description }
        });
        res.status(201).json(milestone);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to create milestone.' });
    }
});
exports.default = router;
//# sourceMappingURL=milestones.controller.js.map