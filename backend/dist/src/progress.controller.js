"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.post('/workout', async (req, res) => {
    try {
        const { userId, date, activity, duration, notes } = req.body;
        const log = await prisma.workoutLog.create({
            data: { userId, date: new Date(date), activity, duration, notes }
        });
        res.status(201).json(log);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to log workout.' });
    }
});
router.post('/nutrition', async (req, res) => {
    try {
        const { userId, date, meal, calories, notes } = req.body;
        const log = await prisma.nutritionLog.create({
            data: { userId, date: new Date(date), meal, calories, notes }
        });
        res.status(201).json(log);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to log nutrition.' });
    }
});
router.post('/supplement', async (req, res) => {
    try {
        const { userId, date, supplementName, dose, notes } = req.body;
        const log = await prisma.supplementLog.create({
            data: { userId, date: new Date(date), supplementName, dose, notes }
        });
        res.status(201).json(log);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to log supplement.' });
    }
});
router.get('/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;
        const workouts = await prisma.workoutLog.findMany({ where: { userId } });
        const nutrition = await prisma.nutritionLog.findMany({ where: { userId } });
        const supplements = await prisma.supplementLog.findMany({ where: { userId } });
        res.json({ workouts, nutrition, supplements });
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch progress logs.' });
    }
});
exports.default = router;
//# sourceMappingURL=progress.controller.js.map