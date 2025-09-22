import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// List all orders for a user
router.get('/orders', async (req, res) => {
  try {
    // Replace with actual user ID from auth/session
    const userId = req.query.userId || 'USER_ID';
    const orders = await prisma.order.findMany({
      where: { clientId: userId },
      orderBy: { createdAt: 'desc' },
      include: { items: true }, // Include order items if you have a relation
    });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// Get details for a specific order
router.get('/orders/:id', async (req, res) => {
  try {
    const orderId = req.params.id;
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: { items: true }, // Include order items if you have a relation
    });
    if (!order) return res.status(404).json({ error: 'Order not found' });
    res.json(order);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch order details' });
  }
});

export default router;