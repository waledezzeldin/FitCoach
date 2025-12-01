"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const globals_1 = require("@jest/globals");
const nutrition_utils_1 = require("../src/nutrition/nutrition.utils");
const mockAccess = (overrides = {}) => ({
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
(0, globals_1.describe)('deriveExpiryDate', () => {
    (0, globals_1.it)('returns date for freemium window', () => {
        const generated = new Date('2025-01-01T00:00:00.000Z');
        const expiry = (0, nutrition_utils_1.deriveExpiryDate)('freemium', generated);
        (0, globals_1.expect)(expiry).not.toBeNull();
        (0, globals_1.expect)(expiry?.toISOString()).toBe('2025-01-08T00:00:00.000Z');
    });
    (0, globals_1.it)('returns null for premium tiers', () => {
        (0, globals_1.expect)((0, nutrition_utils_1.deriveExpiryDate)('premium', new Date())).toBeNull();
    });
});
(0, globals_1.describe)('buildExpiryStatus', () => {
    (0, globals_1.it)('locks expired freemium access', () => {
        const now = new Date();
        const expired = mockAccess({
            planGeneratedAt: new Date(now.getTime() - 10 * 24 * 60 * 60 * 1000),
            expiresAt: new Date(now.getTime() - 24 * 60 * 60 * 1000),
            locked: true,
        });
        const status = (0, nutrition_utils_1.buildExpiryStatus)(expired, 'freemium');
        (0, globals_1.expect)(status.isExpired).toBe(true);
        (0, globals_1.expect)(status.canAccess).toBe(false);
    });
    (0, globals_1.it)('grants unlimited access for premium tier', () => {
        const access = mockAccess();
        const status = (0, nutrition_utils_1.buildExpiryStatus)(access, 'premium');
        (0, globals_1.expect)(status.isExpired).toBe(false);
        (0, globals_1.expect)(status.canAccess).toBe(true);
        (0, globals_1.expect)(status.daysRemaining).toBeNull();
    });
});
(0, globals_1.describe)('formatStatusPayload', () => {
    (0, globals_1.it)('wraps plan metadata and status together', () => {
        const access = mockAccess({
            planGeneratedAt: new Date('2025-02-01T00:00:00.000Z'),
            expiresAt: new Date('2025-02-08T00:00:00.000Z'),
            locked: true,
            windowDays: 7,
        });
        const payload = (0, nutrition_utils_1.formatStatusPayload)(access, 'freemium');
        (0, globals_1.expect)(payload.plan.generatedAt).toBe('2025-02-01T00:00:00.000Z');
        (0, globals_1.expect)(payload.plan.expiresAt).toBe('2025-02-08T00:00:00.000Z');
        (0, globals_1.expect)(payload.plan.locked).toBe(true);
        (0, globals_1.expect)(payload.plan.windowDays).toBe(7);
        (0, globals_1.expect)(payload.status.isExpired).toBe(true);
    });
});
//# sourceMappingURL=nutrition.utils.test.js.map