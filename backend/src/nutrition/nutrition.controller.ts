import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { deriveExpiryDate, formatStatusPayload } from './nutrition.utils';
import { TIER_QUOTAS } from '../subscription/quota.config';

type SubscriptionTier = 'freemium' | 'premium' | 'smart_premium';

const router = Router();
const prisma = new PrismaClient();

const isTier = (value: unknown): value is SubscriptionTier =>
  value === 'freemium' || value === 'premium' || value === 'smart_premium';

const resolveTier = async (userId: string): Promise<SubscriptionTier> => {
  const subscription = await prisma.subscription.findFirst({ where: { userId } });
  const planCode = subscription?.planCode;
  return isTier(planCode) ? planCode : 'freemium';
};

const ensureAccess = async (userId: string, tier: SubscriptionTier) => {
  const now = new Date();
  const windowDays = TIER_QUOTAS[tier].nutritionWindowDays ?? undefined;
  let record = await prisma.nutritionAccess.findUnique({ where: { userId } });
  if (!record) {
    record = await prisma.nutritionAccess.create({
      data: {
        userId,
        planGeneratedAt: now,
        expiresAt: tier === 'freemium' && typeof windowDays === 'number' ? deriveExpiryDate(tier, now) : null,
        locked: tier === 'freemium' && typeof windowDays === 'number',
        windowDays,
      },
    });
    return record;
  }
  if (tier !== 'freemium' && (record.locked || record.expiresAt)) {
    record = await prisma.nutritionAccess.update({
      where: { userId },
      data: {
        locked: false,
        expiresAt: null,
        windowDays: null,
      },
    });
    return record;
  }
  if (tier === 'freemium' && (!record.expiresAt || !record.windowDays)) {
    record = await prisma.nutritionAccess.update({
      where: { userId },
      data: {
        windowDays,
        expiresAt: typeof windowDays === 'number' ? deriveExpiryDate(tier, now) : null,
        locked: typeof windowDays === 'number',
      },
    });
    return record;
  }
  return record;
};

router.get('/preferences/:userId', async (req: Request, res: Response) => {
  const { userId } = req.params;
  if (!userId) {
    return res.status(400).json({ error: 'userId is required' });
  }
  try {
    const preference = await prisma.nutritionPreference.findUnique({ where: { userId } });
    res.json({
      completed: !!preference?.completedAt,
      preferences: preference ?? null,
    });
  } catch (error) {
    console.error('Failed to fetch nutrition preferences', error);
    res.status(500).json({ error: 'Failed to fetch preferences.' });
  }
});

router.post('/preferences', async (req: Request, res: Response) => {
  const { userId, proteinSources = [], proteinAllergies = [], dinnerPreferences, additionalNotes } = req.body;
  if (!userId) {
    return res.status(400).json({ error: 'userId is required' });
  }
  if (!Array.isArray(proteinSources)) {
    return res.status(400).json({ error: 'proteinSources must be an array' });
  }
  if (!Array.isArray(proteinAllergies)) {
    return res.status(400).json({ error: 'proteinAllergies must be an array' });
  }
  try {
    const now = new Date();
    const preference = await prisma.nutritionPreference.upsert({
      where: { userId },
      update: {
        proteinSources,
        proteinAllergies,
        dinnerPreferences,
        additionalNotes,
        completedAt: now,
      },
      create: {
        userId,
        proteinSources,
        proteinAllergies,
        dinnerPreferences,
        additionalNotes,
        completedAt: now,
      },
    });
    res.json({ completed: true, preferences: preference });
  } catch (error) {
    console.error('Failed to save nutrition preferences', error);
    res.status(500).json({ error: 'Failed to save preferences.' });
  }
});

router.get('/access/:userId', async (req: Request, res: Response) => {
  const { userId } = req.params;
  if (!userId) {
    return res.status(400).json({ error: 'userId is required' });
  }
  try {
    const tier = isTier(req.query.tier) ? (req.query.tier as SubscriptionTier) : await resolveTier(userId);
    const access = await ensureAccess(userId, tier);
    res.json(formatStatusPayload(access, tier));
  } catch (error) {
    console.error('Failed to fetch nutrition access', error);
    res.status(500).json({ error: 'Failed to fetch nutrition plan access.' });
  }
});

