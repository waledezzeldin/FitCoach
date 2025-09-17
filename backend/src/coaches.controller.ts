import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Coach onboarding
router.post('/onboard', async (req: Request, res: Response) => {
  try {
    const { userId, bio, certifications, referralCode } = req.body;
    const coach = await prisma.coach.create({
      data: { userId, bio, certifications, referralCode }
    });
    res.status(201).json(coach);
  } catch (err) {
    res.status(500).json({ error: 'Coach onboarding failed.' });
  }
});

// Get coach profile
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const coach = await prisma.coach.findUnique({
      where: { id: req.params.id },
      include: { user: true }
    });
    if (!coach) {
      return res.status(404).json({ error: 'Coach not found.' });
    }
    res.json(coach);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch coach profile.' });
  }
});

// Get coach commissions
router.get('/:id/commissions', async (req: Request, res: Response) => {
  try {
    const commissions = await prisma.commission.findMany({
      where: { coachId: req.params.id }
    });
    res.json(commissions);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch commissions.' });
  }
});

export default router;