import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { sendPushNotification } from './notifications/push.service';

const router = Router();
const prisma = new PrismaClient();

// Get notifications for user
router.get('/', async (req: Request, res: Response) => {
  try {
    const { userId } = req.query;
    if (!userId) return res.status(400).json({ error: 'userId required.' });
    const notifications = await prisma.notification.findMany({
      where: { userId: String(userId) },
      orderBy: { createdAt: 'desc' }
    });
    res.json(notifications);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch notifications.' });
  }
});

// Create notification
router.post('/', async (req: Request, res: Response) => {
  try {
    const { userId, title, message, deviceToken } = req.body;
    const notification = await prisma.notification.create({
      data: { userId, title, message }
    });
    // Send push notification if deviceToken is provided
    if (deviceToken) {
      await sendPushNotification(deviceToken, title, message);
    }
    res.status(201).json(notification);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create notification.' });
  }
});

// Mark notification as read
router.put('/:id/read', async (req: Request, res: Response) => {
  try {
    const notification = await prisma.notification.update({
      where: { id: req.params.id },
      data: { read: true }
    });
    res.json(notification);
  } catch (err) {
    res.status(500).json({ error: 'Failed to mark notification as read.' });
  }
});

export default router;