router.post('/access/regenerate', async (req: Request, res: Response) => {
  const { userId, tier } = req.body as { userId?: string; tier?: SubscriptionTier };
  if (!userId) {
    return res.status(400).json({ error: 'userId is required' });
  }
  try {
    const resolvedTier = tier && isTier(tier) ? tier : await resolveTier(userId);
    const now = new Date();
    const expiresAt = resolvedTier === 'freemium' ? deriveExpiryDate(resolvedTier, now) : null;
    const access = await prisma.nutritionAccess.upsert({
      where: { userId },
      update: {
        planGeneratedAt: now,
        expiresAt,
        locked: resolvedTier === 'freemium' && !!expiresAt,
      },
      create: {
        userId,
        planGeneratedAt: now,
        expiresAt,
        locked: resolvedTier === 'freemium' && !!expiresAt,
        windowDays: TIER_QUOTAS[resolvedTier].nutritionWindowDays ?? undefined,
      },
    });
    res.json(formatStatusPayload(access, resolvedTier));
  } catch (error) {
    console.error('Failed to regenerate nutrition plan', error);
    res.status(500).json({ error: 'Failed to regenerate nutrition plan.' });
  }
});

router.post('/access/unlock', async (req: Request, res: Response) => {
  const { userId } = req.body as { userId?: string };
  if (!userId) {
    return res.status(400).json({ error: 'userId is required' });
  }
  try {
    const access = await prisma.nutritionAccess.upsert({
      where: { userId },
      update: {
        locked: false,
        expiresAt: null,
        windowDays: null,
      },
      create: {
        userId,
        planGeneratedAt: new Date(),
        expiresAt: null,
        locked: false,
        windowDays: null,
      },
    });
    res.json(formatStatusPayload(access, 'premium'));
  } catch (error) {
    console.error('Failed to unlock nutrition access', error);
    res.status(500).json({ error: 'Failed to unlock nutrition access.' });
  }
});

const parseMealPayload = (payload: any) => {
  const { userId, meal, date, calories, protein, carbs, fats, mealType, notes } = payload ?? {};
  if (!userId || !meal || !date) {
    throw new Error('userId, meal, and date are required');
  }
  return {
    userId: String(userId),
    meal: String(meal),
    date: new Date(date),
    calories: Number(calories ?? 0),
    protein: protein !== undefined ? Number(protein) : undefined,
    carbs: carbs !== undefined ? Number(carbs) : undefined,
    fats: fats !== undefined ? Number(fats) : undefined,
    mealType: mealType ? String(mealType) : undefined,
    notes: notes ? String(notes) : undefined,
  };
};

router.get('/logs/:userId', async (req: Request, res: Response) => {
  const { userId } = req.params;
  const day = typeof req.query.date === 'string' ? new Date(req.query.date) : undefined;
  const from = day ? new Date(day.setHours(0, 0, 0, 0)) : undefined;
  const to = day ? new Date(day.setHours(23, 59, 59, 999)) : undefined;
  try {
    const logs = await prisma.nutritionLog.findMany({
      where: {
        userId,
        ...(from && to
          ? {
              date: {
                gte: from,
                lte: to,
              },
            }
          : {}),
      },
      orderBy: { date: 'desc' },
    });
    res.json({ logs });
  } catch (error) {
    console.error('Failed to fetch nutrition logs', error);
    res.status(500).json({ error: 'Failed to fetch nutrition logs.' });
  }
});

router.post('/logs', async (req: Request, res: Response) => {
  try {
    const payload = parseMealPayload(req.body);
    const log = await prisma.nutritionLog.create({ data: payload });
    res.status(201).json(log);
  } catch (error) {
    console.error('Failed to create nutrition log', error);
    res.status(400).json({ error: error instanceof Error ? error.message : 'Invalid payload.' });
  }
});

router.put('/logs/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const existing = await prisma.nutritionLog.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ error: 'Log not found.' });
    }
    const payload = parseMealPayload({
      ...existing,
      ...req.body,
      userId: existing.userId,
    });
    const log = await prisma.nutritionLog.update({ where: { id }, data: payload });
    res.json(log);
  } catch (error) {
    console.error('Failed to update nutrition log', error);
    const status = error instanceof Error && error.message.includes('Required') ? 400 : 500;
    res.status(status).json({ error: error instanceof Error ? error.message : 'Failed to update log.' });
  }
});

router.delete('/logs/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    await prisma.nutritionLog.delete({ where: { id } });
    res.status(204).send();
  } catch (error) {
    console.error('Failed to delete nutrition log', error);
    res.status(500).json({ error: 'Failed to delete log.' });
  }
});

export default router;
