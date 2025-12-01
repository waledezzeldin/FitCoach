import request from 'supertest';
import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import app from '../src/main';

type HomePrismaMocks = {
  userFindUnique: jest.MockedFunction<(args?: any) => Promise<any>>;
  workoutFindMany: jest.MockedFunction<(args?: any) => Promise<any>>;
  nutritionFindMany: jest.MockedFunction<(args?: any) => Promise<any>>;
  sessionFindFirst: jest.MockedFunction<(args?: any) => Promise<any>>;
  quotaFindUnique: jest.MockedFunction<(args?: any) => Promise<any>>;
};

function ensureHomePrismaMocks(): HomePrismaMocks {
  if (!(globalThis as any).__homePrismaMocks) {
    (globalThis as any).__homePrismaMocks = {
      userFindUnique: jest.fn<(args?: any) => Promise<any>>(),
      workoutFindMany: jest.fn<(args?: any) => Promise<any>>(),
      nutritionFindMany: jest.fn<(args?: any) => Promise<any>>(),
      sessionFindFirst: jest.fn<(args?: any) => Promise<any>>(),
      quotaFindUnique: jest.fn<(args?: any) => Promise<any>>(),
    } satisfies HomePrismaMocks;
  }
  return (globalThis as any).__homePrismaMocks as HomePrismaMocks;
}

jest.mock('@prisma/client', () => {
  const actual = jest.requireActual<typeof import('@prisma/client')>('@prisma/client');
  return {
    ...actual,
    PrismaClient: jest.fn(() => {
      const mocks = ensureHomePrismaMocks();
      return {
        user: { findUnique: mocks.userFindUnique },
        workoutLog: { findMany: mocks.workoutFindMany },
        nutritionLog: { findMany: mocks.nutritionFindMany },
        session: { findFirst: mocks.sessionFindFirst },
        subscriptionQuota: { findUnique: mocks.quotaFindUnique },
      };
    }),
  };
});

const homePrismaMocks = ensureHomePrismaMocks();
const mockUserFindUnique = homePrismaMocks.userFindUnique;
const mockWorkoutFindMany = homePrismaMocks.workoutFindMany;
const mockNutritionFindMany = homePrismaMocks.nutritionFindMany;
const mockSessionFindFirst = homePrismaMocks.sessionFindFirst;
const mockQuotaFindUnique = homePrismaMocks.quotaFindUnique;

describe('Home Controller', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    Object.values(ensureHomePrismaMocks()).forEach((mock) => mock.mockReset());
  });

  it('builds a home summary for existing users', async () => {
    const frozenNow = new Date('2025-12-01T12:00:00Z');
    jest.useFakeTimers().setSystemTime(frozenNow);

    mockUserFindUnique.mockResolvedValue({
      id: 'user-1',
      subscriptionQuota: { tier: 'premium' },
      nutritionPreference: { dailyCalorieTarget: 2100 },
      intake: { createdAt: new Date('2025-11-01T00:00:00Z') },
      coach: { user: { name: 'Coach Carter', email: 'coach@example.com' } },
    });
    mockWorkoutFindMany.mockResolvedValue([
      { id: 'w1', date: new Date('2025-11-30T10:00:00Z'), duration: 45 },
      { id: 'w2', date: new Date('2025-11-29T08:00:00Z'), duration: 30 },
    ]);
    mockNutritionFindMany
      .mockResolvedValueOnce([
        { id: 'n1', date: new Date('2025-12-01T07:30:00Z'), calories: 500, protein: 40, carbs: 50, fats: 10 },
      ])
      .mockResolvedValueOnce([
        { id: 'n2', date: new Date('2025-11-30T07:30:00Z'), calories: 1800 },
      ]);
    mockSessionFindFirst.mockResolvedValue({
      id: 'sess-1',
      scheduledAt: new Date('2025-12-02T09:00:00Z'),
      durationMin: 30,
      status: 'scheduled',
      coach: { user: { name: 'Coach Carter' } },
    });
    mockQuotaFindUnique.mockResolvedValue({
      tier: 'premium',
      messagesUsed: 2,
      callsUsed: 0,
      attachmentsUsed: 0,
      resetAt: new Date('2025-12-15T00:00:00Z'),
    });

    try {
      const res = await request(app).get('/v1/home/summary/user-1');

      expect(res.status).toBe(200);
      expect(res.body.quickStats.workoutsCompletedWeek).toBe(2);
      expect(res.body.macros.protein.consumed).toBeGreaterThan(0);
      expect(mockWorkoutFindMany).toHaveBeenCalled();
      expect(mockNutritionFindMany).toHaveBeenCalledTimes(2);
    } finally {
      jest.useRealTimers();
    }
  });

  it('returns 404 when user is missing', async () => {
    mockUserFindUnique.mockResolvedValue(null);

    const res = await request(app).get('/v1/home/summary/user-missing');

    expect(res.status).toBe(404);
    expect(res.body.error).toMatch(/User not found/);
  });
});
