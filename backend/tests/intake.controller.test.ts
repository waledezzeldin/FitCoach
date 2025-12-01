import express from 'express';
import request from 'supertest';
import { createIntakeRouter } from '../src/intake.controller';
import { describe, it, expect, jest, beforeEach } from '@jest/globals';

const mockFindUnique: jest.Mock<any> = jest.fn();
const mockUpsert: jest.Mock<any> = jest.fn();
const mockUpdate: jest.Mock<any> = jest.fn();

describe('Intake Controller', () => {
    const app = express();
    app.use(express.json());
    const router = createIntakeRouter({
        userIntake: {
            findUnique: mockFindUnique,
            upsert: mockUpsert,
            update: mockUpdate,
        },
    } as any);
    app.use('/v1/intake', router);

    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('returns serialized intake for GET /v1/intake/:userId', async () => {
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

        const res = await request(app).get('/v1/intake/user-1').expect(200);
        expect(mockFindUnique).toHaveBeenCalledWith({ where: { userId: 'user-1' } });
        expect(res.body.intake.first).toMatchObject({
            gender: 'female',
            mainGoal: 'general_fitness',
            workoutLocation: 'home',
        });
        expect(res.body.intake.second).toMatchObject({
            age: 28,
            workoutFrequency: 4,
            injuries: ['knee'],
        });
    });

    it('validates required fields for POST /v1/intake/first', async () => {
        await request(app).post('/v1/intake/first').send({ userId: 'user-1' }).expect(400);
        expect(mockUpsert).not.toHaveBeenCalled();
    });

    it('persists first stage and returns payload', async () => {
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

        const res = await request(app)
            .post('/v1/intake/first')
            .send({
                userId: 'user-1',
                gender: 'male',
                mainGoal: 'build_muscle',
                workoutLocation: 'gym',
                completedAt: now.toISOString(),
            })
            .expect(200);

        expect(mockUpsert).toHaveBeenCalledWith({
            where: { userId: 'user-1' },
            update: expect.objectContaining({
                gender: 'male',
                mainGoal: 'build_muscle',
                workoutLocation: 'gym',
                skippedSecond: false,
            }),
            create: expect.objectContaining({ userId: 'user-1' }),
        });
        expect(res.body.intake.first).toMatchObject({ mainGoal: 'build_muscle' });
    });

    it('prevents second stage submission before first stage', async () => {
        mockFindUnique.mockResolvedValue(null);

        await request(app)
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
        expect(mockUpdate).not.toHaveBeenCalled();
    });

    it('saves second stage when first stage exists', async () => {
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

        const res = await request(app)
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

        expect(mockUpdate).toHaveBeenCalledWith({
            where: { userId: 'user-1' },
            data: expect.objectContaining({
                age: 29,
                weightKg: 70,
                injuries: ['ankle'],
            }),
        });
        expect(res.body.intake.second).toMatchObject({ experienceLevel: 'beginner' });
    });

    it('marks second stage as skipped', async () => {
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

        const res = await request(app)
            .post('/v1/intake/skip-second')
            .send({ userId: 'user-1' })
            .expect(200);

        expect(mockUpsert).toHaveBeenCalledWith({
            where: { userId: 'user-1' },
            update: expect.objectContaining({ skippedSecond: true }),
            create: expect.objectContaining({ skippedSecond: true }),
        });
        expect(res.body.intake.skippedSecond).toBe(true);
    });
});
// removed erroneous local beforeEach stub

