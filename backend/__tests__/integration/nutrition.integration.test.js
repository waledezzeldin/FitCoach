const request = require('supertest');
const express = require('express');
const nutritionRoutes = require('../../src/routes/nutrition');
const db = require('../../src/database');
const { generateTestToken } = require('../helpers/testHelpers');

jest.mock('../../src/database');

describe('Nutrition Integration Tests', () => {
  let app;
  let userToken;
  let coachToken;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/nutrition', nutritionRoutes);

    userToken = generateTestToken('test-user-id', 'user', 'premium');
    coachToken = generateTestToken('test-coach-id', 'coach', 'smart_premium');
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /v2/nutrition', () => {
    it('should get user nutrition plans', async () => {
      const mockUser = {
        id: 'test-user-id',
        subscription_tier: 'premium',
        is_active: true
      };
      const mockAccess = {
        id: 'test-user-id',
        subscription_tier: 'premium',
        has_access: true,
        nutrition_access_unlocked_at: null,
        nutrition_access_expires_at: null,
        days_remaining: null
      };

      const mockPlans = [
        {
          id: 'plan-1',
          name: 'Test Plan',
          total_days: 7,
          total_meals: 21,
          completed_meals: 10,
          completion_percentage: 47.62
        }
      ];

      db.query
        .mockResolvedValueOnce({ rows: [mockUser] }) // Auth check
        .mockResolvedValueOnce({ rows: [mockAccess] }) // Access check
        .mockResolvedValueOnce({ rows: mockPlans }); // Get plans

      const response = await request(app)
        .get('/v2/nutrition')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toMatchObject({
        success: true,
        plans: expect.arrayContaining([
          expect.objectContaining({
            id: 'plan-1',
            name: 'Test Plan'
          })
        ])
      });
    });

    it('should block freemium users without trial', async () => {
      const freemiumToken = generateTestToken('freemium-user', 'user', 'freemium');

      const mockUser = {
        id: 'freemium-user',
        subscription_tier: 'freemium',
        is_active: true
      };
      const mockAccess = {
        id: 'freemium-user',
        subscription_tier: 'freemium',
        has_access: false,
        nutrition_access_unlocked_at: null,
        nutrition_access_expires_at: null,
        days_remaining: null
      };

      db.query
        .mockResolvedValueOnce({ rows: [mockUser] })
        .mockResolvedValueOnce({ rows: [mockAccess] });

      const response = await request(app)
        .get('/v2/nutrition')
        .set('Authorization', `Bearer ${freemiumToken}`);

      expect(response.status).toBe(403);
      expect(response.body.accessStatus).toMatchObject({
        hasAccess: false,
        requiresUpgrade: true
      });
    });
  });

  describe('GET /v2/nutrition/access-status', () => {
    it('should return access status', async () => {
      const mockUser = {
        id: 'test-user-id',
        subscription_tier: 'freemium',
        is_active: true
      };
      const mockAccess = {
        id: 'test-user-id',
        subscription_tier: 'freemium',
        has_access: true,
        nutrition_access_unlocked_at: new Date(),
        nutrition_access_expires_at: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
        days_remaining: 3
      };

      db.query
        .mockResolvedValueOnce({ rows: [mockUser] }) // Auth
        .mockResolvedValueOnce({ rows: [mockAccess] }); // Access status

      const response = await request(app)
        .get('/v2/nutrition/access-status')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toMatchObject({
        success: true,
        access: expect.objectContaining({
          hasAccess: true,
          tier: 'freemium',
          isTrialActive: true
        })
      });
    });
  });

  describe('GET /v2/nutrition/:id', () => {
    it('should get nutrition plan by ID', async () => {
      const mockUser = {
        id: 'test-user-id',
        subscription_tier: 'premium',
        is_active: true
      };
      const mockAccess = {
        id: 'test-user-id',
        subscription_tier: 'premium',
        has_access: true,
        nutrition_access_unlocked_at: null,
        nutrition_access_expires_at: null,
        days_remaining: null
      };

      const mockPlan = {
        id: 'plan-1',
        user_id: 'test-user-id',
        name: 'Test Plan',
        daily_calories: 2000
      };

      const mockDays = [
        {
          id: 'day-1',
          day_number: 1,
          meals: [
            {
              id: 'meal-1',
              name: 'Breakfast',
              calories: 500
            }
          ]
        }
      ];

      db.query
        .mockResolvedValueOnce({ rows: [mockUser] }) // Auth
        .mockResolvedValueOnce({ rows: [mockAccess] }) // Nutrition access
        .mockResolvedValueOnce({ rows: [mockPlan] }) // Get plan
        .mockResolvedValueOnce({ rows: mockDays }); // Get days

      const response = await request(app)
        .get('/v2/nutrition/plan-1')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toMatchObject({
        success: true,
        plan: expect.objectContaining({
          id: 'plan-1',
          days: expect.any(Array)
        })
      });
    });

    it('should return 404 for non-existent plan', async () => {
      const mockUser = {
        id: 'test-user-id',
        subscription_tier: 'premium',
        is_active: true
      };
      const mockAccess = {
        id: 'test-user-id',
        subscription_tier: 'premium',
        has_access: true,
        nutrition_access_unlocked_at: null,
        nutrition_access_expires_at: null,
        days_remaining: null
      };

      db.query
        .mockResolvedValueOnce({ rows: [mockUser] })
        .mockResolvedValueOnce({ rows: [mockAccess] })
        .mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .get('/v2/nutrition/non-existent')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(404);
    });
  });

  describe('POST /v2/nutrition/:id/meals/:mealId/complete', () => {
    it('should mark meal as complete', async () => {
      const mockUser = {
        id: 'test-user-id',
        subscription_tier: 'premium',
        is_active: true
      };
      const mockAccess = {
        id: 'test-user-id',
        subscription_tier: 'premium',
        has_access: true,
        nutrition_access_unlocked_at: null,
        nutrition_access_expires_at: null,
        days_remaining: null
      };

      db.query
        .mockResolvedValueOnce({ rows: [mockUser] })
        .mockResolvedValueOnce({ rows: [mockAccess] })
        .mockResolvedValueOnce({ rowCount: 1 });

      const response = await request(app)
        .post('/v2/nutrition/plan-1/meals/meal-1/complete')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        success: true,
        message: 'Meal marked as complete'
      });
    });
  });

  describe('POST /v2/nutrition', () => {
    it('should create nutrition plan (coach only)', async () => {
      const mockCoachUser = {
        id: 'test-coach-id',
        role: 'coach',
        is_active: true
      };

      const mockPlan = {
        id: 'new-plan-id',
        user_id: 'test-user-id',
        coach_id: 'coach-id',
        name: 'New Plan'
      };

      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [mockPlan] }) // Create plan
          .mockResolvedValueOnce({ rows: [] }), // COMMIT
        release: jest.fn()
      };

      db.query.mockResolvedValue({ rows: [mockCoachUser] });
      db.getClient.mockResolvedValue(mockClient);

      const response = await request(app)
        .post('/v2/nutrition')
        .set('Authorization', `Bearer ${coachToken}`)
        .send({
          userId: 'test-user-id',
          name: 'New Plan',
          description: 'Test description',
          dailyCalories: 2000,
          proteinTarget: 150,
          carbsTarget: 200,
          fatsTarget: 60,
          startDate: new Date(),
          endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
          days: []
        });

      expect(response.status).toBe(201);
      expect(response.body).toMatchObject({
        success: true,
        message: 'Nutrition plan created successfully'
      });
    });

    it('should return 403 for non-coach users', async () => {
      const mockUser = {
        id: 'test-user-id',
        role: 'user',
        is_active: true
      };

      db.query.mockResolvedValue({ rows: [mockUser] });

      const response = await request(app)
        .post('/v2/nutrition')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          userId: 'test-user-id',
          name: 'New Plan'
        });

      expect(response.status).toBe(403);
    });
  });

  describe('PUT /v2/nutrition/:id', () => {
    it('should update nutrition plan (coach only)', async () => {
      const mockCoachUser = {
        id: 'test-coach-id',
        role: 'coach',
        is_active: true
      };

      const updatedPlan = {
        id: 'plan-1',
        name: 'Updated Plan',
        daily_calories: 2200
      };

      db.query
        .mockResolvedValueOnce({ rows: [mockCoachUser] })
        .mockResolvedValueOnce({ rows: [updatedPlan] });

      const response = await request(app)
        .put('/v2/nutrition/plan-1')
        .set('Authorization', `Bearer ${coachToken}`)
        .send({
          name: 'Updated Plan',
          dailyCalories: 2200
        });

      expect(response.status).toBe(200);
      expect(response.body).toMatchObject({
        success: true,
        message: 'Nutrition plan updated successfully'
      });
    });
  });

  describe('DELETE /v2/nutrition/:id', () => {
    it('should delete nutrition plan (coach only)', async () => {
      const mockCoachUser = {
        id: 'test-coach-id',
        role: 'coach',
        is_active: true
      };

      db.query
        .mockResolvedValueOnce({ rows: [mockCoachUser] })
        .mockResolvedValueOnce({ rowCount: 1 });

      const response = await request(app)
        .delete('/v2/nutrition/plan-1')
        .set('Authorization', `Bearer ${coachToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        success: true,
        message: 'Nutrition plan deleted successfully'
      });
    });
  });
});
