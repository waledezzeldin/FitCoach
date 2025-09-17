import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Get subscription for user
router.get('/:userId', async (req: Request, res: Response) => {
  try {
    const subscription = await prisma.subscription.findMany({
      where: { userId: req.params.userId },
      orderBy: { startDate: 'desc' }
    });
    res.json(subscription);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch subscription.' });
  }
});

// Create or update subscription
router.post('/', async (req: Request, res: Response) => {
  try {
    const { userId, type, startDate, endDate, isActive, paymentId } = req.body;
    const subscription = await prisma.subscription.create({
      data: {
        userId,
        type,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        isActive,
        paymentId
      }
    });
    res.status(201).json(subscription);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create subscription.' });
  }
});

export default router;