"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = require("supertest");
const globals_1 = require("@jest/globals");
const main_1 = require("../src/main");
const injury_map_1 = require("../src/workouts/injury-map");
globals_1.jest.mock('../src/workouts/injury-map', () => ({
    getAlternativesForInjury: globals_1.jest.fn(),
}));
function ensureWorkoutsPrismaMocks() {
    if (!globalThis.__workoutsPrismaMocks) {
        globalThis.__workoutsPrismaMocks = {
            workoutLogCreate: globals_1.jest.fn(),
        };
    }
    return globalThis.__workoutsPrismaMocks;
}
globals_1.jest.mock('@prisma/client', () => {
    const actual = globals_1.jest.requireActual('@prisma/client');
    return {
        ...actual,
        PrismaClient: globals_1.jest.fn(() => {
            const mocks = ensureWorkoutsPrismaMocks();
            return {
                workoutLog: { create: mocks.workoutLogCreate },
            };
        }),
    };
});
const workoutMocks = ensureWorkoutsPrismaMocks();
const mockWorkoutLogCreate = workoutMocks.workoutLogCreate;
(0, globals_1.describe)('Workouts Controller', () => {
    (0, globals_1.beforeEach)(() => {
        globals_1.jest.clearAllMocks();
        ensureWorkoutsPrismaMocks().workoutLogCreate.mockReset();
    });
    (0, globals_1.it)('requires an injuryArea when fetching alternatives', async () => {
        const res = await (0, supertest_1.default)(main_1.default).get('/v1/workouts/alternatives');
        (0, globals_1.expect)(res.status).toBe(400);
        (0, globals_1.expect)(res.body.error).toMatch(/injuryArea is required/);
    });
    (0, globals_1.it)('returns mapped alternatives for valid queries', async () => {
        injury_map_1.getAlternativesForInjury.mockReturnValue([
            { id: 'alt-1', name: 'Seated Row', muscleGroup: 'back' },
        ]);
        const res = await (0, supertest_1.default)(main_1.default).get('/v1/workouts/alternatives').query({ injuryArea: 'shoulder', muscleGroup: 'back' });
        (0, globals_1.expect)(res.status).toBe(200);
        (0, globals_1.expect)(res.body.alternatives).toHaveLength(1);
        (0, globals_1.expect)(injury_map_1.getAlternativesForInjury).toHaveBeenCalledWith('shoulder', 'back');
    });
    (0, globals_1.it)('records workout swaps', async () => {
        mockWorkoutLogCreate.mockResolvedValue({ id: 'log-1' });
        const res = await (0, supertest_1.default)(main_1.default)
            .post('/v1/workouts/swaps')
            .send({
            userId: 'user-1',
            originalExerciseId: 'ex-1',
            alternativeExerciseId: 'ex-2',
            sessionId: 'session-1',
        });
        (0, globals_1.expect)(res.status).toBe(201);
        (0, globals_1.expect)(mockWorkoutLogCreate).toHaveBeenCalled();
    });
    (0, globals_1.it)('handles swap validation errors', async () => {
        const res = await (0, supertest_1.default)(main_1.default)
            .post('/v1/workouts/swaps')
            .send({ originalExerciseId: 'ex-1', alternativeExerciseId: 'ex-2' });
        (0, globals_1.expect)(res.status).toBe(400);
        (0, globals_1.expect)(mockWorkoutLogCreate).not.toHaveBeenCalled();
    });
    (0, globals_1.it)('surfaces persistence failures when recording swaps', async () => {
        mockWorkoutLogCreate.mockRejectedValue(new Error('db down'));
        const res = await (0, supertest_1.default)(main_1.default)
            .post('/v1/workouts/swaps')
            .send({
            userId: 'user-1',
            originalExerciseId: 'ex-1',
            alternativeExerciseId: 'ex-2',
        });
        (0, globals_1.expect)(res.status).toBe(500);
    });
});
//# sourceMappingURL=workouts.controller.test.js.map