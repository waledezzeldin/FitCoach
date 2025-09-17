import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { OpenAI } from 'openai';

const router = Router();
const prisma = new PrismaClient();
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

router.post('/', async (req: Request, res: Response) => {
  try {
    const { userId, goals, coachInput } = req.body;
    // Call OpenAI for recommendation
    const completion = await openai.chat.completions.create({
      messages: [
        { role: 'system', content: 'You are a fitness and nutrition expert.' },
        { role: 'user', content: `User goals: ${goals}. Coach input: ${coachInput}` }
      ],
      model: 'gpt-3.5-turbo'
    });
    const aiContent = completion.choices[0].message.content;
    // Save recommendation
    const recommendation = await prisma.recommendation.create({
      data: { userId, type: 'ai', content: aiContent }
    });
    res.json(recommendation);
  } catch (err) {
    res.status(500).json({ error: 'Failed to generate recommendation.' });
  }
});

export default router;
