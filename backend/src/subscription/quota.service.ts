import { PrismaClient, SubscriptionQuota, SubscriptionTier } from '@prisma/client';
import { MessageLimit, QuotaLimits, TIER_QUOTAS, nextResetDate, quotaWarningThreshold } from './quota.config';

export type QuotaAction = 'message' | 'call' | 'attachment';

export interface QuotaEvaluation {
  allowed: boolean;
  reason?: string;
  remaining?: number | 'unlimited';
  usagePercent?: number;
}

export interface QuotaSnapshot {
  userId: string;
  tier: SubscriptionTier;
  usage: {
    messagesUsed: number;
    callsUsed: number;
    attachmentsUsed: number;
    resetAt: string;
  };
  limits: QuotaLimits;
}

const messageRemaining = (limit: MessageLimit, used: number): number | 'unlimited' => {
  if (limit === 'unlimited') return 'unlimited';
  return Math.max(limit - used, 0);
};

const shouldReset = (record: SubscriptionQuota, now: Date): boolean => record.resetAt.getTime() <= now.getTime();

const resetUsage = async (prisma: PrismaClient, record: SubscriptionQuota, now: Date): Promise<SubscriptionQuota> =>
  prisma.subscriptionQuota.update({
    where: { userId: record.userId },
    data: {
      messagesUsed: 0,
      callsUsed: 0,
      attachmentsUsed: 0,
      resetAt: nextResetDate(now),
    },
  });

export const evaluateQuota = (
  limits: QuotaLimits,
  usage: SubscriptionQuota,
  action: QuotaAction,
): QuotaEvaluation => {
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

export const ensureQuotaRecord = async (
  prisma: PrismaClient,
  userId: string,
  tierOverride?: SubscriptionTier,
): Promise<SubscriptionQuota> => {
  const now = new Date();
  const record = await prisma.subscriptionQuota.findUnique({ where: { userId } });
  if (!record) {
    const tier = tierOverride ?? 'freemium';
    const limits = TIER_QUOTAS[tier];
    return prisma.subscriptionQuota.create({
      data: {
        userId,
        tier,
        resetAt: nextResetDate(now),
        nutritionWindowDays: limits.nutritionWindowDays ?? undefined,
        nutritionLocked: !limits.nutritionPersistent,
      },
    });
  }
  let updated = record;
  if (tierOverride && record.tier !== tierOverride) {
    const limits = TIER_QUOTAS[tierOverride];
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

export const getQuotaSnapshot = async (
  prisma: PrismaClient,
  userId: string,
  tierOverride?: SubscriptionTier,
): Promise<QuotaSnapshot> => {
  const quota = await ensureQuotaRecord(prisma, userId, tierOverride);
  const limits = TIER_QUOTAS[quota.tier];
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

export const checkQuota = async (
  prisma: PrismaClient,
  userId: string,
  action: QuotaAction,
  tierOverride?: SubscriptionTier,
) => {
  const quota = await ensureQuotaRecord(prisma, userId, tierOverride);
  const limits = TIER_QUOTAS[quota.tier];
  const evaluation = evaluateQuota(limits, quota, action);
  const warning =
    evaluation.allowed && evaluation.usagePercent !== undefined && evaluation.usagePercent >= quotaWarningThreshold;
  return {
    ...evaluation,
    warning,
  };
};

export const consumeQuota = async (
  prisma: PrismaClient,
  userId: string,
  action: QuotaAction,
  tierOverride?: SubscriptionTier,
) => {
  const quota = await ensureQuotaRecord(prisma, userId, tierOverride);
  const limits = TIER_QUOTAS[quota.tier];
  const evaluation = evaluateQuota(limits, quota, action);
  if (!evaluation.allowed) {
    return { allowed: false, reason: evaluation.reason };
  }
  const data: Partial<SubscriptionQuota> = {};
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

export const mapTierFromPlan = (planCode?: string | null): SubscriptionTier => {
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
