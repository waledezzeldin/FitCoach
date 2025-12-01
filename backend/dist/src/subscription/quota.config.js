"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.nextResetDate = exports.quotaWarningThreshold = exports.TIER_QUOTAS = void 0;
exports.TIER_QUOTAS = {
    freemium: {
        messages: 20,
        calls: 1,
        callDuration: 15,
        chatAttachments: false,
        nutritionPersistent: false,
        nutritionWindowDays: 7,
    },
    premium: {
        messages: 200,
        calls: 2,
        callDuration: 25,
        chatAttachments: true,
        nutritionPersistent: true,
        nutritionWindowDays: null,
    },
    smart_premium: {
        messages: 'unlimited',
        calls: 4,
        callDuration: 25,
        chatAttachments: true,
        nutritionPersistent: true,
        nutritionWindowDays: null,
    },
};
exports.quotaWarningThreshold = 0.8;
const nextResetDate = (from = new Date()) => {
    const year = from.getUTCFullYear();
    const month = from.getUTCMonth();
    return new Date(Date.UTC(year, month + 1, 1));
};
exports.nextResetDate = nextResetDate;
//# sourceMappingURL=quota.config.js.map