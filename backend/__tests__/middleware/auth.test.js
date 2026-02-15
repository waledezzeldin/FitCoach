const { authMiddleware, roleCheck, tierCheck, checkMessageQuota, checkNutritionAccess } = require('../../src/middleware/auth');
const jwt = require('jsonwebtoken');
const db = require('../../src/database');
const { mockRequest, mockResponse, mockNext, generateTestToken, createTestUser } = require('../helpers/testHelpers');

jest.mock('../../src/database');

describe('Auth Middleware', () => {
  let req, res, next;

  beforeEach(() => {
    req = mockRequest();
    res = mockResponse();
    next = mockNext();
    jest.clearAllMocks();
  });

  describe('authMiddleware', () => {
    it('should authenticate valid token', async () => {
      const token = generateTestToken('test-user-id', 'user', 'freemium');
      req.headers.authorization = `Bearer ${token}`;

      const testUser = createTestUser();
      db.query.mockResolvedValue({ rows: [testUser] });

      await authMiddleware(req, res, next);

      expect(req.user).toEqual(
        expect.objectContaining({
          userId: 'test-user-id',
          role: 'user',
          tier: 'freemium'
        })
      );
      expect(next).toHaveBeenCalled();
    });

    it('should return 401 if no token provided', async () => {
      await authMiddleware(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'No token provided'
      });
      expect(next).not.toHaveBeenCalled();
    });

    it('should return 401 for invalid token', async () => {
      req.headers.authorization = 'Bearer invalid-token';

      await authMiddleware(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid token'
      });
    });

    it('should return 401 for expired token', async () => {
      const expiredToken = jwt.sign(
        { userId: 'test-user-id' },
        process.env.JWT_SECRET,
        { expiresIn: '-1h' }
      );
      req.headers.authorization = `Bearer ${expiredToken}`;

      await authMiddleware(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
    });

    it('should return 401 if user not found', async () => {
      const token = generateTestToken('test-user-id');
      req.headers.authorization = `Bearer ${token}`;

      db.query.mockResolvedValue({ rows: [] });

      await authMiddleware(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid token or inactive user'
      });
    });

    it('should return 403 if user is suspended', async () => {
      const token = generateTestToken('test-user-id');
      req.headers.authorization = `Bearer ${token}`;

      const suspendedUser = createTestUser({ is_active: false });
      db.query.mockResolvedValue({ rows: [suspendedUser] });

      await authMiddleware(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid token or inactive user'
      });
    });
  });

  describe('roleCheck', () => {
    it('should allow access for matching role', () => {
      req.user = { role: 'coach' };
      const middleware = roleCheck('coach', 'admin');

      middleware(req, res, next);

      expect(next).toHaveBeenCalled();
    });

    it('should deny access for non-matching role', () => {
      req.user = { role: 'user' };
      const middleware = roleCheck('coach', 'admin');

      middleware(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Insufficient permissions'
      });
      expect(next).not.toHaveBeenCalled();
    });

    it('should handle multiple allowed roles', () => {
      req.user = { role: 'admin' };
      const middleware = roleCheck('coach', 'admin', 'superadmin');

      middleware(req, res, next);

      expect(next).toHaveBeenCalled();
    });
  });

  describe('tierCheck', () => {
    it('should allow access for matching tier', () => {
      req.user = { tier: 'premium' };
      const middleware = tierCheck('premium', 'smart_premium');

      middleware(req, res, next);

      expect(next).toHaveBeenCalled();
    });

    it('should deny access for lower tier', () => {
      req.user = { tier: 'freemium' };
      const middleware = tierCheck('premium', 'smart_premium');

      middleware(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Upgrade required to access this feature',
        requiredTier: ['premium', 'smart_premium']
      });
      expect(next).not.toHaveBeenCalled();
    });
  });

  describe('checkMessageQuota', () => {
    it('should allow message if quota available', async () => {
      const testUser = createTestUser({
        subscription_tier: 'freemium',
        messages_sent_this_month: 5
      });
      req.user = { userId: testUser.id };

      db.query.mockResolvedValue({ rows: [testUser] });

      await checkMessageQuota(req, res, next);

      expect(next).toHaveBeenCalled();
    });

    it('should block message if quota exceeded for freemium', async () => {
      const testUser = createTestUser({
        subscription_tier: 'freemium',
        messages_sent_this_month: 20
      });
      req.user = { userId: testUser.id };

      db.query.mockResolvedValue({ rows: [testUser] });

      await checkMessageQuota(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Message quota exceeded',
        quota: 20,
        used: 20,
        upgradeRequired: true
      });
      expect(next).not.toHaveBeenCalled();
    });

    it('should allow unlimited messages for premium users', async () => {
      const testUser = createTestUser({
        subscription_tier: 'premium',
        messages_sent_this_month: 100
      });
      req.user = { userId: testUser.id };

      db.query.mockResolvedValue({ rows: [testUser] });

      await checkMessageQuota(req, res, next);

      expect(next).toHaveBeenCalled();
    });

    it('should handle database errors', async () => {
      req.user = { userId: 'test-user-id' };

      db.query.mockRejectedValue(new Error('Database error'));

      await checkMessageQuota(req, res, next);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe('checkNutritionAccess', () => {
    it('should allow access for premium users', async () => {
      const testUser = createTestUser({
        subscription_tier: 'premium'
      });
      req.user = { userId: testUser.id };

      db.query.mockResolvedValue({ rows: [testUser] });

      await checkNutritionAccess(req, res, next);

      expect(next).toHaveBeenCalled();
    });

    it('should allow access for freemium users with active trial', async () => {
      const testUser = createTestUser({
        subscription_tier: 'freemium',
        nutrition_trial_active: true,
        nutrition_trial_start_date: new Date()
      });
      req.user = { userId: testUser.id };

      db.query.mockResolvedValue({ rows: [testUser] });

      await checkNutritionAccess(req, res, next);

      expect(req.trialDaysRemaining).toBeDefined();
      expect(next).toHaveBeenCalled();
    });

    it('should block access for freemium users without trial', async () => {
      const testUser = createTestUser({
        subscription_tier: 'freemium',
        nutrition_trial_active: false
      });
      req.user = { userId: testUser.id };

      db.query.mockResolvedValue({ rows: [testUser] });

      await checkNutritionAccess(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Nutrition trial has expired',
        upgradeRequired: true,
        trialExpired: true
      });
      expect(next).not.toHaveBeenCalled();
    });

    it('should block access for expired trial', async () => {
      const expiredDate = new Date();
      expiredDate.setDate(expiredDate.getDate() - 15); // 15 days ago

      const testUser = createTestUser({
        subscription_tier: 'freemium',
        nutrition_trial_active: true,
        nutrition_trial_start_date: expiredDate
      });
      req.user = { userId: testUser.id };

      db.query.mockResolvedValue({ rows: [testUser] });

      await checkNutritionAccess(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
    });
  });
});
