const request = require('supertest');
const express = require('express');
const userRoutes = require('../../src/routes/users');
const workoutRoutes = require('../../src/routes/workouts');
const db = require('../../src/database');
const intakeService = require('../../src/services/intakeService');
const userProfileService = require('../../src/services/userProfileService');

jest.mock('../../src/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(),
  pool: { connect: jest.fn() }
}));

jest.mock('../../src/services/intakeService');
jest.mock('../../src/services/userProfileService');

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = { userId: 'user-1', role: 'user', tier: 'freemium' };
    next();
  },
  roleCheck: () => (req, res, next) => next(),
  tierCheck: () => (req, res, next) => next()
}));

describe('Intake & Workout Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/users', userRoutes);
    app.use('/v2/workouts', workoutRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('POST /v2/users/intake/first returns profile', async () => {
    intakeService.submitStage1.mockResolvedValue({});
    userProfileService.getUserProfileForApp.mockResolvedValue({ success: true, user: { id: 'user-1' } });
    db.query.mockResolvedValue({ rows: [] });

    const response = await request(app)
      .post('/v2/users/intake/first')
      .send({
        gender: 'male',
        mainGoal: 'lose_weight',
        workoutLocation: 'at_home'
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  it('POST /v2/users/intake/second returns profile', async () => {
    intakeService.submitStage2.mockResolvedValue({});
    userProfileService.getUserProfileForApp.mockResolvedValue({ success: true, user: { id: 'user-1' } });
    db.query.mockResolvedValue({ rows: [] });

    const response = await request(app)
      .post('/v2/users/intake/second')
      .send({
        age: 30,
        weight: 80,
        height: 175,
        experienceLevel: 'intermediate',
        workoutFrequency: 4,
        injuries: ['knee']
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  it('GET /v2/workouts/plan returns active plan', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [{ id: 'plan-1' }] })
      .mockResolvedValueOnce({ rows: [{ id: 'plan-1', user_id: 'user-1', coach_id: 'coach-1', name: 'Plan', description: null, start_date: '2026-02-01', is_active: true }] })
      .mockResolvedValueOnce({
        rows: [
          {
            id: 'day-1',
            day_name: 'Day 1',
            day_name_ar: null,
            day_number: 1,
            notes: null,
            exercises: [
              {
                id: 'ex-1',
                exerciseId: 'ex-1',
                name: 'Squat',
                nameAr: null,
                nameEn: 'Squat',
                category: null,
                muscleGroup: null,
                equipment: null,
                difficulty: null,
                videoUrl: null,
                thumbnailUrl: null,
                instructions: null,
                instructionsAr: null,
                instructionsEn: null,
                sets: 3,
                reps: '10',
                restTime: 60,
                tempo: null,
                notes: null,
                contraindications: [],
                alternatives: [],
                isCompleted: false,
                order: 1
              }
            ]
          }
        ]
      });

    const response = await request(app)
      .get('/v2/workouts/plan');

    expect(response.status).toBe(200);
    expect(response.body.id).toBe('plan-1');
    expect(response.body.days.length).toBe(1);
  });
});
