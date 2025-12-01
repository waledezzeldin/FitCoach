"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const client_1 = require("@prisma/client");
const quota_service_1 = require("./subscription/quota.service");
const quota_config_1 = require("./subscription/quota.config");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
const isValidTier = (value) => value === 'freemium' || value === 'premium' || value === 'smart_premium';
router.get('/quota/:userId', async (req, res) => {
    const { userId } = req.params;
    if (!userId) {
        return res.status(400).json({ error: 'userId is required' });
    }
    try {
        const snapshot = await (0, quota_service_1.getQuotaSnapshot)(prisma, userId);
        res.json(snapshot);
    }
    catch (error) {
        console.error('Quota snapshot failed', error);
        res.status(500).json({ error: 'Failed to fetch quota snapshot.' });
    }
});
router.post('/quota/check', async (req, res) => {
    const { userId, action, tier } = req.body;
    if (!userId || !action) {
        return res.status(400).json({ error: 'userId and action are required' });
    }
    if (!['message', 'call', 'attachment'].includes(action)) {
        return res.status(400).json({ error: 'Unsupported action' });
    }
    const tierOverride = isValidTier(tier) ? tier : undefined;
    try {
        const result = await (0, quota_service_1.checkQuota)(prisma, userId, action, tierOverride);
        res.json(result);
    }
    catch (error) {
        console.error('Quota check failed', error);
        res.status(500).json({ error: 'Failed to check quota.' });
    }
});
router.post('/quota/consume', async (req, res) => {
    const { userId, action, tier } = req.body;
    if (!userId || !action) {
        return res.status(400).json({ error: 'userId and action are required' });
    }
    if (!['message', 'call', 'attachment'].includes(action)) {
        return res.status(400).json({ error: 'Unsupported action' });
    }
    const tierOverride = isValidTier(tier) ? tier : undefined;
    try {
        const result = await (0, quota_service_1.consumeQuota)(prisma, userId, action, tierOverride);
        if (!result.allowed) {
            return res.status(409).json(result);
        }
        res.json(result);
    }
    catch (error) {
        console.error('Quota consume failed', error);
        res.status(500).json({ error: 'Failed to consume quota.' });
    }
});
router.post('/tier', async (req, res) => {
    const { userId, tier, planCode } = req.body;
    if (!userId) {
        return res.status(400).json({ error: 'userId is required' });
    }
    const normalizedTier = tier ?? (0, quota_service_1.mapTierFromPlan)(planCode);
    if (!isValidTier(normalizedTier)) {
        return res.status(400).json({ error: 'Invalid tier value' });
    }
    try {
        const limits = quota_config_1.TIER_QUOTAS[normalizedTier];
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
                resetAt: (0, quota_config_1.nextResetDate)(new Date()),
                nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
                nutritionLocked: !limits.nutritionPersistent,
            },
        });
        await prisma.subscription.updateMany({ where: { userId }, data: { planCode: normalizedTier } });
        res.json({ userId, tier: record.tier });
    }
    catch (error) {
        console.error('Tier update failed', error);
        res.status(500).json({ error: 'Failed to update subscription tier.' });
    }
});
router.get('/:userId', async (req, res) => {
    try {
        const subscription = await prisma.subscription.findMany({
            where: { userId: req.params.userId },
            orderBy: { createdAt: 'desc' },
        });
        res.json(subscription);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch subscription.' });
    }
});
router.post('/', async (req, res) => {
    try {
        const { userId, stripeSubscriptionId, currentPeriodEnd, status, isActive, planCode, } = req.body;
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
            const normalized = (0, quota_service_1.mapTierFromPlan)(planCode);
            const limits = quota_config_1.TIER_QUOTAS[normalized];
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
                    resetAt: (0, quota_config_1.nextResetDate)(new Date()),
                    nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
                    nutritionLocked: !limits.nutritionPersistent,
                },
            });
        }
        res.status(201).json(subscription);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to create subscription.' });
    }
});
exports.default = router;
//# sourceMappingURL=subscription.controller.js.map