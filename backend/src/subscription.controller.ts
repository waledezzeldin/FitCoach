import { Router, Request, Response } from 'express';
import { PrismaClient, SubscriptionTier } from '@prisma/client';
import { checkQuota, consumeQuota, getQuotaSnapshot, mapTierFromPlan } from './subscription/quota.service';
import { TIER_QUOTAS, nextResetDate } from './subscription/quota.config';

const router = Router();
const prisma = new PrismaClient();

const isValidTier = (value: unknown): value is SubscriptionTier =>
  value === 'freemium' || value === 'premium' || value === 'smart_premium';

router.get('/quota/:userId', async (req: Request, res: Response) => {
  const { userId } = req.params;
  if (!userId) {
    return res.status(400).json({ error: 'userId is required' });
  }
  try {
    const snapshot = await getQuotaSnapshot(prisma, userId);
    res.json(snapshot);
  } catch (error) {
    console.error('Quota snapshot failed', error);
    res.status(500).json({ error: 'Failed to fetch quota snapshot.' });
  }
});

router.post('/quota/check', async (req: Request, res: Response) => {
  const { userId, action, tier } = req.body as { userId?: string; action?: string; tier?: SubscriptionTier };
  if (!userId || !action) {
    return res.status(400).json({ error: 'userId and action are required' });
  }
  if (!['message', 'call', 'attachment'].includes(action)) {
    return res.status(400).json({ error: 'Unsupported action' });
  }
  const tierOverride = isValidTier(tier) ? tier : undefined;
  try {
    const result = await checkQuota(prisma, userId, action as any, tierOverride);
    res.json(result);
  } catch (error) {
    console.error('Quota check failed', error);
    res.status(500).json({ error: 'Failed to check quota.' });
  }
});

router.post('/quota/consume', async (req: Request, res: Response) => {
  const { userId, action, tier } = req.body as { userId?: string; action?: string; tier?: SubscriptionTier };
  if (!userId || !action) {
    return res.status(400).json({ error: 'userId and action are required' });
  }
  if (!['message', 'call', 'attachment'].includes(action)) {
    return res.status(400).json({ error: 'Unsupported action' });
  }
  const tierOverride = isValidTier(tier) ? tier : undefined;
  try {
    const result = await consumeQuota(prisma, userId, action as any, tierOverride);
    if (!result.allowed) {
      return res.status(409).json(result);
    }
    res.json(result);
  } catch (error) {
    console.error('Quota consume failed', error);
    res.status(500).json({ error: 'Failed to consume quota.' });
  }
});

router.post('/tier', async (req: Request, res: Response) => {
  const { userId, tier, planCode } = req.body as { userId?: string; tier?: SubscriptionTier; planCode?: string };
  if (!userId) {
    return res.status(400).json({ error: 'userId is required' });
  }
  const normalizedTier = tier ?? mapTierFromPlan(planCode);
  if (!isValidTier(normalizedTier)) {
    return res.status(400).json({ error: 'Invalid tier value' });
  }
  try {
    const limits = TIER_QUOTAS[normalizedTier];
    const record = await prisma.subscriptionQuota.upsert({
      where: { userId },
      update: {
        tier: normalizedTier,
        nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
        nutritionLocked: !limits.nutritionPersistent,
      },
      create: {
        userId,
        tier: normalizedTier,
        resetAt: nextResetDate(new Date()),
        nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
        nutritionLocked: !limits.nutritionPersistent,
      },
    });
    await prisma.subscription.updateMany({ where: { userId }, data: { planCode: normalizedTier } });
    res.json({ userId, tier: record.tier });
  } catch (error) {
    console.error('Tier update failed', error);
    res.status(500).json({ error: 'Failed to update subscription tier.' });
  }
});

// Get subscription for user
router.get('/:userId', async (req: Request, res: Response) => {
  try {
    const subscription = await prisma.subscription.findMany({
      where: { userId: req.params.userId },
      orderBy: { createdAt: 'desc' },
    });
    res.json(subscription);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch subscription.' });
  }
});

// Create or update subscription
router.post('/', async (req: Request, res: Response) => {
  try {
    const {
      userId,
      stripeSubscriptionId,
      currentPeriodEnd,
      status,
      isActive,
      planCode,
    } = req.body;
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    const subscription = await prisma.subscription.create({
      data: {
        userId,
        stripeSubscriptionId,
        status: status ?? (isActive ? 'active' : 'inactive'),
        currentPeriodEnd: currentPeriodEnd ? new Date(currentPeriodEnd) : null,
        planCode,
      },
    });
    if (planCode) {
      const normalized = mapTierFromPlan(planCode);
      const limits = TIER_QUOTAS[normalized];
      await prisma.subscriptionQuota.upsert({
        where: { userId },
        update: {
          tier: normalized,
          nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
          nutritionLocked: !limits.nutritionPersistent,
        },
        create: {
          userId,
          tier: normalized,
          resetAt: nextResetDate(new Date()),
          nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
          nutritionLocked: !limits.nutritionPersistent,
        },
      });
    }
    res.status(201).json(subscription);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create subscription.' });
  }
});

export default router;