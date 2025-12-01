"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = require("supertest");
const globals_1 = require("@jest/globals");
const main_1 = require("../src/main");
const quota_service_1 = require("../src/subscription/quota.service");
function ensureCoachMessageMock() {
    if (!globalThis.__coachMessageCreate) {
        globalThis.__coachMessageCreate = globals_1.jest.fn();
    }
    return globalThis.__coachMessageCreate;
}
globals_1.jest.mock('@prisma/client', () => {
    const asyncMock = (value = null) => globals_1.jest.fn(async () => value);
    const createModelMock = () => ({
        findUnique: asyncMock(),
        findMany: asyncMock([]),
        findFirst: asyncMock(),
        create: asyncMock(),
        update: asyncMock(),
        delete: asyncMock(),
        count: asyncMock(0),
        aggregate: asyncMock({ _sum: { amount: 0 } }),
        groupBy: asyncMock([]),
    });
    return {
        PrismaClient: globals_1.jest.fn().mockImplementation(() => {
            const coachMessageCreate = ensureCoachMessageMock();
            const base = {
                coachMessage: { create: coachMessageCreate },
                session: createModelMock(),
                coach: createModelMock(),
                commission: createModelMock(),
                user: createModelMock(),
                userIntake: createModelMock(),
                milestone: createModelMock(),
                nutritionLog: createModelMock(),
                subscriptionQuota: createModelMock(),
                $transaction: globals_1.jest.fn(async (cb) => (typeof cb === 'function' ? cb(base) : null)),
                $connect: globals_1.jest.fn(),
                $disconnect: globals_1.jest.fn(),
                $use: globals_1.jest.fn(),
            };
            return new Proxy(base, {
                get(target, prop) {
                    if (prop in target) {
                        return target[prop];
                    }
                    const model = createModelMock();
                    target[prop] = model;
                    return model;
                },
            });
        }),
    };
});
globals_1.jest.mock('../src/subscription/quota.service', () => ({
    consumeQuota: globals_1.jest.fn(),
    getQuotaSnapshot: globals_1.jest.fn(),
}));
const mockConsumeQuota = quota_service_1.consumeQuota;
const mockGetQuotaSnapshot = quota_service_1.getQuotaSnapshot;
const coachMessageCreateMock = () => ensureCoachMessageMock();
(0, globals_1.describe)('Coach messaging routes', () => {
    (0, globals_1.beforeEach)(() => {
        coachMessageCreateMock().mockReset();
        mockConsumeQuota.mockReset();
        mockGetQuotaSnapshot.mockReset();
        mockGetQuotaSnapshot.mockImplementation(async () => null);
    });
    (0, globals_1.it)('allows members to send messages when quota permits it', async () => {
        mockConsumeQuota.mockImplementation(async () => ({ allowed: true }));
        coachMessageCreateMock().mockImplementation(async () => ({ id: 'msg-1' }));
        const res = await (0, supertest_1.default)(main_1.default)
            .post('/v1/coaches/coach-1/messages')
            .send({ userId: 'user-1', sender: 'user', body: 'Need help with macros' });
        (0, globals_1.expect)(res.status).toBe(201);
        (0, globals_1.expect)(mockConsumeQuota).toHaveBeenCalledTimes(1);
        (0, globals_1.expect)(mockConsumeQuota).toHaveBeenCalledWith(globals_1.expect.anything(), 'user-1', 'message');
        (0, globals_1.expect)(coachMessageCreateMock()).toHaveBeenCalledWith(globals_1.expect.objectContaining({
            data: globals_1.expect.objectContaining({ userId: 'user-1', sender: 'user', body: 'Need help with macros' }),
        }));
    });
    (0, globals_1.it)('blocks user messages when quota is exhausted', async () => {
        mockConsumeQuota.mockImplementation(async () => ({ allowed: false, reason: 'Message quota exceeded' }));
        const res = await (0, supertest_1.default)(main_1.default)
            .post('/v1/coaches/coach-1/messages')
            .send({ userId: 'user-1', sender: 'user', body: 'Anyone there?' });
        (0, globals_1.expect)(res.status).toBe(409);
        (0, globals_1.expect)(res.body.reason).toBe('Message quota exceeded');
        (0, globals_1.expect)(coachMessageCreateMock()).not.toHaveBeenCalled();
    });
    (0, globals_1.it)('applies attachment quota when files are uploaded', async () => {
        mockConsumeQuota
            .mockImplementationOnce(async () => ({ allowed: true }))
            .mockImplementationOnce(async () => ({ allowed: true }));
        coachMessageCreateMock().mockImplementation(async () => ({ id: 'msg-attachment' }));
        const res = await (0, supertest_1.default)(main_1.default)
            .post('/v1/coaches/coach-1/messages')
            .send({
            userId: 'user-2',
            sender: 'user',
            body: 'Sharing today\'s log',
            attachmentUrl: 'https://cdn.fitcoach.dev/logs/attachment.pdf',
            attachmentName: 'log.pdf',
        });
        (0, globals_1.expect)(res.status).toBe(201);
        (0, globals_1.expect)(mockConsumeQuota).toHaveBeenNthCalledWith(1, globals_1.expect.anything(), 'user-2', 'message');
        (0, globals_1.expect)(mockConsumeQuota).toHaveBeenNthCalledWith(2, globals_1.expect.anything(), 'user-2', 'attachment');
        (0, globals_1.expect)(coachMessageCreateMock()).toHaveBeenCalled();
    });
    (0, globals_1.it)('rejects payloads without user identifiers', async () => {
        const res = await (0, supertest_1.default)(main_1.default)
            .post('/v1/coaches/coach-1/messages')
            .send({ sender: 'coach', body: 'Reminder to stretch' });
        (0, globals_1.expect)(res.status).toBe(400);
        (0, globals_1.expect)(mockConsumeQuota).not.toHaveBeenCalled();
    });
});
//# sourceMappingURL=coaches.controller.test.js.map