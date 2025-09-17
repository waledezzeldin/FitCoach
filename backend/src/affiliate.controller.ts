import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Get affiliate info
router.get('/', async (req: Request, res: Response) => {
  try {
    const affiliates = await prisma.affiliate.findMany();
    res.json(affiliates);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch affiliates.' });
  }
});

// Create affiliate
router.post('/', async (req: Request, res: Response) => {
  try {
    const { name, referralCode, brandUrl } = req.body;
    const affiliate = await prisma.affiliate.create({
      data: { name, referralCode, brandUrl }
    });
    res.status(201).json(affiliate);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create affiliate.' });
  }
});

export default router;