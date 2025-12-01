import request from 'supertest';
import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import app from '../src/main';
import { getAlternativesForInjury } from '../src/workouts/injury-map';

jest.mock('../src/workouts/injury-map', () => ({
  getAlternativesForInjury: jest.fn(),
}));

type WorkoutsPrismaMocks = {
  workoutLogCreate: jest.MockedFunction<(args?: any) => Promise<any>>;
};

function ensureWorkoutsPrismaMocks(): WorkoutsPrismaMocks {
  if (!(globalThis as any).__workoutsPrismaMocks) {
    (globalThis as any).__workoutsPrismaMocks = {
      workoutLogCreate: jest.fn<(args?: any) => Promise<any>>(),
    } satisfies WorkoutsPrismaMocks;
  }
  return (globalThis as any).__workoutsPrismaMocks as WorkoutsPrismaMocks;
}

jest.mock('@prisma/client', () => {
  const actual = jest.requireActual<typeof import('@prisma/client')>('@prisma/client');
  return {
    ...actual,
    PrismaClient: jest.fn(() => {
      const mocks = ensureWorkoutsPrismaMocks();
      return {
        workoutLog: { create: mocks.workoutLogCreate },
      };
    }),
  };
});

const workoutMocks = ensureWorkoutsPrismaMocks();
const mockWorkoutLogCreate = workoutMocks.workoutLogCreate;

describe('Workouts Controller', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    ensureWorkoutsPrismaMocks().workoutLogCreate.mockReset();
  });

  it('requires an injuryArea when fetching alternatives', async () => {
    const res = await request(app).get('/v1/workouts/alternatives');
    expect(res.status).toBe(400);
    expect(res.body.error).toMatch(/injuryArea is required/);
  });

  it('returns mapped alternatives for valid queries', async () => {
    (getAlternativesForInjury as jest.Mock).mockReturnValue([
      { id: 'alt-1', name: 'Seated Row', muscleGroup: 'back' },
    ]);

    const res = await request(app).get('/v1/workouts/alternatives').query({ injuryArea: 'shoulder', muscleGroup: 'back' });

    expect(res.status).toBe(200);
    expect(res.body.alternatives).toHaveLength(1);
    expect(getAlternativesForInjury).toHaveBeenCalledWith('shoulder', 'back');
  });

  it('records workout swaps', async () => {
    mockWorkoutLogCreate.mockResolvedValue({ id: 'log-1' });

    const res = await request(app)
      .post('/v1/workouts/swaps')
      .send({
        userId: 'user-1',
        originalExerciseId: 'ex-1',
        alternativeExerciseId: 'ex-2',
        sessionId: 'session-1',
      });

    expect(res.status).toBe(201);
    expect(mockWorkoutLogCreate).toHaveBeenCalled();
  });

  it('handles swap validation errors', async () => {
    const res = await request(app)
      .post('/v1/workouts/swaps')
      .send({ originalExerciseId: 'ex-1', alternativeExerciseId: 'ex-2' });

    expect(res.status).toBe(400);
    expect(mockWorkoutLogCreate).not.toHaveBeenCalled();
  });

  it('surfaces persistence failures when recording swaps', async () => {
    mockWorkoutLogCreate.mockRejectedValue(new Error('db down'));

    const res = await request(app)
      .post('/v1/workouts/swaps')
      .send({
        userId: 'user-1',
        originalExerciseId: 'ex-1',
        alternativeExerciseId: 'ex-2',
      });

    expect(res.status).toBe(500);
  });
});
