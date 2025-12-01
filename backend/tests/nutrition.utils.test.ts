import { describe, expect, it } from '@jest/globals';
import { buildExpiryStatus, deriveExpiryDate, formatStatusPayload } from '../src/nutrition/nutrition.utils';

interface NutritionAccess {
  id: string;
  userId: string;
  planGeneratedAt: Date;
  expiresAt: Date | null;
  locked: boolean;
  windowDays: number;
  createdAt: Date;
  updatedAt: Date;
}

const mockAccess = (overrides: Partial<NutritionAccess> = {}): NutritionAccess => ({
  id: 'access-1',
  userId: 'user-1',
  planGeneratedAt: overrides.planGeneratedAt ?? new Date('2025-01-01T00:00:00.000Z'),
  expiresAt: null,
  locked: false,
  windowDays: 7,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

describe('deriveExpiryDate', () => {
  it('returns date for freemium window', () => {
    const generated = new Date('2025-01-01T00:00:00.000Z');
    const expiry = deriveExpiryDate('freemium', generated);
    expect(expiry).not.toBeNull();
    expect(expiry?.toISOString()).toBe('2025-01-08T00:00:00.000Z');
  });

  it('returns null for premium tiers', () => {
    expect(deriveExpiryDate('premium', new Date())).toBeNull();
  });
});

describe('buildExpiryStatus', () => {
  it('locks expired freemium access', () => {
    const now = new Date();
    const expired = mockAccess({
      planGeneratedAt: new Date(now.getTime() - 10 * 24 * 60 * 60 * 1000),
      expiresAt: new Date(now.getTime() - 24 * 60 * 60 * 1000),
      locked: true,
    });
    const status = buildExpiryStatus(expired, 'freemium');
    expect(status.isExpired).toBe(true);
    expect(status.canAccess).toBe(false);
  });

  it('grants unlimited access for premium tier', () => {
    const access = mockAccess();
    const status = buildExpiryStatus(access, 'premium');
    expect(status.isExpired).toBe(false);
    expect(status.canAccess).toBe(true);
    expect(status.daysRemaining).toBeNull();
  });
});

describe('formatStatusPayload', () => {
  it('wraps plan metadata and status together', () => {
    const access = mockAccess({
      planGeneratedAt: new Date('2025-02-01T00:00:00.000Z'),
      expiresAt: new Date('2025-02-08T00:00:00.000Z'),
      locked: true,
      windowDays: 7,
    });
    const payload = formatStatusPayload(access, 'freemium');
    expect(payload.plan.generatedAt).toBe('2025-02-01T00:00:00.000Z');
    expect(payload.plan.expiresAt).toBe('2025-02-08T00:00:00.000Z');
    expect(payload.plan.locked).toBe(true);
    expect(payload.plan.windowDays).toBe(7);
    expect(payload.status.isExpired).toBe(true);
  });
});
