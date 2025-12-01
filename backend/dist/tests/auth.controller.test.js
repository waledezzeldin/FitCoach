"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const supertest_1 = require("supertest");
const globals_1 = require("@jest/globals");
const mockUserFindUnique = globals_1.jest.fn();
const mockUserCreate = globals_1.jest.fn();
const mockUserUpdate = globals_1.jest.fn();
const mockVerifyIdToken = globals_1.jest.fn();
globals_1.jest.mock('@prisma/client', () => {
    return {
        PrismaClient: globals_1.jest.fn(() => ({
            user: {
                findUnique: mockUserFindUnique,
                create: mockUserCreate,
                update: mockUserUpdate,
            },
        })),
    };
});
globals_1.jest.mock('firebase-admin', () => ({
    apps: [],
    credential: { applicationDefault: globals_1.jest.fn(() => ({})) },
    initializeApp: globals_1.jest.fn(),
    auth: () => ({ verifyIdToken: mockVerifyIdToken }),
}));
const auth_controller_1 = require("../src/auth.controller");
process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'test-secret';
(0, globals_1.describe)('POST /auth/firebase/exchange', () => {
    const app = (0, express_1.default)();
    app.use(express_1.default.json());
    app.use(auth_controller_1.default);
    (0, globals_1.beforeEach)(() => {
        globals_1.jest.clearAllMocks();
    });
    (0, globals_1.it)('creates a new freemium user when phone is not mapped', async () => {
        mockVerifyIdToken.mockResolvedValue({
            phone_number: '+15551234567',
            name: 'Mina',
            email: null,
        });
        mockUserFindUnique.mockResolvedValue(null);
        mockUserCreate.mockResolvedValue({
            id: 'user_1',
            name: 'Mina',
            email: 'phone_15551234567@fitcoach.app',
            phone: '+15551234567',
            role: 'user',
        });
        const res = await (0, supertest_1.default)(app)
            .post('/auth/firebase/exchange')
            .send({ idToken: 'mock-token' })
            .expect(200);
        (0, globals_1.expect)(mockUserCreate).toHaveBeenCalledWith({
            data: globals_1.expect.objectContaining({
                phone: '+15551234567',
                role: 'user',
            }),
        });
        (0, globals_1.expect)(res.body.subscriptionType).toBe('freemium');
        (0, globals_1.expect)(res.body.user).toMatchObject({
            phone: '+15551234567',
            role: 'user',
        });
    });
    (0, globals_1.it)('promotes mapped phones to coach role and smart premium subscription', async () => {
        mockVerifyIdToken.mockResolvedValue({
            phone_number: '+966507654321',
            name: 'Coach Sarah',
            email: 'coach@fitcoach.com',
        });
        mockUserFindUnique.mockResolvedValue({
            id: 'coach_1',
            name: 'Coach Sarah',
            email: 'coach@fitcoach.com',
            phone: '+966507654321',
            role: 'user',
        });
        mockUserUpdate.mockResolvedValue({
            id: 'coach_1',
            name: 'Coach Sarah',
            email: 'coach@fitcoach.com',
            phone: '+966507654321',
            role: 'coach',
        });
        const res = await (0, supertest_1.default)(app)
            .post('/auth/firebase/exchange')
            .send({ idToken: 'coach-token' })
            .expect(200);
        (0, globals_1.expect)(mockUserUpdate).toHaveBeenCalledWith({
            where: { id: 'coach_1' },
            data: { role: 'coach' },
        });
        (0, globals_1.expect)(res.body.subscriptionType).toBe('smart_premium');
        (0, globals_1.expect)(res.body.user).toMatchObject({ role: 'coach' });
    });
    (0, globals_1.it)('rejects requests without an idToken', async () => {
        const res = await (0, supertest_1.default)(app)
            .post('/auth/firebase/exchange')
            .send({})
            .expect(400);
        (0, globals_1.expect)(res.body).toHaveProperty('error', 'idToken required.');
        (0, globals_1.expect)(mockVerifyIdToken).not.toHaveBeenCalled();
    });
});
//# sourceMappingURL=auth.controller.test.js.map