import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { getAlternativesForInjury } from './workouts/injury-map';

const router = Router();
const prisma = new PrismaClient();

router.get('/alternatives', (req: Request, res: Response) => {
  const injuryArea = typeof req.query.injuryArea === 'string' ? req.query.injuryArea : undefined;
  const muscleGroup = typeof req.query.muscleGroup === 'string' ? req.query.muscleGroup : undefined;
  if (!injuryArea) {
    return res.status(400).json({ error: 'injuryArea is required' });
  }
  const alternatives = getAlternativesForInjury(injuryArea, muscleGroup);
  res.json({ alternatives });
});

router.post('/swaps', async (req: Request, res: Response) => {
  const { sessionId, userId, originalExerciseId, alternativeExerciseId, injuryArea } = req.body as {
    sessionId?: string;
    userId?: string;
    originalExerciseId?: string;
    alternativeExerciseId?: string;
    injuryArea?: string;
  };

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
  } catch (err) {
    console.error('Failed to record workout swap', err);
    res.status(500).json({ error: 'Failed to record swap.' });
  }
});

export default router;
