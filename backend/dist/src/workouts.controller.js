"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const injury_map_1 = require("./workouts/injury-map");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
router.get('/alternatives', (req, res) => {
    const injuryArea = typeof req.query.injuryArea === 'string' ? req.query.injuryArea : undefined;
    const muscleGroup = typeof req.query.muscleGroup === 'string' ? req.query.muscleGroup : undefined;
    if (!injuryArea) {
        return res.status(400).json({ error: 'injuryArea is required' });
    }
    const alternatives = (0, injury_map_1.getAlternativesForInjury)(injuryArea, muscleGroup);
    res.json({ alternatives });
});
router.post('/swaps', async (req, res) => {
    const { sessionId, userId, originalExerciseId, alternativeExerciseId, injuryArea } = req.body;
    if (!userId || !originalExerciseId || !alternativeExerciseId) {
        return res.status(400).json({ error: 'userId, originalExerciseId, and alternativeExerciseId are required.' });
    }
    try {
        await prisma.workoutLog.create({
            data: {
                userId,
                date: new Date(),
                activity: 'swap',
                duration: 0,
                notes: JSON.stringify({
                    sessionId,
                    originalExerciseId,
                    alternativeExerciseId,
                    injuryArea,
                }),
            },
        });
        res.status(201).json({ success: true });
    }
    catch (err) {
        console.error('Failed to record workout swap', err);
        res.status(500).json({ error: 'Failed to record swap.' });
    }
});
exports.default = router;
//# sourceMappingURL=workouts.controller.js.map