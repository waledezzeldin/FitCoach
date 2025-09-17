import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Save device token for user
router.post('/device-token', async (req: Request, res: Response) => {
  try {
    const { userId, deviceToken } = req.body;
    await prisma.user.update({
      where: { id: userId },
      data: { deviceToken }
    });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to save device token.' });
  }
});

export default router;