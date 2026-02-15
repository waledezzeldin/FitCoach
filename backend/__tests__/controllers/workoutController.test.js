const workoutController = require('../../src/controllers/workoutController');
const db = require('../../src/database');
const { mockRequest, mockResponse } = require('../helpers/testHelpers');

jest.mock('../../src/database');
jest.mock('../../src/services/workoutTemplateService', () => ({
  getAllTemplateSummaries: jest.fn(() => []),
  searchTemplates: jest.fn(() => []),
  getTemplateById: jest.fn(() => null),
  getTemplateSummary: jest.fn((template) => template),
}));
jest.mock('../../src/services/workoutGenerationService', () => ({
  generateFromTemplate: jest.fn(),
  recommendTemplate: jest.fn(),
}));
jest.mock('../../src/services/workoutRecommendationService', () => ({}));
jest.mock('../../src/services/coachCustomizationService', () => ({}));
jest.mock('../../src/services/exerciseCatalogService', () => ({
  getById: jest.fn(async () => null),
}));

describe('WorkoutController.logWorkoutCompat', () => {
  let req;
  let res;
  let mockClient;

  beforeEach(() => {
    req = mockRequest({
      user: { userId: 'user-1' },
      body: {},
    });
    res = mockResponse();

    mockClient = {
      query: jest.fn(),
      release: jest.fn(),
    };
    db.getClient.mockResolvedValue(mockClient);
    jest.clearAllMocks();
  });

  it('returns 400 when no exercise IDs or workout day ID are provided', async () => {
    await workoutController.logWorkoutCompat(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
      })
    );
    expect(mockClient.query).not.toHaveBeenCalled();
    expect(mockClient.release).toHaveBeenCalled();
  });

  it('marks provided exercises complete and writes audit log', async () => {
    req.body = {
      exerciseIds: ['ex-1', 'ex-2'],
      durationMinutes: 38,
      notes: 'solid session',
    };

    mockClient.query
      .mockResolvedValueOnce({ rows: [] }) // BEGIN
      .mockResolvedValueOnce({
        rows: [
          { id: 'ex-1', workout_day_id: 'day-1', completed_at: new Date() },
          { id: 'ex-2', workout_day_id: 'day-1', completed_at: new Date() },
        ],
      }) // UPDATE
      .mockResolvedValueOnce({ rows: [] }) // INSERT audit log
      .mockResolvedValueOnce({ rows: [] }); // COMMIT

    await workoutController.logWorkoutCompat(req, res);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: true,
        logged: expect.objectContaining({
          completedExercises: 2,
          workoutDayId: 'day-1',
          durationMinutes: 38,
        }),
      })
    );
    expect(mockClient.query).toHaveBeenNthCalledWith(1, 'BEGIN');
    expect(mockClient.query).toHaveBeenNthCalledWith(4, 'COMMIT');
    expect(mockClient.release).toHaveBeenCalled();
  });
});
