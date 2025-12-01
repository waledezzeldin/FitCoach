import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';
import { consumeQuota } from '../subscription/quota.service';
const prisma = new PrismaClient();
const router = Router();

const buildAvailability = (start: Date, days: number, existing: Date[]) => {
  const taken = new Set(existing.map((d) => d.toISOString()));
  const slotsPerDay = ['09:00', '11:00', '13:00', '15:00', '17:00'];
  const results: { date: string; slots: { label: string; iso: string }[] }[] = [];
  for (let i = 0; i < days; i += 1) {
    const day = new Date(start);
    day.setDate(start.getDate() + i);
    const dayISO = day.toISOString().split('T')[0];
    const slots = slotsPerDay
      .map((time) => {
        const [h, m] = time.split(':').map(Number);
        const slot = new Date(day);
        slot.setHours(h, m, 0, 0);
        return slot;
      })
      .filter((slot) => slot > new Date())
      .filter((slot) => !taken.has(slot.toISOString()))
      .map((slot) => ({
        label: slot.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }),
        iso: slot.toISOString(),
      }));
    results.push({ date: dayISO, slots });
  }
  return results;
};

// Availability lookup
router.get('/availability/:coachId', async (req: Request, res: Response) => {
  const { coachId } = req.params;
  const days = Math.min(Math.max(Number(req.query.days ?? 7), 1), 14);
  const from = new Date();
  const until = new Date(from);
  until.setDate(from.getDate() + days);
  try {
    const sessions = await prisma.session.findMany({
      where: {
        coachId,
        scheduledAt: { gte: from, lt: until },
        status: { notIn: ['cancelled'] },
      },
      select: { scheduledAt: true },
    });
    res.json({ availability: buildAvailability(from, days, sessions.map((s) => s.scheduledAt)) });
  } catch (err) {
    console.error('Failed to fetch availability', err);
    res.status(500).json({ error: 'Failed to fetch availability.' });
  }
});

// POST /v1/sessions -> schedule session with quota enforcement
router.post('/', async (req: Request, res: Response) => {
  const { userId, coachId, scheduledAt, durationMin } = req.body as {
    userId?: string;
    coachId?: string;
    scheduledAt?: string;
    durationMin?: number;
  };

  if (!userId || !coachId || !scheduledAt) {
    return res.status(400).json({ error: 'userId, coachId, and scheduledAt are required.' });
  }

  try {
    const slot = new Date(scheduledAt);
    const conflict = await prisma.session.findFirst({
      where: { coachId, scheduledAt: slot, status: { not: 'cancelled' } },
    });
    if (conflict) {
      return res.status(409).json({ error: 'Time slot unavailable.' });
    }

    const quotaResult = await consumeQuota(prisma, userId, 'call');
    if (!quotaResult.allowed) {
      return res.status(409).json(quotaResult);
    }

    const session = await prisma.session.create({
      data: {
        userId,
        coachId,
        scheduledAt: slot,
        durationMin: durationMin || 30,
        status: 'scheduled',
      },
    });
    res.status(201).json(session);
  } catch (err) {
    console.error('Failed to schedule session', err);
    res.status(500).json({ error: 'Failed to schedule session.' });
  }
});

// Rate completed session
router.post('/:id/rate', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { userId, rating, note } = req.body as { userId?: string; rating?: number; note?: string };
  if (!userId || typeof rating !== 'number' || rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'userId and rating (1-5) are required.' });
  }

  try {
    const session = await prisma.session.findUnique({ where: { id } });
    if (!session) {
      return res.status(404).json({ error: 'Session not found.' });
    }
    if (session.userId !== userId) {
      return res.status(403).json({ error: 'Cannot rate this session.' });
    }

    const updated = await prisma.session.update({
      where: { id },
      data: {
        rating,
        ratingNote: note,
        status: 'completed',
      },
    });
    res.json(updated);
  } catch (err) {
    console.error('Failed to rate session', err);
    res.status(500).json({ error: 'Failed to submit rating.' });
  }
});

// GET /v1/sessions/:id/join -> return agora token + channel name
router.get('/:id/join', async (req, res) => {
  const session = await prisma.session.findUnique({ where: { id: req.params.id }});
  if (!session) return res.status(404).json({ error: 'not_found' });
  const channel = session.agoraChannel || `session_${session.id}`;
  const appId = process.env.AGORA_APP_ID || '';
  const appCert = process.env.AGORA_APP_CERT || '';
  const uid = 0;
  const expire = Math.floor(Date.now()/1000) + 3600;
  const token = RtcTokenBuilder.buildTokenWithUid(appId, appCert, channel, uid, RtcRole.PUBLISHER, expire);
  // persist channel if not present
  if (!session.agoraChannel) {
    await prisma.session.update({ where: { id: session.id }, data: { agoraChannel: channel }});
  }
  res.json({ channelName: channel, token, expiresAt: expire });
});

export default router;
