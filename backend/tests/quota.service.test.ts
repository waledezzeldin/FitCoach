import { describe, expect, it } from '@jest/globals';
import { evaluateQuota } from '../src/subscription/quota.service';
import { TIER_QUOTAS } from '../src/subscription/quota.config';

type SubscriptionQuota = {
  id: string;
  userId: string;
  tier: 'freemium' | 'premium' | 'smart_premium';
  messagesUsed: number;
  callsUsed: number;
  attachmentsUsed: number;
  resetAt: Date;
  nutritionWindowDays: number;
  nutritionExpiresAt: Date | null;
  nutritionLocked: boolean;
  createdAt: Date;
  updatedAt: Date;
};

const mockQuota = (overrides: Partial<SubscriptionQuota> = {}): SubscriptionQuota => ({
  id: 'quota-1',
  userId: 'user-1',
  tier: 'freemium',
  messagesUsed: 0,
  callsUsed: 0,
  attachmentsUsed: 0,
  resetAt: new Date(),
  nutritionWindowDays: 7,
  nutritionExpiresAt: null,
  nutritionLocked: true,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

describe('evaluateQuota', () => {
  it('allows messages while under limit', () => {
    const limits = TIER_QUOTAS.freemium;
    const result = evaluateQuota(limits, mockQuota({ messagesUsed: 10 }), 'message');
    expect(result.allowed).toBe(true);
    expect(result.remaining).toBe(10);
  });

  it('blocks messages when limit reached', () => {
    const limits = TIER_QUOTAS.freemium;
    const result = evaluateQuota(limits, mockQuota({ messagesUsed: 20 }), 'message');
    expect(result.allowed).toBe(false);
    expect(result.reason).toMatch(/quota/i);
  });

  it('treats smart premium messages as unlimited', () => {
    const limits = TIER_QUOTAS.smart_premium;
    const result = evaluateQuota(limits, mockQuota({ tier: 'smart_premium' }), 'message');
    expect(result.allowed).toBe(true);
    expect(result.remaining).toBe('unlimited');
  });

  it('blocks attachments for freemium tier', () => {
    const limits = TIER_QUOTAS.freemium;
    const result = evaluateQuota(limits, mockQuota(), 'attachment');
    expect(result.allowed).toBe(false);
    expect(result.reason).toContain('Attachments');
  });

  it('allows attachments for premium tiers', () => {
    const limits = TIER_QUOTAS.premium;
    const result = evaluateQuota(limits, mockQuota({ tier: 'premium' }), 'attachment');
    expect(result.allowed).toBe(true);
  });
});
