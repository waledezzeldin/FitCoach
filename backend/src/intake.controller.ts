import { Router } from 'express';
import { PrismaClient, UserIntake } from '@prisma/client';

export const createIntakeRouter = (client: PrismaClient) => {
  const router = Router();

  const serializeIntake = (record: UserIntake | null) => {
    if (!record) {
      return { first: null, second: null, skippedSecond: false };
    }

    const firstCompleted = !!(record.gender && record.mainGoal && record.workoutLocation);
    const secondCompleted =
      record.age !== null &&
      record.age !== undefined &&
      record.weightKg !== null &&
      record.weightKg !== undefined &&
      record.heightCm !== null &&
      record.heightCm !== undefined &&
      !!record.experienceLevel &&
      record.workoutFrequency !== null &&
      record.workoutFrequency !== undefined;

    return {
      first: firstCompleted
        ? {
            gender: record.gender,
            mainGoal: record.mainGoal,
            workoutLocation: record.workoutLocation,
            completedAt: record.firstCompletedAt?.toISOString(),
          }
        : null,
      second: secondCompleted
        ? {
            age: record.age,
            weight: record.weightKg,
            height: record.heightCm,
            experienceLevel: record.experienceLevel,
            workoutFrequency: record.workoutFrequency,
            injuries: record.injuries,
            completedAt: record.secondCompletedAt?.toISOString(),
          }
        : null,
      skippedSecond: record.skippedSecond,
    };
  };

  router.get('/:userId', async (req, res) => {
    const { userId } = req.params;
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    try {
      const intake = await client.userIntake.findUnique({ where: { userId } });
      return res.json({ intake: serializeIntake(intake) });
    } catch (error) {
      console.error('Failed to fetch intake', error);
      return res.status(500).json({ error: 'Failed to fetch intake data' });
    }
  });

  router.post('/first', async (req, res) => {
    const { userId, gender, mainGoal, workoutLocation, completedAt } = req.body;
    if (!userId || !gender || !mainGoal || !workoutLocation) {
      return res.status(400).json({ error: 'userId, gender, mainGoal and workoutLocation are required' });
    }
    const timestamp = completedAt ? new Date(completedAt) : new Date();
    try {
      const intake = await client.userIntake.upsert({
        where: { userId },
        update: {
          gender,
          mainGoal,
          workoutLocation,
          firstCompletedAt: timestamp,
          skippedSecond: false,
        },
        create: {
          userId,
          gender,
          mainGoal,
          workoutLocation,
          firstCompletedAt: timestamp,
          injuries: [],
        },
      });
      return res.json({ intake: serializeIntake(intake) });
    } catch (error) {
      console.error('Failed to save first intake stage', error);
      return res.status(500).json({ error: 'Failed to save intake' });
    }
  });

  router.post('/second', async (req, res) => {
    const {
      userId,
      age,
      weight,
      height,
      experienceLevel,
      workoutFrequency,
      injuries = [],
      completedAt,
    } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    if (
      age === undefined ||
      weight === undefined ||
      height === undefined ||
      !experienceLevel ||
      workoutFrequency === undefined
    ) {
      return res.status(400).json({ error: 'age, weight, height, experienceLevel and workoutFrequency are required' });
    }

    const existing = await client.userIntake.findUnique({ where: { userId } });
    if (!existing) {
      return res.status(409).json({ error: 'First intake stage must be completed before submitting the second stage.' });
    }

    const payloadInjuries = Array.isArray(injuries) ? injuries.map((item) => String(item)) : [];
    const timestamp = completedAt ? new Date(completedAt) : new Date();

    try {
      const intake = await client.userIntake.update({
        where: { userId },
        data: {
          age,
          weightKg: weight,
          heightCm: height,
          experienceLevel,
          workoutFrequency,
          injuries: payloadInjuries,
          secondCompletedAt: timestamp,
          skippedSecond: false,
        },
      });
      return res.json({ intake: serializeIntake(intake) });
    } catch (error) {
      console.error('Failed to save second intake stage', error);
      return res.status(500).json({ error: 'Failed to save intake' });
    }
  });

  router.post('/skip-second', async (req, res) => {
    const { userId } = req.body;
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    try {
      const intake = await client.userIntake.upsert({
        where: { userId },
        update: {
          skippedSecond: true,
          secondCompletedAt: null,
        },
        create: {
          userId,
          skippedSecond: true,
          injuries: [],
        },
      });
      return res.json({ intake: serializeIntake(intake) });
    } catch (error) {
      console.error('Failed to skip second intake stage', error);
      return res.status(500).json({ error: 'Failed to skip intake stage' });
    }
  });
  return router;
};