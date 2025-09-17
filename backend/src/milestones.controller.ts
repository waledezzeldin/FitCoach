import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Get milestones for user
router.get('/:userId', async (req: Request, res: Response) => {
  try {
    const milestones = await prisma.milestone.findMany({
      where: { userId: req.params.userId },
      orderBy: { achievedAt: 'desc' }
    });
    res.json(milestones);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch milestones.' });
  }
});

// Create milestone
router.post('/', async (req: Request, res: Response) => {
  try {
    const { userId, type, description } = req.body;
    const milestone = await prisma.milestone.create({
      data: { userId, type, description }
    });
    res.status(201).json(milestone);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create milestone.' });
  }
});

export default router;