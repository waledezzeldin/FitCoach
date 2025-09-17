import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Get all bundles
router.get('/', async (req: Request, res: Response) => {
  try {
    const bundles = await prisma.bundle.findMany({ include: { products: true } });
    res.json(bundles);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch bundles.' });
  }
});

export default router;