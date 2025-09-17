import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Get delivery status by orderId
router.get('/', async (req: Request, res: Response) => {
  try {
    const { orderId } = req.query;
    if (!orderId) return res.status(400).json({ error: 'orderId required.' });
    const delivery = await prisma.delivery.findUnique({
      where: { orderId: String(orderId) }
    });
    if (!delivery) {
      return res.status(404).json({ error: 'Delivery info not found.' });
    }
    res.json(delivery);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch delivery info.' });
  }
});

export default router;