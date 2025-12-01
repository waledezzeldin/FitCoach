"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatStatusPayload = exports.buildExpiryStatus = exports.deriveExpiryDate = void 0;
const quota_config_1 = require("../subscription/quota.config");
const addDays = (date, days) => new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
const deriveExpiryDate = (tier, generatedAt) => {
    const windowDays = quota_config_1.TIER_QUOTAS[tier].nutritionWindowDays;
    if (tier === 'freemium' && typeof windowDays === 'number') {
        return addDays(generatedAt, windowDays);
    }
    return null;
};
exports.deriveExpiryDate = deriveExpiryDate;
const buildExpiryStatus = (record, tier) => {
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
    const expiresAt = record.expiresAt ?? (0, exports.deriveExpiryDate)(tier, record.planGeneratedAt);
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
exports.buildExpiryStatus = buildExpiryStatus;
const formatStatusPayload = (record, tier) => ({
    plan: {
        generatedAt: record.planGeneratedAt.toISOString(),
        expiresAt: record.expiresAt?.toISOString() ?? null,
        locked: record.locked,
        windowDays: record.windowDays ?? null,
    },
    status: (0, exports.buildExpiryStatus)(record, tier),
});
exports.formatStatusPayload = formatStatusPayload;
//# sourceMappingURL=nutrition.utils.js.map