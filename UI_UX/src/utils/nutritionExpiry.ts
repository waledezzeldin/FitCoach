// Nutrition Plan Expiry Utilities

export interface NutritionPlan {
  id: string;
  generatedAt: Date;
  expiresAt: Date | null; // null = persistent (Premium+)
  isLocked: boolean;
}

export interface NutritionExpiryStatus {
  isExpired: boolean;
  isLocked: boolean;
  daysRemaining: number | null;
  hoursRemaining: number | null;
  canAccess: boolean;
  expiryMessage?: string;
}

export const checkNutritionExpiry = (
  plan: NutritionPlan | null,
  tier: 'Freemium' | 'Premium' | 'Smart Premium'
): NutritionExpiryStatus => {
  // No plan exists
  if (!plan) {
    return {
      isExpired: false,
      isLocked: true,
      daysRemaining: null,
      hoursRemaining: null,
      canAccess: false,
      expiryMessage: 'No nutrition plan generated'
    };
  }
  
  // Premium+ users have persistent access
  if (tier !== 'Freemium') {
    return {
      isExpired: false,
      isLocked: false,
      daysRemaining: null,
      hoursRemaining: null,
      canAccess: true
    };
  }
  
  // Freemium users: check expiry
  const now = new Date();
  const expiresAt = plan.expiresAt;
  
  if (!expiresAt) {
    // Shouldn't happen for Freemium, but handle gracefully
    return {
      isExpired: false,
      isLocked: false,
      daysRemaining: null,
      hoursRemaining: null,
      canAccess: true
    };
  }
  
  const timeRemaining = expiresAt.getTime() - now.getTime();
  const isExpired = timeRemaining <= 0;
  
  if (isExpired) {
    return {
      isExpired: true,
      isLocked: true,
      daysRemaining: 0,
      hoursRemaining: 0,
      canAccess: false,
      expiryMessage: 'Access expired - Upgrade to Premium to unlock'
    };
  }
  
  const daysRemaining = Math.ceil(timeRemaining / (1000 * 60 * 60 * 24));
  const hoursRemaining = Math.ceil(timeRemaining / (1000 * 60 * 60));
  
  return {
    isExpired: false,
    isLocked: false,
    daysRemaining,
    hoursRemaining,
    canAccess: true
  };
};

export const createNutritionPlan = (
  tier: 'Freemium' | 'Premium' | 'Smart Premium',
  windowDays: number = 7
): NutritionPlan => {
  const now = new Date();
  const id = `nutrition_${Date.now()}`;
  
  // Freemium: set expiry, Premium+: no expiry
  const expiresAt = tier === 'Freemium' 
    ? new Date(now.getTime() + windowDays * 24 * 60 * 60 * 1000)
    : null;
  
  return {
    id,
    generatedAt: now,
    expiresAt,
    isLocked: false
  };
};

export const regenerateNutritionPlan = (
  tier: 'Freemium' | 'Premium' | 'Smart Premium',
  windowDays: number = 7
): NutritionPlan => {
  // Regenerating creates a new plan with fresh expiry
  return createNutritionPlan(tier, windowDays);
};

export const unlockNutritionPlan = (plan: NutritionPlan): NutritionPlan => {
  // Called when user upgrades - removes expiry and unlocks
  return {
    ...plan,
    expiresAt: null,
    isLocked: false
  };
};

export const formatExpiryMessage = (status: NutritionExpiryStatus): string => {
  if (status.expiryMessage) {
    return status.expiryMessage;
  }
  
  if (!status.canAccess) {
    return 'Upgrade to Premium for unlimited access';
  }
  
  if (status.daysRemaining !== null) {
    if (status.daysRemaining === 0 && status.hoursRemaining !== null) {
      return `Expires in ${status.hoursRemaining} hour${status.hoursRemaining === 1 ? '' : 's'}`;
    }
    return `${status.daysRemaining} day${status.daysRemaining === 1 ? '' : 's'} remaining`;
  }
  
  return 'Unlimited access';
};
