"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.post('/onboard', async (req, res) => {
    try {
        const { userId, bio, certifications, referralCode } = req.body;
        const coach = await prisma.coach.create({
            data: { userId, bio, certifications, referralCode }
        });
        res.status(201).json(coach);
    }
    catch (err) {
        res.status(500).json({ error: 'Coach onboarding failed.' });
    }
});
router.get('/:id', async (req, res) => {
    try {
        const coach = await prisma.coach.findUnique({
            where: { id: req.params.id },
            include: { user: true }
        });
        if (!coach) {
            return res.status(404).json({ error: 'Coach not found.' });
        }
        res.json(coach);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch coach profile.' });
    }
});
router.get('/:id/commissions', async (req, res) => {
    try {
        const commissions = await prisma.commission.findMany({
            where: { coachId: req.params.id }
        });
        res.json(commissions);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch commissions.' });
    }
});
exports.default = router;
//# sourceMappingURL=coaches.controller.js.map