"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const supertest_1 = require("supertest");
const globals_1 = require("@jest/globals");
const demo_controller_1 = require("../src/demo.controller");
const payments_controller_1 = require("../src/payments.controller");
const notifications_controller_1 = require("../src/notifications.controller");
const demo_mode_guard_1 = require("../src/middleware/demo-mode.guard");
const mockSendPush = globals_1.jest.fn();
const getPrismaMocks = () => globalThis.__prismaMocks;
globals_1.jest.mock('../src/notifications/push.service', () => ({
    sendPushNotification: (...args) => mockSendPush(...args),
}));
globals_1.jest.mock('@prisma/client', () => {
    const bucket = {
        paymentCreate: globals_1.jest.fn(),
        paymentFindMany: globals_1.jest.fn(),
        notificationFindMany: globals_1.jest.fn(),
        notificationCreate: globals_1.jest.fn(),
        notificationUpdate: globals_1.jest.fn(),
    };
    globalThis.__prismaMocks = bucket;
    return {
        PrismaClient: globals_1.jest.fn(() => ({
            payment: {
                create: bucket.paymentCreate,
                findMany: bucket.paymentFindMany,
            },
            notification: {
                findMany: bucket.notificationFindMany,
                create: bucket.notificationCreate,
                update: bucket.notificationUpdate,
            },
        })),
    };
});
const { paymentCreate: mockPaymentCreate, paymentFindMany: mockPaymentFindMany, notificationFindMany: mockNotificationFindMany, notificationCreate: mockNotificationCreate, notificationUpdate: mockNotificationUpdate, } = getPrismaMocks();
const buildApp = () => {
    const app = (0, express_1.default)();
    app.use(express_1.default.json());
    app.use((0, demo_mode_guard_1.default)());
    app.use(demo_controller_1.default);
    app.use('/v1/payments', payments_controller_1.default);
    app.use('/v1/notifications', notifications_controller_1.default);
    app.post('/mutations', (_req, res) => res.status(201).json({ ok: true }));
    return app;
};
(0, globals_1.describe)('Demo fixtures & guard middleware', () => {
    (0, globals_1.beforeEach)(() => {
        globals_1.jest.clearAllMocks();
        mockPaymentCreate.mockResolvedValue({
            id: 'payment_1',
            status: 'pending',
        });
        mockNotificationCreate.mockResolvedValue({
            id: 'notification_1',
            read: false,
        });
        mockNotificationUpdate.mockResolvedValue({
            id: 'notification_1',
            read: true,
        });
    });
    (0, globals_1.it)('serves persona-specific fixtures', async () => {
        const res = await (0, supertest_1.default)(buildApp())
            .get('/v1/demo/fixtures?persona=coach')
            .expect(200);
        (0, globals_1.expect)(res.body.persona).toBe('coach');
        (0, globals_1.expect)(res.body.user).toMatchObject({ role: 'coach' });
        (0, globals_1.expect)(Array.isArray(res.body.availablePersonas)).toBe(true);
    });
    (0, globals_1.it)('blocks mutating routes when the demo header is present', async () => {
        await (0, supertest_1.default)(buildApp())
            .post('/mutations')
            .set('X-Demo-Mode', '1')
            .send({})
            .expect(403);
    });
    (0, globals_1.it)('allows mutations when no demo header is provided', async () => {
        await (0, supertest_1.default)(buildApp())
            .post('/mutations')
            .send({})
            .expect(201);
    });
    (0, globals_1.it)('simulates payments without hitting the database in demo mode', async () => {
        const res = await (0, supertest_1.default)(buildApp())
            .post('/v1/payments')
            .set('X-Demo-Mode', '1')
            .send({ userId: 'u1', amount: 25, provider: 'stripe' })
            .expect(200);
        (0, globals_1.expect)(res.body.demo).toBe(true);
        (0, globals_1.expect)(res.body.status).toBe('simulated');
        (0, globals_1.expect)(mockPaymentCreate).not.toHaveBeenCalled();
    });
    (0, globals_1.it)('persists payments normally outside demo mode', async () => {
        const app = buildApp();
        mockPaymentCreate.mockResolvedValueOnce({
            id: 'payment_live',
            userId: 'live',
            status: 'pending',
        });
        const res = await (0, supertest_1.default)(app)
            .post('/v1/payments')
            .send({ userId: 'live', amount: 10, provider: 'stripe' })
            .expect(201);
        (0, globals_1.expect)(res.body).toMatchObject({ id: 'payment_live' });
        (0, globals_1.expect)(mockPaymentCreate).toHaveBeenCalled();
    });
    (0, globals_1.it)('skips notification writes and push delivery inside demo mode', async () => {
        const res = await (0, supertest_1.default)(buildApp())
            .post('/v1/notifications')
            .set('X-Demo-Mode', '1')
            .send({ userId: 'u1', title: 'Hello', message: 'Demo', deviceToken: 'token' })
            .expect(200);
        (0, globals_1.expect)(res.body.demo).toBe(true);
        (0, globals_1.expect)(mockNotificationCreate).not.toHaveBeenCalled();
        (0, globals_1.expect)(mockSendPush).not.toHaveBeenCalled();
    });
});
//# sourceMappingURL=demo.guard.test.js.map