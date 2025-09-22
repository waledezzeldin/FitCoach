import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Example endpoint
const router = Router();

router.post('/intake', async (req, res) => {
  const { userId, goal, experience, injuries, allergies, meds, diet, budget, age, weight, height, gender, trainingLocation } = req.body;
  await prisma.userHealth.create({
    data: {
      userId,
      goals: [goal],
      experience,
      injuries,
      allergies,
      meds,
      diet,
      budget,
      age,
      weight,
      height,
      gender,
      trainingLocation,
    }
  });
  res.json({ success: true });
});

export default router;