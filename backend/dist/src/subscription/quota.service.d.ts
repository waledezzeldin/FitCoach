import { PrismaClient, SubscriptionQuota, SubscriptionTier } from '@prisma/client';
import { QuotaLimits } from './quota.config';
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
export declare const evaluateQuota: (limits: QuotaLimits, usage: SubscriptionQuota, action: QuotaAction) => QuotaEvaluation;
export declare const ensureQuotaRecord: (prisma: PrismaClient, userId: string, tierOverride?: SubscriptionTier) => Promise<SubscriptionQuota>;
export declare const getQuotaSnapshot: (prisma: PrismaClient, userId: string, tierOverride?: SubscriptionTier) => Promise<QuotaSnapshot>;
export declare const checkQuota: (prisma: PrismaClient, userId: string, action: QuotaAction, tierOverride?: SubscriptionTier) => Promise<{
    warning: boolean;
    allowed: boolean;
    reason?: string;
    remaining?: number | "unlimited";
    usagePercent?: number;
}>;
export declare const consumeQuota: (prisma: PrismaClient, userId: string, action: QuotaAction, tierOverride?: SubscriptionTier) => Promise<{
    allowed: boolean;
    reason: string;
    usage?: undefined;
} | {
    allowed: boolean;
    usage: {
        id: string;
        userId: string;
        createdAt: Date;
        updatedAt: Date;
        tier: import(".prisma/client").$Enums.SubscriptionTier;
        messagesUsed: number;
        callsUsed: number;
        attachmentsUsed: number;
        resetAt: Date;
        nutritionWindowDays: number | null;
        nutritionExpiresAt: Date | null;
        nutritionLocked: boolean;
    };
    reason?: undefined;
}>;
export declare const mapTierFromPlan: (planCode?: string | null) => SubscriptionTier;
