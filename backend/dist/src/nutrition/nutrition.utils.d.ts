import { TIER_QUOTAS } from '../subscription/quota.config';
type SubscriptionTier = keyof typeof TIER_QUOTAS;
export interface NutritionAccess {
    planGeneratedAt: Date;
    expiresAt?: Date | null;
    locked: boolean;
    windowDays?: number | null;
}
export interface NutritionExpiryStatus {
    isExpired: boolean;
    isLocked: boolean;
    daysRemaining: number | null;
    hoursRemaining: number | null;
    canAccess: boolean;
    expiryMessage?: string;
}
export declare const deriveExpiryDate: (tier: SubscriptionTier, generatedAt: Date) => Date | null;
export declare const buildExpiryStatus: (record: NutritionAccess, tier: SubscriptionTier) => NutritionExpiryStatus;
export declare const formatStatusPayload: (record: NutritionAccess, tier: SubscriptionTier) => {
    plan: {
        generatedAt: string;
        expiresAt: string;
        locked: boolean;
        windowDays: number;
    };
    status: NutritionExpiryStatus;
};
export {};
