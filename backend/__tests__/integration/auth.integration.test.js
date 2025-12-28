const request = require('supertest');
const express = require('express');
const authRoutes = require('../../src/routes/auth');
const db = require('../../src/database');

jest.mock('../../src/database');

describe('Auth Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/auth', authRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /v2/auth/send-otp', () => {
    it('should send OTP successfully', async () => {
      const mockClient = {
        query: jest.fn().mockResolvedValue({ rows: [] }),
        release: jest.fn()
      };
      db.getClient.mockResolvedValue(mockClient);

      const response = await request(app)
        .post('/v2/auth/send-otp')
        .send({ phoneNumber: '+966500000001' });

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        success: true,
        message: 'OTP sent successfully',
        expiresIn: 300
      });
    });

    it('should return 400 for invalid phone number', async () => {
      const response = await request(app)
        .post('/v2/auth/send-otp')
        .send({ phoneNumber: 'invalid' });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should return 400 for missing phone number', async () => {
      const response = await request(app)
        .post('/v2/auth/send-otp')
        .send({});

      expect(response.status).toBe(400);
    });
  });

  describe('POST /v2/auth/verify-otp', () => {
    it('should verify OTP and return tokens for existing user', async () => {
      const mockUser = {
        id: 'test-user-id',
        phone_number: '+966500000001',
        full_name: 'Test User',
        role: 'user',
        subscription_tier: 'freemium',
        is_verified: true,
        is_active: true
      };
      const otpRow = { id: 'otp-id' };
      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [otpRow] }) // Select OTP
          .mockResolvedValueOnce({ rows: [] }) // Update OTP
          .mockResolvedValueOnce({ rows: [mockUser] }) // Select user
          .mockResolvedValueOnce({ rows: [] }) // Update last login
          .mockResolvedValueOnce({ rows: [] }), // COMMIT
        release: jest.fn()
      };
      db.getClient.mockResolvedValue(mockClient);

      const response = await request(app)
        .post('/v2/auth/verify-otp')
        .send({
          phoneNumber: '+966500000001',
          otpCode: '123456'
        });

      expect(response.status).toBe(200);
      expect(response.body).toMatchObject({
        success: true,
        message: 'OTP verification successful',
        user: expect.objectContaining({
          id: mockUser.id
        }),
        token: expect.any(String)
      });
    });

    it('should create new user if not exists', async () => {
      const newUser = {
        id: 'new-user-id',
        phone_number: '+966500000002',
        role: 'user',
        subscription_tier: 'freemium',
        is_verified: true,
        is_active: true
      };
      const otpRow = { id: 'otp-id' };
      const defaultCoach = { id: 'coach-id', user_id: 'coach-user-id' };
      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [otpRow] }) // Select OTP
          .mockResolvedValueOnce({ rows: [] }) // Update OTP
          .mockResolvedValueOnce({ rows: [] }) // Select user
          .mockResolvedValueOnce({ rows: [newUser] }) // Insert user
          .mockResolvedValueOnce({ rows: [defaultCoach] }) // Default coach
          .mockResolvedValueOnce({ rows: [] }) // Assign coach
          .mockResolvedValueOnce({ rows: [] }) // Update last login
          .mockResolvedValueOnce({ rows: [] }), // COMMIT
        release: jest.fn()
      };
      db.getClient.mockResolvedValue(mockClient);

      const response = await request(app)
        .post('/v2/auth/verify-otp')
        .send({
          phoneNumber: '+966500000002',
          otpCode: '123456'
        });

      expect(response.status).toBe(200);
      expect(response.body.isNewUser).toBe(true);
    });

    it('should return 400 for invalid OTP', async () => {
      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({ rows: [] }) // BEGIN
          .mockResolvedValueOnce({ rows: [] }) // Select OTP
          .mockResolvedValueOnce({ rows: [] }), // ROLLBACK
        release: jest.fn()
      };
      db.getClient.mockResolvedValue(mockClient);

      const response = await request(app)
        .post('/v2/auth/verify-otp')
        .send({
          phoneNumber: '+966500000001',
          otpCode: '000000'
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v2/auth/refresh-token', () => {
    it('should refresh tokens successfully', async () => {
      const jwt = require('jsonwebtoken');
      const refreshToken = jwt.sign(
        { userId: 'test-user-id', type: 'refresh' },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      const mockUser = {
        id: 'test-user-id',
        phone_number: '+966500000001',
        role: 'user',
        subscription_tier: 'freemium',
        is_active: true
      };

      db.query.mockResolvedValue({ rows: [mockUser] });

      const response = await request(app)
        .post('/v2/auth/refresh-token')
        .send({ refreshToken });

      expect(response.status).toBe(200);
      expect(response.body).toMatchObject({
        success: true,
        accessToken: expect.any(String)
      });
    });

    it('should return 400 for missing refresh token', async () => {
      const response = await request(app)
        .post('/v2/auth/refresh-token')
        .send({});

      expect(response.status).toBe(400);
    });

    it('should return 401 for invalid refresh token', async () => {
      const response = await request(app)
        .post('/v2/auth/refresh-token')
        .send({ refreshToken: 'invalid-token' });

      expect(response.status).toBe(401);
    });
  });

  describe('POST /v2/auth/logout', () => {
    it('should logout successfully', async () => {
      const jwt = require('jsonwebtoken');
      const token = jwt.sign(
        { userId: 'test-user-id' },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      const mockUser = {
        id: 'test-user-id',
        is_active: true
      };

      db.query.mockResolvedValue({ rows: [mockUser] });

      const response = await request(app)
        .post('/v2/auth/logout')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        success: true,
        message: 'Logged out successfully'
      });
    });

    it('should return 401 without token', async () => {
      const response = await request(app)
        .post('/v2/auth/logout');

      expect(response.status).toBe(401);
    });
  });

  describe('GET /v2/auth/me', () => {
    it('should return current user', async () => {
      const jwt = require('jsonwebtoken');
      const token = jwt.sign(
        { userId: 'test-user-id' },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      const mockUser = {
        id: 'test-user-id',
        phone_number: '+966500000001',
        full_name: 'Test User',
        role: 'user',
        subscription_tier: 'freemium',
        is_active: true
      };

      db.query.mockResolvedValue({ rows: [mockUser] });

      const response = await request(app)
        .get('/v2/auth/me')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body).toMatchObject({
        success: true,
        user: expect.objectContaining({
          id: mockUser.id,
          phone_number: mockUser.phone_number
        })
      });
    });

    it('should return 401 without token', async () => {
      const response = await request(app)
        .get('/v2/auth/me');

      expect(response.status).toBe(401);
    });
  });
});
