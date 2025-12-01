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

const addDays = (date: Date, days: number): Date => new Date(date.getTime() + days * 24 * 60 * 60 * 1000);

export const deriveExpiryDate = (tier: SubscriptionTier, generatedAt: Date): Date | null => {
  const windowDays = TIER_QUOTAS[tier].nutritionWindowDays;
  if (tier === 'freemium' && typeof windowDays === 'number') {
    return addDays(generatedAt, windowDays);
  }
  return null;
};

export const buildExpiryStatus = (record: NutritionAccess, tier: SubscriptionTier): NutritionExpiryStatus => {
  if (!record) {
    return {
      isExpired: false,
      isLocked: true,
      daysRemaining: null,
      hoursRemaining: null,
      canAccess: false,
      expiryMessage: 'Nutrition plan not generated',
    };
  }

  if (tier !== 'freemium') {
    return {
      isExpired: false,
      isLocked: false,
      daysRemaining: null,
      hoursRemaining: null,
      canAccess: true,
    };
  }

  const now = new Date();
  const expiresAt = record.expiresAt ?? deriveExpiryDate(tier, record.planGeneratedAt);
  if (!expiresAt) {
    return {
      isExpired: false,
      isLocked: false,
      daysRemaining: null,
      hoursRemaining: null,
      canAccess: true,
    };
  }

  const diff = expiresAt.getTime() - now.getTime();
  const isExpired = diff <= 0;

  if (isExpired) {
    return {
      isExpired: true,
      isLocked: true,
      daysRemaining: 0,
      hoursRemaining: 0,
      canAccess: false,
      expiryMessage: 'Access expired - upgrade to unlock',
    };
  }

  const daysRemaining = Math.ceil(diff / (1000 * 60 * 60 * 24));
  const hoursRemaining = Math.ceil(diff / (1000 * 60 * 60));

  return {
    isExpired: false,
    isLocked: false,
    daysRemaining,
    hoursRemaining,
    canAccess: true,
  };
};

export const formatStatusPayload = (record: NutritionAccess, tier: SubscriptionTier) => ({
  plan: {
    generatedAt: record.planGeneratedAt.toISOString(),
    expiresAt: record.expiresAt?.toISOString() ?? null,
    locked: record.locked,
    windowDays: record.windowDays ?? null,
  },
  status: buildExpiryStatus(record, tier),
});
