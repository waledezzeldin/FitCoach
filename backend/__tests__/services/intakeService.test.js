const intakeService = require('../../src/services/intakeService');
const db = require('../../src/database');
const workoutGenerationService = require('../../src/services/workoutGenerationService');

jest.mock('../../src/database');
jest.mock('../../src/services/workoutGenerationService');

describe('IntakeService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('uses starter template for stage 1 and forces 3 days for freemium', async () => {
    const mockClient = {
      query: jest.fn((sql) => {
        if (sql.startsWith('SELECT subscription_tier')) {
          return Promise.resolve({ rows: [{ subscription_tier: 'freemium' }] });
        }
        if (sql.startsWith('SELECT id FROM user_intake')) {
          return Promise.resolve({ rows: [] });
        }
        if (sql.startsWith('INSERT INTO user_intake')) {
          return Promise.resolve({ rows: [{ id: 'intake-1' }] });
        }
        return Promise.resolve({ rows: [] });
      }),
      release: jest.fn()
    };

    db.getClient.mockResolvedValue(mockClient);

    workoutGenerationService.getStarterTemplate.mockResolvedValue({ plan_id: 'starter-3d' });
    workoutGenerationService.generateFromTemplate.mockResolvedValue({ plan: { id: 'plan-1' } });

    await intakeService.submitStage1('user-1', {
      primary_goal: 'fat_loss',
      workout_location: 'home',
      training_days_per_week: 5
    });

    expect(workoutGenerationService.getStarterTemplate).toHaveBeenCalledWith(
      'fat_loss',
      'home',
      3
    );
    expect(workoutGenerationService.generateFromTemplate).toHaveBeenCalled();
  });

  it('uses recommended template and passes injuries for stage 2', async () => {
    const mockClient = {
      query: jest.fn((sql) => {
        if (sql.startsWith('SELECT subscription_tier')) {
          return Promise.resolve({ rows: [{ subscription_tier: 'premium' }] });
        }
        return Promise.resolve({ rows: [] });
      }),
      release: jest.fn()
    };

    db.getClient.mockResolvedValue(mockClient);
    workoutGenerationService.recommendTemplate.mockResolvedValue({ plan_id: 'premium-4d' });
    workoutGenerationService.generateFromTemplate.mockResolvedValue({ plan: { id: 'plan-2' } });

    await intakeService.submitStage2('user-2', {
      age: 30,
      weight: 70,
      height: 170,
      experience_level: 'beginner',
      injury_history: ['shoulder']
    });

    expect(workoutGenerationService.recommendTemplate).toHaveBeenCalledWith('user-2');
    expect(workoutGenerationService.generateFromTemplate).toHaveBeenCalledWith(
      'user-2',
      'premium-4d',
      null,
      expect.objectContaining({ injuries: ['shoulder'] })
    );
  });
});
