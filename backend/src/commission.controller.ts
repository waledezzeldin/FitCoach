import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Get commissions for coach or affiliate
router.get('/', async (req: Request, res: Response) => {
  try {
    const { coachId, affiliateId } = req.query;
    let commissions = [];
    if (coachId) {
      commissions = await prisma.commission.findMany({ where: { coachId: String(coachId) } });
    } else if (affiliateId) {
      commissions = await prisma.commission.findMany({ where: { affiliateId: String(affiliateId) } });
    } else {
      commissions = await prisma.commission.findMany();
    }
    res.json(commissions);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch commissions.' });
  }
});

export default router;