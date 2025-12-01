"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = require("supertest");
const globals_1 = require("@jest/globals");
const main_1 = require("../src/main");
function ensureHomePrismaMocks() {
    if (!globalThis.__homePrismaMocks) {
        globalThis.__homePrismaMocks = {
            userFindUnique: globals_1.jest.fn(),
            workoutFindMany: globals_1.jest.fn(),
            nutritionFindMany: globals_1.jest.fn(),
            sessionFindFirst: globals_1.jest.fn(),
            quotaFindUnique: globals_1.jest.fn(),
        };
    }
    return globalThis.__homePrismaMocks;
}
globals_1.jest.mock('@prisma/client', () => {
    const actual = globals_1.jest.requireActual('@prisma/client');
    return {
        ...actual,
        PrismaClient: globals_1.jest.fn(() => {
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
(0, globals_1.describe)('Home Controller', () => {
    (0, globals_1.beforeEach)(() => {
        globals_1.jest.clearAllMocks();
        Object.values(ensureHomePrismaMocks()).forEach((mock) => mock.mockReset());
    });
    (0, globals_1.it)('builds a home summary for existing users', async () => {
        const frozenNow = new Date('2025-12-01T12:00:00Z');
        globals_1.jest.useFakeTimers().setSystemTime(frozenNow);
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
            const res = await (0, supertest_1.default)(main_1.default).get('/v1/home/summary/user-1');
            (0, globals_1.expect)(res.status).toBe(200);
            (0, globals_1.expect)(res.body.quickStats.workoutsCompletedWeek).toBe(2);
            (0, globals_1.expect)(res.body.macros.protein.consumed).toBeGreaterThan(0);
            (0, globals_1.expect)(mockWorkoutFindMany).toHaveBeenCalled();
            (0, globals_1.expect)(mockNutritionFindMany).toHaveBeenCalledTimes(2);
        }
        finally {
            globals_1.jest.useRealTimers();
        }
    });
    (0, globals_1.it)('returns 404 when user is missing', async () => {
        mockUserFindUnique.mockResolvedValue(null);
        const res = await (0, supertest_1.default)(main_1.default).get('/v1/home/summary/user-missing');
        (0, globals_1.expect)(res.status).toBe(404);
        (0, globals_1.expect)(res.body.error).toMatch(/User not found/);
    });
});
//# sourceMappingURL=home.controller.test.js.map