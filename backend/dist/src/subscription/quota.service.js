"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mapTierFromPlan = exports.consumeQuota = exports.checkQuota = exports.getQuotaSnapshot = exports.ensureQuotaRecord = exports.evaluateQuota = void 0;
const quota_config_1 = require("./quota.config");
const messageRemaining = (limit, used) => {
    if (limit === 'unlimited')
        return 'unlimited';
    return Math.max(limit - used, 0);
};
const shouldReset = (record, now) => record.resetAt.getTime() <= now.getTime();
const resetUsage = async (prisma, record, now) => prisma.subscriptionQuota.update({
    where: { userId: record.userId },
    data: {
        messagesUsed: 0,
        callsUsed: 0,
        attachmentsUsed: 0,
        resetAt: (0, quota_config_1.nextResetDate)(now),
    },
});
const evaluateQuota = (limits, usage, action) => {
    switch (action) {
        case 'message': {
            if (limits.messages === 'unlimited') {
                return { allowed: true, remaining: 'unlimited', usagePercent: 0 };
            }
            const used = usage.messagesUsed;
            const remaining = messageRemaining(limits.messages, used);
            const usagePercent = limits.messages === 0 ? 1 : used / limits.messages;
            if (remaining === 0) {
                return { allowed: false, reason: 'Message quota exceeded', remaining: 0 };
            }
            return { allowed: true, remaining, usagePercent };
        }
        case 'call': {
            const remaining = limits.calls - usage.callsUsed;
            if (remaining <= 0) {
                return { allowed: false, reason: 'Video call quota exceeded', remaining: 0 };
            }
            return { allowed: true, remaining, usagePercent: usage.callsUsed / limits.calls };
        }
        case 'attachment': {
            if (!limits.chatAttachments) {
                return { allowed: false, reason: 'Attachments require Premium subscription' };
            }
            return { allowed: true, remaining: limits.chatAttachments ? Infinity : 0 };
        }
        default:
            return { allowed: false, reason: 'Unsupported action' };
    }
};
exports.evaluateQuota = evaluateQuota;
const ensureQuotaRecord = async (prisma, userId, tierOverride) => {
    const now = new Date();
    const record = await prisma.subscriptionQuota.findUnique({ where: { userId } });
    if (!record) {
        const tier = tierOverride ?? 'freemium';
        const limits = quota_config_1.TIER_QUOTAS[tier];
        return prisma.subscriptionQuota.create({
            data: {
                userId,
                tier,
                resetAt: (0, quota_config_1.nextResetDate)(now),
                nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
                nutritionLocked: !limits.nutritionPersistent,
            },
        });
    }
    let updated = record;
    if (tierOverride && record.tier !== tierOverride) {
        const limits = quota_config_1.TIER_QUOTAS[tierOverride];
        updated = await prisma.subscriptionQuota.update({
            where: { userId },
            data: {
                tier: tierOverride,
                nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
            },
        });
    }
    if (shouldReset(updated, now)) {
        updated = await resetUsage(prisma, updated, now);
    }
    return updated;
};
exports.ensureQuotaRecord = ensureQuotaRecord;
const getQuotaSnapshot = async (prisma, userId, tierOverride) => {
    const quota = await (0, exports.ensureQuotaRecord)(prisma, userId, tierOverride);
    const limits = quota_config_1.TIER_QUOTAS[quota.tier];
    return {
        userId,
        tier: quota.tier,
        usage: {
            messagesUsed: quota.messagesUsed,
            callsUsed: quota.callsUsed,
            attachmentsUsed: quota.attachmentsUsed,
            resetAt: quota.resetAt.toISOString(),
        },
        limits,
    };
};
exports.getQuotaSnapshot = getQuotaSnapshot;
const checkQuota = async (prisma, userId, action, tierOverride) => {
    const quota = await (0, exports.ensureQuotaRecord)(prisma, userId, tierOverride);
    const limits = quota_config_1.TIER_QUOTAS[quota.tier];
    const evaluation = (0, exports.evaluateQuota)(limits, quota, action);
    const warning = evaluation.allowed && evaluation.usagePercent !== undefined && evaluation.usagePercent >= quota_config_1.quotaWarningThreshold;
    return {
        ...evaluation,
        warning,
    };
};
exports.checkQuota = checkQuota;
const consumeQuota = async (prisma, userId, action, tierOverride) => {
    const quota = await (0, exports.ensureQuotaRecord)(prisma, userId, tierOverride);
    const limits = quota_config_1.TIER_QUOTAS[quota.tier];
    const evaluation = (0, exports.evaluateQuota)(limits, quota, action);
    if (!evaluation.allowed) {
        return { allowed: false, reason: evaluation.reason };
    }
    const data = {};
    if (action === 'message' && limits.messages !== 'unlimited') {
        data.messagesUsed = quota.messagesUsed + 1;
    }
    if (action === 'call') {
        data.callsUsed = quota.callsUsed + 1;
    }
    if (action === 'attachment') {
        data.attachmentsUsed = quota.attachmentsUsed + 1;
    }
    const updated = await prisma.subscriptionQuota.update({ where: { userId }, data });
    return { allowed: true, usage: updated };
};
exports.consumeQuota = consumeQuota;
const mapTierFromPlan = (planCode) => {
    switch (planCode) {
        case 'smart_premium':
        case 'smart-premium':
        case 'smartPremium':
            return 'smart_premium';
        case 'premium':
            return 'premium';
        default:
            return 'freemium';
    }
};
exports.mapTierFromPlan = mapTierFromPlan;
//# sourceMappingURL=quota.service.js.map