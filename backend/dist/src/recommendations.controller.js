"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const openai_1 = require("openai");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
const openai = process.env.OPENAI_API_KEY ? new openai_1.OpenAI({ apiKey: process.env.OPENAI_API_KEY }) : null;
router.post('/', async (req, res) => {
    try {
        const { userId, goals, coachInput } = req.body;
        if (!openai) {
            return res.status(503).json({ error: 'OpenAI API key is not configured.' });
        }
        const completion = await openai.chat.completions.create({
            messages: [
                { role: 'system', content: 'You are a fitness and nutrition expert.' },
                { role: 'user', content: `User goals: ${goals}. Coach input: ${coachInput}` }
            ],
            model: 'gpt-3.5-turbo'
        });
        const aiContent = completion.choices[0]?.message?.content?.trim();
        if (!aiContent) {
            return res.status(502).json({ error: 'OpenAI returned empty recommendation.' });
        }
        const recommendation = await prisma.recommendation.create({
            data: { userId, type: 'ai', content: aiContent }
        });
        res.json(recommendation);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to generate recommendation.' });
    }
});
exports.default = router;
//# sourceMappingURL=recommendations.controller.js.map