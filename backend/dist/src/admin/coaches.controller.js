"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/', async (req, res) => {
    try {
        const coaches = await prisma.coach.findMany({
            include: { user: true }
        });
        res.json(coaches);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch coaches.' });
    }
});
router.put('/:id', async (req, res) => {
    try {
        const { bio, certifications, referralCode } = req.body;
        const coach = await prisma.coach.update({
            where: { id: req.params.id },
            data: { bio, certifications, referralCode }
        });
        res.json(coach);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to update coach.' });
    }
});
router.delete('/:id', async (req, res) => {
    try {
        await prisma.coach.delete({ where: { id: req.params.id } });
        res.json({ message: 'Coach deleted.' });
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to delete coach.' });
    }
});
exports.default = router;
//# sourceMappingURL=coaches.controller.js.map