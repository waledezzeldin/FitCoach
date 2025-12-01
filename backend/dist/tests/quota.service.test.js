"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const globals_1 = require("@jest/globals");
const quota_service_1 = require("../src/subscription/quota.service");
const quota_config_1 = require("../src/subscription/quota.config");
const mockQuota = (overrides = {}) => ({
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
(0, globals_1.describe)('evaluateQuota', () => {
    (0, globals_1.it)('allows messages while under limit', () => {
        const limits = quota_config_1.TIER_QUOTAS.freemium;
        const result = (0, quota_service_1.evaluateQuota)(limits, mockQuota({ messagesUsed: 10 }), 'message');
        (0, globals_1.expect)(result.allowed).toBe(true);
        (0, globals_1.expect)(result.remaining).toBe(10);
    });
    (0, globals_1.it)('blocks messages when limit reached', () => {
        const limits = quota_config_1.TIER_QUOTAS.freemium;
        const result = (0, quota_service_1.evaluateQuota)(limits, mockQuota({ messagesUsed: 20 }), 'message');
        (0, globals_1.expect)(result.allowed).toBe(false);
        (0, globals_1.expect)(result.reason).toMatch(/quota/i);
    });
    (0, globals_1.it)('treats smart premium messages as unlimited', () => {
        const limits = quota_config_1.TIER_QUOTAS.smart_premium;
        const result = (0, quota_service_1.evaluateQuota)(limits, mockQuota({ tier: 'smart_premium' }), 'message');
        (0, globals_1.expect)(result.allowed).toBe(true);
        (0, globals_1.expect)(result.remaining).toBe('unlimited');
    });
    (0, globals_1.it)('blocks attachments for freemium tier', () => {
        const limits = quota_config_1.TIER_QUOTAS.freemium;
        const result = (0, quota_service_1.evaluateQuota)(limits, mockQuota(), 'attachment');
        (0, globals_1.expect)(result.allowed).toBe(false);
        (0, globals_1.expect)(result.reason).toContain('Attachments');
    });
    (0, globals_1.it)('allows attachments for premium tiers', () => {
        const limits = quota_config_1.TIER_QUOTAS.premium;
        const result = (0, quota_service_1.evaluateQuota)(limits, mockQuota({ tier: 'premium' }), 'attachment');
        (0, globals_1.expect)(result.allowed).toBe(true);
    });
});
//# sourceMappingURL=quota.service.test.js.map