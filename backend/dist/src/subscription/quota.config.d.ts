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
export declare const TIER_QUOTAS: Record<SubscriptionTier, QuotaLimits>;
export declare const quotaWarningThreshold = 0.8;
export declare const nextResetDate: (from?: Date) => Date;
