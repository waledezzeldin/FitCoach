import { Router, Request, Response } from 'express';
// Update the import path to match your actual Prisma client location
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const router = Router();

router.post('/:id/approve', async (req: Request, res: Response) => {
  try {
    const requestId = req.params.id;
    const coachRequest = await prisma.coachRequest.update({
      where: { id: requestId },
      data: { status: 'approved' }
    });
    await prisma.user.update({
      where: { id: coachRequest.userId },
      data: { role: 'coach' }
    });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Approval failed.' });
  }
});

export default router;