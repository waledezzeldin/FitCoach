"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const openai_1 = require("openai");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
const openai = new openai_1.OpenAI({ apiKey: process.env.OPENAI_API_KEY });
router.post('/', async (req, res) => {
    try {
        const { userId, goals, coachInput } = req.body;
        const completion = await openai.chat.completions.create({
            messages: [
                { role: 'system', content: 'You are a fitness and nutrition expert.' },
                { role: 'user', content: `User goals: ${goals}. Coach input: ${coachInput}` }
            ],
            model: 'gpt-3.5-turbo'
        });
        const aiContent = completion.choices[0].message.content;
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