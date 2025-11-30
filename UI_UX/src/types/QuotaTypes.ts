// Quota Types for FitCoach+ v2.0

export type SubscriptionTier = 'Freemium' | 'Premium' | 'Smart Premium';

export interface QuotaLimits {
  messages: number | 'unlimited';
  calls: number;
  callDuration: number; // minutes
  chatAttachments: boolean;
  nutritionPersistent: boolean;
  nutritionWindowDays: number | null; // null = persistent
}

export interface QuotaUsage {
  messagesUsed: number;
  messagesTotal: number | 'unlimited';
  callsUsed: number;
  callsTotal: number;
  resetDate: Date; // Next monthly reset
}

export interface QuotaCheckResult {
  allowed: boolean;
  reason?: string;
  remaining?: number;
  showWarning?: boolean; // true if at 80%
}

// Tier configuration (server-side, but mirrored client-side)
export const TIER_QUOTAS: Record<SubscriptionTier, QuotaLimits> = {
  'Freemium': {
    messages: 20,
    calls: 1,
    callDuration: 15,
    chatAttachments: false,
    nutritionPersistent: false,
    nutritionWindowDays: 7
  },
  'Premium': {
    messages: 200,
    calls: 2,
    callDuration: 25,
    chatAttachments: true,
    nutritionPersistent: true,
    nutritionWindowDays: null
  },
  'Smart Premium': {
    messages: 'unlimited',
    calls: 4,
    callDuration: 25,
    chatAttachments: true,
    nutritionPersistent: true,
    nutritionWindowDays: null
  }
};

export const checkQuota = (
  tier: SubscriptionTier,
  usage: QuotaUsage,
  action: 'message' | 'call' | 'attachment'
): QuotaCheckResult => {
  const limits = TIER_QUOTAS[tier];
  
  switch (action) {
    case 'message': {
      if (limits.messages === 'unlimited') {
        return { allowed: true };
      }
      
      const remaining = limits.messages - usage.messagesUsed;
      
      if (remaining <= 0) {
        return {
          allowed: false,
          reason: 'Message quota exceeded',
          remaining: 0
        };
      }
      
      const usagePercent = (usage.messagesUsed / limits.messages) * 100;
      
      return {
        allowed: true,
        remaining,
        showWarning: usagePercent >= 80
      };
    }
    
    case 'call': {
      const remaining = limits.calls - usage.callsUsed;
      
      if (remaining <= 0) {
        return {
          allowed: false,
          reason: 'Video call quota exceeded',
          remaining: 0
        };
      }
      
      const usagePercent = (usage.callsUsed / limits.calls) * 100;
      
      return {
        allowed: true,
        remaining,
        showWarning: usagePercent >= 80
      };
    }
    
    case 'attachment': {
      if (!limits.chatAttachments) {
        return {
          allowed: false,
          reason: 'Attachments require Premium subscription'
        };
      }
      
      return { allowed: true };
    }
    
    default:
      return { allowed: false, reason: 'Unknown action' };
  }
};

export const initializeQuota = (tier: SubscriptionTier): QuotaUsage => {
  const limits = TIER_QUOTAS[tier];
  const now = new Date();
  const resetDate = new Date(now.getFullYear(), now.getMonth() + 1, 1); // First day of next month
  
  return {
    messagesUsed: 0,
    messagesTotal: limits.messages,
    callsUsed: 0,
    callsTotal: limits.calls,
    resetDate
  };
};
