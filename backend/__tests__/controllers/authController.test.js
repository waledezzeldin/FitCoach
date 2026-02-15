const authController = require('../../src/controllers/authController');
const db = require('../../src/database');
const jwt = require('jsonwebtoken');
const userProfileService = require('../../src/services/userProfileService');
const { mockRequest, mockResponse, mockNext, createTestUser } = require('../helpers/testHelpers');

jest.mock('../../src/database');
jest.mock('../../src/services/userProfileService', () => ({
  getUserProfileForApp: jest.fn()
}));

describe('AuthController', () => {
  let req, res, next;

  beforeEach(() => {
    req = mockRequest();
    res = mockResponse();
    next = mockNext();
    jest.clearAllMocks();
    db.getClient.mockResolvedValue({ query: jest.fn().mockResolvedValue({ rows: [] }), release: jest.fn() });
  });

  describe('sendOTP', () => {
    it('should send OTP successfully', async () => {
      req.body = { phoneNumber: '+966500000001' };

      await authController.sendOTP(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'OTP sent successfully',
        expiresIn: 300
      });
    });

    it('should return 400 if phone number is missing', async () => {
      req.body = {};

      await authController.sendOTP(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Phone number is required'
      });
    });

    it('should return 400 if phone number is invalid', async () => {
      req.body = { phoneNumber: 'invalid' };

      await authController.sendOTP(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid phone number format'
      });
    });

    it('should handle database errors', async () => {
      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockRejectedValueOnce(new Error('Database error')) // DELETE/INSERT
          .mockResolvedValueOnce({ rows: [] }), // ROLLBACK
        release: jest.fn()
      };
      db.getClient.mockResolvedValue(mockClient);
      req.body = { phoneNumber: '+966500000001' };

      await authController.sendOTP(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Failed to send OTP'
      });
    });
  });

  describe('verifyOTP', () => {
    it('should verify OTP and login existing user', async () => {
      req.body = {
        phoneNumber: '+966500000001',
        otpCode: '123456'
      };

      const testUser = createTestUser();
      const otpRow = { id: 'otp-id' };
      userProfileService.getUserProfileForApp.mockResolvedValueOnce(null);

      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [otpRow] }) // Select OTP
          .mockResolvedValueOnce({ rows: [] }) // Update OTP
          .mockResolvedValueOnce({ rows: [testUser] }) // Select user
          .mockResolvedValueOnce({ rows: [] }) // Update last login
          .mockResolvedValueOnce({ rows: [] }), // COMMIT
        release: jest.fn()
      };
      db.getClient.mockResolvedValue(mockClient);

      await authController.verifyOTP(req, res);

      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true,
          message: 'OTP verification successful',
          user: expect.objectContaining({
            id: testUser.id,
            phone_number: testUser.phone_number
          }),
          token: expect.any(String)
        })
      );
    });

    it('should verify OTP and create new user', async () => {
      req.body = {
        phoneNumber: '+966500000001',
        otpCode: '123456'
      };

      const newUser = createTestUser();
      const otpRow = { id: 'otp-id' };
      const defaultCoach = { id: 'coach-id', user_id: 'coach-user-id' };
      userProfileService.getUserProfileForApp.mockResolvedValueOnce(null);

      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [otpRow] }) // Select OTP
          .mockResolvedValueOnce({ rows: [] }) // Update OTP
          .mockResolvedValueOnce({ rows: [] }) // Select user (none)
          .mockResolvedValueOnce({ rows: [newUser] }) // Insert user
          .mockResolvedValueOnce({ rows: [defaultCoach] }) // Default coach
          .mockResolvedValueOnce({ rows: [] }) // Assign coach
          .mockResolvedValueOnce({ rows: [] }) // Update last login
          .mockResolvedValueOnce({ rows: [] }), // COMMIT
        release: jest.fn()
      };
      db.getClient.mockResolvedValue(mockClient);

      await authController.verifyOTP(req, res);

      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true,
          isNewUser: true
        })
      );
    });

    it('should return 400 if OTP is invalid', async () => {
      req.body = {
        phoneNumber: '+966500000001',
        otpCode: '123456'
      };

      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [] }) // Select OTP (invalid)
          .mockResolvedValueOnce({ rows: [] }), // ROLLBACK
        release: jest.fn()
      };
      db.getClient.mockResolvedValue(mockClient);

      await authController.verifyOTP(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid or expired OTP'
      });
    });

    it('should return 400 if required fields are missing', async () => {
      req.body = { phoneNumber: '+966500000001' };

      await authController.verifyOTP(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });
  });

  describe('refreshToken', () => {
    it('should refresh token successfully', async () => {
      const testUser = createTestUser();
      const refreshToken = jwt.sign(
        { userId: testUser.id, type: 'refresh' },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      req.body = { refreshToken };

      db.query.mockResolvedValue({ rows: [testUser] });

      await authController.refreshToken(req, res);

      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true,
          accessToken: expect.any(String),
          token: expect.any(String)
        })
      );
    });

    it('should return 400 if refresh token is missing', async () => {
      req.body = {};

      await authController.refreshToken(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return 401 if refresh token is invalid', async () => {
      req.body = { refreshToken: 'invalid-token' };

      await authController.refreshToken(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
    });
  });

  describe('logout', () => {
    it('should logout successfully', async () => {
      req.user = { userId: 'test-user-id' };

      await authController.logout(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Logged out successfully'
      });
    });
  });

  describe('getCurrentUser', () => {
    it('should return current user', async () => {
      const testUser = createTestUser();
      req.user = { userId: testUser.id };

      db.query.mockResolvedValue({ rows: [testUser] });

      await authController.getCurrentUser(req, res);

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        user: expect.objectContaining({
          id: testUser.id
        })
      });
    });

    it('should return 404 if user not found', async () => {
      req.user = { userId: 'non-existent' };

      db.query.mockResolvedValue({ rows: [] });

      await authController.getCurrentUser(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });
  });
});
