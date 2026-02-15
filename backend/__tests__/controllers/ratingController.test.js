const ratingController = require('../../src/controllers/ratingController');
const db = require('../../src/database');
const { mockRequest, mockResponse, createTestRating } = require('../helpers/testHelpers');

jest.mock('../../src/database');

describe('RatingController', () => {
  let req, res;

  beforeEach(() => {
    req = mockRequest();
    res = mockResponse();
    jest.clearAllMocks();
    db.getClient.mockResolvedValue({ query: jest.fn(), release: jest.fn() });
  });

  describe('submitRating', () => {
    it('should submit rating successfully', async () => {
      req.user = { userId: 'test-user-id' };
      req.body = {
        coachId: 'test-coach-id',
        context: 'video_call',
        referenceId: 'test-booking-id',
        rating: 5,
        feedback: 'Excellent session!'
      };

      const newRating = createTestRating();
      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [newRating] }) // Insert rating
          .mockResolvedValueOnce({ rows: [{ avg_rating: 4.8, total: 11 }] }) // Get avg
          .mockResolvedValueOnce({ rows: [] }) // Update coach
          .mockResolvedValueOnce({ rows: [] }), // COMMIT
        release: jest.fn()
      };

      db.getClient.mockResolvedValue(mockClient);

      await ratingController.submitRating(req, res);

      expect(mockClient.query).toHaveBeenCalledWith('BEGIN');
      expect(mockClient.query).toHaveBeenCalledWith('COMMIT');
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true,
          message: 'Rating submitted successfully',
          rating: newRating,
          coachStats: {
            averageRating: 4.8,
            totalRatings: 11
          }
        })
      );
    });

    it('should return 400 for invalid rating', async () => {
      req.user = { userId: 'test-user-id' };
      req.body = {
        coachId: 'test-coach-id',
        context: 'video_call',
        rating: 6 // Invalid
      };

      await ratingController.submitRating(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    });

    it('should return 400 for invalid context', async () => {
      req.user = { userId: 'test-user-id' };
      req.body = {
        coachId: 'test-coach-id',
        context: 'invalid_context',
        rating: 5
      };

      await ratingController.submitRating(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid rating context'
      });
    });

    it('should rollback on database error', async () => {
      req.user = { userId: 'test-user-id' };
      req.body = {
        coachId: 'test-coach-id',
        context: 'video_call',
        rating: 5
      };

      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockRejectedValueOnce(new Error('Database error')), // Insert fails
        release: jest.fn()
      };

      db.getClient.mockResolvedValue(mockClient);

      await ratingController.submitRating(req, res);

      expect(mockClient.query).toHaveBeenCalledWith('ROLLBACK');
      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe('getCoachRatings', () => {
    it('should get coach ratings with stats', async () => {
      req.params = { id: 'test-coach-id' };
      req.query = { page: 1, limit: 20 };

      const mockRatings = [
        createTestRating({ rating: 5 }),
        createTestRating({ rating: 4 })
      ];

      db.query
        .mockResolvedValueOnce({ rows: mockRatings }) // Get ratings
        .mockResolvedValueOnce({ rows: [{ count: 2 }] }) // Get count
        .mockResolvedValueOnce({ // Get distribution
          rows: [
            { rating: 5, count: 1 },
            { rating: 4, count: 1 }
          ]
        })
        .mockResolvedValueOnce({ // Get coach stats
          rows: [{ average_rating: 4.5, total_ratings: 2 }]
        });

      await ratingController.getCoachRatings(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        ratings: mockRatings,
        pagination: {
          total: 2,
          page: 1,
          limit: 20,
          totalPages: 1
        },
        stats: {
          averageRating: 4.5,
          totalRatings: 2,
          distribution: {
            5: 1,
            4: 1,
            3: 0,
            2: 0,
            1: 0
          }
        }
      });
    });

    it('should filter by context', async () => {
      req.params = { id: 'test-coach-id' };
      req.query = { context: 'video_call' };

      db.query
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [{ count: 0 }] })
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [{ average_rating: 0, total_ratings: 0 }] });

      await ratingController.getCoachRatings(req, res);

      expect(db.query).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true
        })
      );
    });

    it('should handle errors', async () => {
      req.params = { id: 'test-coach-id' };

      db.query.mockRejectedValue(new Error('Database error'));

      await ratingController.getCoachRatings(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe('getUserRatings', () => {
    it('should get user ratings', async () => {
      const userId = 'test-user-id';
      req.params = { id: userId };
      req.user = { userId, role: 'user' };

      const mockRatings = [
        createTestRating({ user_id: userId })
      ];

      db.query.mockResolvedValue({ rows: mockRatings });

      await ratingController.getUserRatings(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        ratings: mockRatings
      });
    });

    it('should return 403 for unauthorized access', async () => {
      req.params = { id: 'different-user-id' };
      req.user = { userId: 'test-user-id', role: 'user' };

      await ratingController.getUserRatings(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
    });

    it('should allow admin to view any user ratings', async () => {
      req.params = { id: 'any-user-id' };
      req.user = { userId: 'admin-id', role: 'admin' };

      db.query.mockResolvedValue({ rows: [] });

      await ratingController.getUserRatings(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        ratings: []
      });
    });
  });
});
