const userController = require('../../src/controllers/userController');
const intakeService = require('../../src/services/intakeService');
const userProfileService = require('../../src/services/userProfileService');
const db = require('../../src/database');
const { mockRequest, mockResponse } = require('../helpers/testHelpers');

jest.mock('../../src/services/intakeService');
jest.mock('../../src/services/userProfileService');
jest.mock('../../src/database');

describe('UserController Intake Compatibility', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('maps goal/location for first intake', async () => {
    const req = mockRequest({
      user: { userId: 'user-1' },
      body: {
        gender: 'male',
        mainGoal: 'lose_weight',
        workoutLocation: 'at_home'
      }
    });
    const res = mockResponse();

    intakeService.submitStage1.mockResolvedValue({});
    userProfileService.getUserProfileForApp.mockResolvedValue({ success: true });
    db.query.mockResolvedValue({ rows: [] });

    await userController.submitFirstIntakeCompat(req, res);

    expect(intakeService.submitStage1).toHaveBeenCalledWith('user-1', {
      primary_goal: 'fat_loss',
      workout_location: 'home',
      training_days_per_week: 3
    });
    expect(res.json).toHaveBeenCalledWith({ success: true });
  });

  it('submits second intake with injuries and workout frequency', async () => {
    const req = mockRequest({
      user: { userId: 'user-2' },
      body: {
        age: 28,
        weight: 78,
        height: 175,
        experienceLevel: 'intermediate',
        workoutFrequency: 4,
        injuries: ['knee']
      }
    });
    const res = mockResponse();

    intakeService.submitStage2.mockResolvedValue({});
    userProfileService.getUserProfileForApp.mockResolvedValue({ success: true });
    db.query.mockResolvedValue({ rows: [] });

    await userController.submitSecondIntakeCompat(req, res);

    expect(intakeService.submitStage2).toHaveBeenCalledWith('user-2', {
      age: 28,
      weight: 78,
      height: 175,
      experience_level: 'intermediate',
      injury_history: ['knee']
    });
    expect(db.query).toHaveBeenCalledWith(
      expect.stringContaining('UPDATE user_intake'),
      expect.arrayContaining([4, 'user-2'])
    );
    expect(res.json).toHaveBeenCalledWith({ success: true });
  });
});
