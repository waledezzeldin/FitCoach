const nutritionController = require('../../src/controllers/nutritionController');
const db = require('../../src/database');
const nutritionAccessService = require('../../src/services/nutritionAccessService');
const { mockRequest, mockResponse, createTestUser, createTestNutritionPlan } = require('../helpers/testHelpers');

jest.mock('../../src/database');
jest.mock('../../src/services/nutritionAccessService', () => ({
  checkAccess: jest.fn(),
  checkAndUnlockIfFirstWorkout: jest.fn()
}));

describe('NutritionController', () => {
  let req, res;

  beforeEach(() => {
    req = mockRequest();
    res = mockResponse();
    jest.clearAllMocks();
  });

  describe('getUserPlans', () => {
    it('should get user nutrition plans with progress', async () => {
      const testUser = createTestUser();
      req.user = { userId: testUser.id };

      const mockPlans = [
        {
          ...createTestNutritionPlan(),
          total_days: 7,
          total_meals: 21,
          completed_meals: 10,
          completion_percentage: 47.62
        }
      ];

      req.nutritionAccess = {
        hasAccess: true,
        tier: 'premium',
        isTrialActive: false,
        daysRemaining: null,
        trialExpiresAt: null
      };

      db.query.mockResolvedValue({ rows: mockPlans });

      await nutritionController.getUserPlans(req, res);

      expect(db.query).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        plans: mockPlans,
        accessInfo: {
          hasAccess: true,
          tier: 'premium',
          isTrialActive: false,
          daysRemaining: null,
          expiresAt: null
        }
      });
    });

    it('should handle database errors', async () => {
      req.user = { userId: 'test-user-id' };

      db.query.mockRejectedValue(new Error('Database error'));

      await nutritionController.getUserPlans(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Failed to get nutrition plans'
      });
    });
  });

  describe('getPlanById', () => {
    it('should get nutrition plan by ID with meals', async () => {
      const testPlan = createTestNutritionPlan();
      const testUser = createTestUser({ id: testPlan.user_id });
      req.user = { userId: testUser.id };
      req.params = { id: testPlan.id };

      const mockDays = [
        {
          id: 'day-1',
          day_number: 1,
          day_name: 'Monday',
          meals: [
            {
              id: 'meal-1',
              name: 'Breakfast',
              type: 'breakfast',
              calories: 500,
              protein: 30,
              carbs: 50,
              fats: 15
            }
          ]
        }
      ];

      db.query
        .mockResolvedValueOnce({ rows: [testPlan] }) // Get plan
        .mockResolvedValueOnce({ rows: mockDays }); // Get days with meals

      await nutritionController.getPlanById(req, res);

      expect(db.query).toHaveBeenCalledTimes(2);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        plan: expect.objectContaining({
          id: testPlan.id,
          days: mockDays
        }),
        trialDaysRemaining: null
      });
    });

    it('should return 404 if plan not found', async () => {
      req.user = { userId: 'test-user-id' };
      req.params = { id: 'non-existent' };

      db.query.mockResolvedValue({ rows: [] });

      await nutritionController.getPlanById(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Nutrition plan not found'
      });
    });

    it('should return 403 for unauthorized access', async () => {
      const testPlan = createTestNutritionPlan({ user_id: 'different-user' });
      req.user = { userId: 'test-user-id', role: 'user' };
      req.params = { id: testPlan.id };

      db.query.mockResolvedValue({ rows: [testPlan] });

      await nutritionController.getPlanById(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Unauthorized'
      });
    });
  });

  describe('completeMeal', () => {
    it('should mark meal as complete', async () => {
      req.params = { id: 'test-plan-id', mealId: 'test-meal-id' };

      db.query.mockResolvedValue({ rowCount: 1 });

      await nutritionController.completeMeal(req, res);

      expect(db.query).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Meal marked as complete'
      });
    });

    it('should handle errors', async () => {
      req.params = { id: 'test-plan-id', mealId: 'test-meal-id' };

      db.query.mockRejectedValue(new Error('Database error'));

      await nutritionController.completeMeal(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe('getAccessStatus', () => {
    it('should return access status', async () => {
      req.user = { userId: 'test-user-id' };

      const accessStatus = {
        hasAccess: true,
        tier: 'premium',
        isTrialActive: false,
        daysRemaining: null,
        trialExpiresAt: null
      };

      nutritionAccessService.checkAccess.mockResolvedValue(accessStatus);

      await nutritionController.getAccessStatus(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        access: accessStatus
      });
    });

    it('should handle access errors', async () => {
      req.user = { userId: 'test-user-id' };

      nutritionAccessService.checkAccess.mockRejectedValue(new Error('Access error'));

      await nutritionController.getAccessStatus(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Failed to get nutrition access status'
      });
    });
  });

  describe('createPlan', () => {
    it('should create nutrition plan with meals', async () => {
      req.user = { userId: 'test-coach-user-id' };
      req.body = {
        userId: 'test-user-id',
        name: 'Test Plan',
        description: 'Test description',
        dailyCalories: 2000,
        proteinTarget: 150,
        carbsTarget: 200,
        fatsTarget: 60,
        startDate: new Date(),
        endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        days: [
          {
            dayName: 'Monday',
            dayNumber: 1,
            notes: 'Test notes',
            meals: [
              {
                name: 'Breakfast',
                nameAr: 'فطور',
                nameEn: 'Breakfast',
                type: 'breakfast',
                time: '08:00',
                calories: 500,
                protein: 30,
                carbs: 50,
                fats: 15,
                instructions: 'Test instructions',
                instructionsAr: 'تعليمات',
                instructionsEn: 'Instructions'
              }
            ]
          }
        ]
      };

      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [createTestNutritionPlan()] }) // Insert plan
          .mockResolvedValueOnce({ rows: [{ id: 'day-1' }] }) // Insert day
          .mockResolvedValueOnce({ rows: [] }) // Insert meal
          .mockResolvedValueOnce({ rows: [] }), // COMMIT
        release: jest.fn()
      };

      db.getClient.mockResolvedValue(mockClient);

      await nutritionController.createPlan(req, res);

      expect(mockClient.query).toHaveBeenCalledWith('BEGIN');
      expect(mockClient.query).toHaveBeenCalledWith('COMMIT');
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true,
          message: 'Nutrition plan created successfully'
        })
      );
    });

    it('should rollback on error', async () => {
      req.user = { userId: 'test-coach-user-id' };
      req.body = {
        userId: 'test-user-id',
        name: 'Test Plan',
        days: []
      };

      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockRejectedValueOnce(new Error('Database error')), // Insert plan fails
        release: jest.fn()
      };

      db.getClient.mockResolvedValue(mockClient);

      await nutritionController.createPlan(req, res);

      expect(mockClient.query).toHaveBeenCalledWith('ROLLBACK');
      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe('updatePlan', () => {
    it('should update nutrition plan', async () => {
      req.params = { id: 'test-plan-id' };
      req.body = {
        name: 'Updated Plan',
        dailyCalories: 2200
      };

      const updatedPlan = createTestNutritionPlan({
        name: 'Updated Plan',
        daily_calories: 2200
      });

      db.query.mockResolvedValue({ rows: [updatedPlan] });

      await nutritionController.updatePlan(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Nutrition plan updated successfully',
        plan: updatedPlan
      });
    });
  });

  describe('deletePlan', () => {
    it('should delete nutrition plan', async () => {
      req.params = { id: 'test-plan-id' };

      db.query.mockResolvedValue({ rowCount: 1 });

      await nutritionController.deletePlan(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Nutrition plan deleted successfully'
      });
    });
  });
});
