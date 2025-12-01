import { Router, Request, Response } from 'express';
import { PrismaClient, Prisma } from '@prisma/client';
import { getQuotaSnapshot, consumeQuota } from './subscription/quota.service';

const router = Router();
const prisma = new PrismaClient();

type SessionWithUser = Prisma.SessionGetPayload<{
  include: { user: true };
}>;

const coachDashboardSessionsArgs: Prisma.SessionFindManyArgs = {
  include: { user: true },
  orderBy: { scheduledAt: 'asc' },
  take: 20,
};

const coachPendingRatingArgs: Prisma.SessionFindFirstArgs = {
  orderBy: { scheduledAt: 'desc' },
};

const coachProfileInclude: Prisma.CoachInclude = {
  user: true,
  certificates: { orderBy: { issuedAt: 'desc' } },
  experiences: { orderBy: { startDate: 'desc' } },
  achievements: { orderBy: { achievedAt: 'desc' } },
};

const coachDashboardInclude: Prisma.CoachInclude = {
  user: true,
};

const buildCoachStats = async (coachId: string) => {
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  const [clientGroups, activeClientGroups, completedSessions, successfulSessions, ratingAgg, monthlyRevenue, totalRevenue] =
    await Promise.all([
      prisma.session.groupBy({ by: ['userId'], where: { coachId } }),
      prisma.session.groupBy({
        by: ['userId'],
        where: {
          coachId,
          scheduledAt: { gte: now },
        },
      }),
      prisma.session.count({ where: { coachId, status: 'completed' } }),
      prisma.session.count({ where: { coachId, status: 'completed', rating: { gte: 4 } } }),
      prisma.session.aggregate({
        where: { coachId, rating: { not: null } },
        _avg: { rating: true },
        _count: { rating: true },
      }),
      prisma.commission.aggregate({
        where: { coachId, createdAt: { gte: startOfMonth } },
        _sum: { amount: true },
      }),
      prisma.commission.aggregate({ where: { coachId }, _sum: { amount: true } }),
    ]);

  const averageRatingValue = ratingAgg._avg?.rating;
  const averageRating = typeof averageRatingValue === 'number' ? Number(averageRatingValue.toFixed(2)) : null;
  const successRate = completedSessions > 0 ? Math.round((successfulSessions / completedSessions) * 100) : null;

  return {
    totalClients: clientGroups.length,
    activeClients: activeClientGroups.length,
    completedSessions,
    successfulSessions,
    averageRating,
    successRate,
    monthlyRevenue: Number(monthlyRevenue._sum.amount ?? 0),
    totalRevenue: Number(totalRevenue._sum.amount ?? 0),
    ratingCount: ratingAgg._count?.rating ?? 0,
  };
};

// Coach onboarding
router.post('/onboard', async (req: Request, res: Response) => {
  try {
    const { userId, bio, certifications, referralCode } = req.body;
    const coach = await prisma.coach.create({
      data: { userId, bio, certifications, referralCode }
    });
    res.status(201).json(coach);
  } catch (err) {
    res.status(500).json({ error: 'Coach onboarding failed.' });
  }
});

// Get coach profile
router.get('/:id/dashboard', async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = typeof req.query.userId === 'string' ? req.query.userId : undefined;
  try {
    const coach = await prisma.coach.findUnique({
      where: { id },
      include: coachDashboardInclude,
    });
    if (!coach) {
      return res.status(404).json({ error: 'Coach not found.' });
    }

    const [sessionResults, quota, pendingRating, stats] = await Promise.all([
      prisma.session.findMany({
        ...coachDashboardSessionsArgs,
        where: { coachId: id },
      }),
      userId ? getQuotaSnapshot(prisma, userId).catch(() => null) : Promise.resolve(null),
      userId
        ? prisma.session.findFirst({
            ...coachPendingRatingArgs,
            where: { coachId: id, userId, status: 'completed', rating: null },
          })
        : Promise.resolve(null),
      buildCoachStats(id),
    ]);

    const sessions = sessionResults as SessionWithUser[];

    const rated = sessions.filter((s) => typeof s.rating === 'number');
    const ratingStats = {
      count: rated.length,
      average: rated.length ? rated.reduce((acc, curr) => acc + (curr.rating ?? 0), 0) / rated.length : null,
    };

    res.json({
      coach,
      rating: ratingStats,
      quota,
      stats,
      attachmentsAllowed: !!quota?.limits.chatAttachments,
      upcomingSessions: sessions
        .filter((s) => s.scheduledAt > new Date())
        .slice(0, 10)
        .map((s) => ({
          id: s.id,
          scheduledAt: s.scheduledAt,
          status: s.status,
          user: { id: s.user.id, name: s.user.name, email: s.user.email },
        })),
      pendingRatingSession: pendingRating
        ? { id: pendingRating.id, scheduledAt: pendingRating.scheduledAt }
        : null,
    });
  } catch (err) {
    console.error('Failed to fetch coach dashboard', err);
    res.status(500).json({ error: 'Failed to fetch coach dashboard.' });
  }
});

