import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Log workout
router.post('/workout', async (req: Request, res: Response) => {
  try {
    const { userId, date, activity, duration, notes } = req.body;
    const log = await prisma.workoutLog.create({
      data: { userId, date: new Date(date), activity, duration, notes }
    });
    res.status(201).json(log);
  } catch (err) {
    res.status(500).json({ error: 'Failed to log workout.' });
  }
});

// Log nutrition
router.post('/nutrition', async (req: Request, res: Response) => {
  try {
    const { userId, date, meal, calories, notes } = req.body;
    const log = await prisma.nutritionLog.create({
      data: { userId, date: new Date(date), meal, calories, notes }
    });
    res.status(201).json(log);
  } catch (err) {
    res.status(500).json({ error: 'Failed to log nutrition.' });
  }
});

// Log supplement
router.post('/supplement', async (req: Request, res: Response) => {
  try {
    const { userId, date, supplementName, dose, notes } = req.body;
    const log = await prisma.supplementLog.create({
      data: { userId, date: new Date(date), supplementName, dose, notes }
    });
    res.status(201).json(log);
  } catch (err) {
    res.status(500).json({ error: 'Failed to log supplement.' });
  }
});

// Get all progress logs for user
router.get('/:userId', async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId;
    const workouts = await prisma.workoutLog.findMany({ where: { userId } });
    const nutrition = await prisma.nutritionLog.findMany({ where: { userId } });
    const supplements = await prisma.supplementLog.findMany({ where: { userId } });
    res.json({ workouts, nutrition, supplements });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch progress logs.' });
  }
});

export default router;