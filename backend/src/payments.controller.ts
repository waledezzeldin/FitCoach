import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Initiate payment
router.post('/', async (req: Request, res: Response) => {
  try {
    const { userId, orderId, amount, provider, currency, subscriptionId } = req.body;
    // You would typically call your payment provider here (e.g., Stripe)
    // For now, just create a payment record as pending
    const payment = await prisma.payment.create({
      data: {
        userId,
        orderId,
        subscriptionId,
        amount,
        currency: currency || 'USD',
        status: 'pending',
        provider,
      }
    });
    res.status(201).json(payment);
  } catch (err) {
    res.status(500).json({ error: 'Failed to initiate payment.' });
  }
});

// Get payment history for user
router.get('/:userId', async (req: Request, res: Response) => {
  try {
    const payments = await prisma.payment.findMany({
      where: { userId: req.params.userId },
      orderBy: { createdAt: 'desc' }
    });
    res.json(payments);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch payment history.' });
  }
});

export default router;