router.get('/:coachId/clients/:userId', async (req: Request, res: Response) => {
  const { coachId, userId } = req.params;
  try {
    const [user, intake, quota, sessions, milestones, nutritionLogs] = await Promise.all([
      prisma.user.findUnique({ where: { id: userId } }),
      prisma.userIntake.findUnique({ where: { userId } }),
      getQuotaSnapshot(prisma, userId).catch(() => null),
      prisma.session.findMany({
        where: { userId, coachId },
        orderBy: { scheduledAt: 'desc' },
        take: 10,
      }),
      prisma.milestone.findMany({ where: { userId }, orderBy: { achievedAt: 'desc' }, take: 5 }),
      prisma.nutritionLog.findMany({ where: { userId }, orderBy: { date: 'desc' }, take: 10 }),
    ]);

    if (!user) {
      return res.status(404).json({ error: 'Client not found.' });
    }

    res.json({ user, intake, quota, sessions, milestones, nutritionLogs });
  } catch (err) {
    console.error('Failed to fetch client detail', err);
    res.status(500).json({ error: 'Failed to fetch client detail.' });
  }
});

router.get('/:coachId/messages', async (req: Request, res: Response) => {
  const { coachId } = req.params;
  const userId = typeof req.query.userId === 'string' ? req.query.userId : undefined;
  const requestedLimit = Number(req.query.limit ?? 50);
  const safeLimit = Number.isFinite(requestedLimit) ? requestedLimit : 50;
  try {
    const messages = await prisma.coachMessage.findMany({
      where: {
        coachId,
        ...(userId ? { userId } : {}),
      },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
      take: Math.min(Math.max(safeLimit, 1), 200),
    });
    res.json({ messages: messages.reverse() });
  } catch (err) {
    console.error('Failed to fetch coach messages', err);
    res.status(500).json({ error: 'Failed to fetch messages.' });
  }
});

router.post('/:coachId/messages', async (req: Request, res: Response) => {
  const { coachId } = req.params;
  const { userId, sender, body, attachmentUrl, attachmentName, attachmentType, attachmentSize } = req.body as {
    userId?: string;
    sender?: string;
    body?: string;
    attachmentUrl?: string;
    attachmentName?: string;
    attachmentType?: string;
    attachmentSize?: number;
  };

  if (!userId || !sender || !['coach', 'user'].includes(sender)) {
    return res.status(400).json({ error: 'userId and valid sender are required.' });
  }

  try {
    if (sender === 'user') {
      const quotaResult = await consumeQuota(prisma, userId, 'message');
      if (!quotaResult.allowed) {
        return res.status(409).json(quotaResult);
      }
      if (attachmentUrl) {
        const attachmentQuota = await consumeQuota(prisma, userId, 'attachment');
        if (!attachmentQuota.allowed) {
          return res.status(409).json(attachmentQuota);
        }
      }
    }

    const message = await prisma.coachMessage.create({
      data: {
        coachId,
        userId,
        sender,
        body,
        attachmentUrl,
        attachmentName,
        attachmentType,
        attachmentSize,
      },
    });
    res.status(201).json(message);
  } catch (err) {
    console.error('Failed to post coach message', err);
    res.status(500).json({ error: 'Failed to post message.' });
  }
});

// Get coach commissions
router.get('/:id/commissions', async (req: Request, res: Response) => {
  try {
    const commissions = await prisma.commission.findMany({
      where: { coachId: req.params.id }
    });
    res.json(commissions);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch commissions.' });
  }
});

router.get('/:id/profile', async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = typeof req.query.userId === 'string' ? req.query.userId : undefined;
  try {
    const coach = await prisma.coach.findUnique({
      where: { id },
      include: coachProfileInclude,
    });
    if (!coach) {
      return res.status(404).json({ error: 'Coach not found.' });
    }

    const [stats, quota] = await Promise.all([
      buildCoachStats(id),
      userId ? getQuotaSnapshot(prisma, userId).catch(() => null) : Promise.resolve(null),
    ]);

    const { certificates, experiences, achievements, ...coachCore } = coach;

    res.json({
      coach: coachCore,
      certificates,
      experiences,
      achievements,
      stats,
      quota,
      contact: {
        email: coach.user.email,
        phone: coach.user.phone,
      },
    });
  } catch (err) {
    console.error('Failed to fetch coach profile', err);
    res.status(500).json({ error: 'Failed to fetch coach profile.' });
  }
});

// Coach profile fallback (keep last to avoid intercepting nested routes)
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const coach = await prisma.coach.findUnique({
      where: { id: req.params.id },
      include: { user: true }
    });
    if (!coach) {
      return res.status(404).json({ error: 'Coach not found.' });
    }
    res.json(coach);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch coach profile.' });
  }
});

export default router;