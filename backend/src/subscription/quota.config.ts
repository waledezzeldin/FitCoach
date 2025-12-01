import { SubscriptionTier } from '@prisma/client';

export type MessageLimit = number | 'unlimited';

export interface QuotaLimits {
  messages: MessageLimit;
  calls: number;
  callDuration: number;
  chatAttachments: boolean;
  nutritionPersistent: boolean;
  nutritionWindowDays: number | null;
}

export const TIER_QUOTAS: Record<SubscriptionTier, QuotaLimits> = {
  freemium: {
    messages: 20,
    calls: 1,
    callDuration: 15,
    chatAttachments: false,
    nutritionPersistent: false,
    nutritionWindowDays: 7,
  },
  premium: {
    messages: 200,
    calls: 2,
    callDuration: 25,
    chatAttachments: true,
    nutritionPersistent: true,
    nutritionWindowDays: null,
  },
  smart_premium: {
    messages: 'unlimited',
    calls: 4,
    callDuration: 25,
    chatAttachments: true,
    nutritionPersistent: true,
    nutritionWindowDays: null,
  },
};

export const quotaWarningThreshold = 0.8;

export const nextResetDate = (from: Date = new Date()): Date => {
  const year = from.getUTCFullYear();
  const month = from.getUTCMonth();
  return new Date(Date.UTC(year, month + 1, 1));
};
