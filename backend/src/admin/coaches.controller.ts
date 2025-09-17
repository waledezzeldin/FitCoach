import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// List all coaches
router.get('/', async (req: Request, res: Response) => {
  try {
    const coaches = await prisma.coach.findMany({
      include: { user: true }
    });
    res.json(coaches);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch coaches.' });
  }
});

// Update coach
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { bio, certifications, referralCode } = req.body;
    const coach = await prisma.coach.update({
      where: { id: req.params.id },
      data: { bio, certifications, referralCode }
    });
    res.json(coach);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update coach.' });
  }
});

// Delete coach
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    await prisma.coach.delete({ where: { id: req.params.id } });
    res.json({ message: 'Coach deleted.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete coach.' });
  }
});

export default router;