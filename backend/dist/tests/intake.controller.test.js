"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const supertest_1 = require("supertest");
const intake_controller_1 = require("../src/intake.controller");
const globals_1 = require("@jest/globals");
const mockFindUnique = globals_1.jest.fn();
const mockUpsert = globals_1.jest.fn();
const mockUpdate = globals_1.jest.fn();
(0, globals_1.describe)('Intake Controller', () => {
    const app = (0, express_1.default)();
    app.use(express_1.default.json());
    const router = (0, intake_controller_1.createIntakeRouter)({
        userIntake: {
            findUnique: mockFindUnique,
            upsert: mockUpsert,
            update: mockUpdate,
        },
    });
    app.use('/v1/intake', router);
    (0, globals_1.beforeEach)(() => {
        globals_1.jest.clearAllMocks();
    });
    (0, globals_1.it)('returns serialized intake for GET /v1/intake/:userId', async () => {
        const now = new Date('2025-01-01T00:00:00Z');
        mockFindUnique.mockResolvedValue({
            id: 'intake-1',
            userId: 'user-1',
            gender: 'female',
            mainGoal: 'general_fitness',
            workoutLocation: 'home',
            firstCompletedAt: now,
            age: 28,
            weightKg: 62,
            heightCm: 168,
            experienceLevel: 'intermediate',
            workoutFrequency: 4,
            injuries: ['knee'],
            secondCompletedAt: now,
            skippedSecond: false,
            createdAt: now,
            updatedAt: now,
        });
        const res = await (0, supertest_1.default)(app).get('/v1/intake/user-1').expect(200);
        (0, globals_1.expect)(mockFindUnique).toHaveBeenCalledWith({ where: { userId: 'user-1' } });
        (0, globals_1.expect)(res.body.intake.first).toMatchObject({
            gender: 'female',
            mainGoal: 'general_fitness',
            workoutLocation: 'home',
        });
        (0, globals_1.expect)(res.body.intake.second).toMatchObject({
            age: 28,
            workoutFrequency: 4,
            injuries: ['knee'],
        });
    });
    (0, globals_1.it)('validates required fields for POST /v1/intake/first', async () => {
        await (0, supertest_1.default)(app).post('/v1/intake/first').send({ userId: 'user-1' }).expect(400);
        (0, globals_1.expect)(mockUpsert).not.toHaveBeenCalled();
    });
    (0, globals_1.it)('persists first stage and returns payload', async () => {
        const now = new Date('2025-02-01T00:00:00Z');
        mockUpsert.mockResolvedValue({
            id: 'intake-1',
            userId: 'user-1',
            gender: 'male',
            mainGoal: 'build_muscle',
            workoutLocation: 'gym',
            firstCompletedAt: now,
            skippedSecond: false,
            age: null,
            weightKg: null,
            heightCm: null,
            experienceLevel: null,
            workoutFrequency: null,
            injuries: [],
            secondCompletedAt: null,
            createdAt: now,
            updatedAt: now,
        });
        const res = await (0, supertest_1.default)(app)
            .post('/v1/intake/first')
            .send({
            userId: 'user-1',
            gender: 'male',
            mainGoal: 'build_muscle',
            workoutLocation: 'gym',
            completedAt: now.toISOString(),
        })
            .expect(200);
        (0, globals_1.expect)(mockUpsert).toHaveBeenCalledWith({
            where: { userId: 'user-1' },
            update: globals_1.expect.objectContaining({
                gender: 'male',
                mainGoal: 'build_muscle',
                workoutLocation: 'gym',
                skippedSecond: false,
            }),
            create: globals_1.expect.objectContaining({ userId: 'user-1' }),
        });
        (0, globals_1.expect)(res.body.intake.first).toMatchObject({ mainGoal: 'build_muscle' });
    });
    (0, globals_1.it)('prevents second stage submission before first stage', async () => {
        mockFindUnique.mockResolvedValue(null);
        await (0, supertest_1.default)(app)
            .post('/v1/intake/second')
            .send({
            userId: 'user-1',
            age: 29,
            weight: 70,
            height: 172,
            experienceLevel: 'beginner',
            workoutFrequency: 3,
            injuries: [],
        })
            .expect(409);
        (0, globals_1.expect)(mockUpdate).not.toHaveBeenCalled();
    });
    (0, globals_1.it)('saves second stage when first stage exists', async () => {
        const now = new Date('2025-03-02T00:00:00Z');
        mockFindUnique.mockResolvedValue({ id: 'intake-1' });
        mockUpdate.mockResolvedValue({
            id: 'intake-1',
            userId: 'user-1',
            gender: 'male',
            mainGoal: 'build_muscle',
            workoutLocation: 'gym',
            firstCompletedAt: now,
            age: 29,
            weightKg: 70,
            heightCm: 172,
            experienceLevel: 'beginner',
            workoutFrequency: 3,
            injuries: [],
            secondCompletedAt: now,
            skippedSecond: false,
            createdAt: now,
            updatedAt: now,
        });
        const res = await (0, supertest_1.default)(app)
            .post('/v1/intake/second')
            .send({
            userId: 'user-1',
            age: 29,
            weight: 70,
            height: 172,
            experienceLevel: 'beginner',
            workoutFrequency: 3,
            injuries: ['ankle'],
        })
            .expect(200);
        (0, globals_1.expect)(mockUpdate).toHaveBeenCalledWith({
            where: { userId: 'user-1' },
            data: globals_1.expect.objectContaining({
                age: 29,
                weightKg: 70,
                injuries: ['ankle'],
            }),
        });
        (0, globals_1.expect)(res.body.intake.second).toMatchObject({ experienceLevel: 'beginner' });
    });
    (0, globals_1.it)('marks second stage as skipped', async () => {
        const now = new Date('2025-04-01T00:00:00Z');
        mockUpsert.mockResolvedValue({
            id: 'intake-1',
            userId: 'user-1',
            gender: null,
            mainGoal: null,
            workoutLocation: null,
            firstCompletedAt: null,
            age: null,
            weightKg: null,
            heightCm: null,
            experienceLevel: null,
            workoutFrequency: null,
            injuries: [],
            secondCompletedAt: null,
            skippedSecond: true,
            createdAt: now,
            updatedAt: now,
        });
        const res = await (0, supertest_1.default)(app)
            .post('/v1/intake/skip-second')
            .send({ userId: 'user-1' })
            .expect(200);
        (0, globals_1.expect)(mockUpsert).toHaveBeenCalledWith({
            where: { userId: 'user-1' },
            update: globals_1.expect.objectContaining({ skippedSecond: true }),
            create: globals_1.expect.objectContaining({ skippedSecond: true }),
        });
        (0, globals_1.expect)(res.body.intake.skippedSecond).toBe(true);
    });
});
//# sourceMappingURL=intake.controller.test.js.map