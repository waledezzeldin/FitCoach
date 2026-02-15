const request = require('supertest');
const express = require('express');
const paymentRoutes = require('../../src/routes/payments');
const paymentService = require('../../src/services/paymentService');

jest.mock('../../src/services/paymentService', () => ({
  getSubscriptionStatus: jest.fn()
}));

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = { userId: 'user-1', role: 'user', tier: 'premium' };
    next();
  }
}));

describe('Payments Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/payments', paymentRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should return subscription status', async () => {
    paymentService.getSubscriptionStatus.mockResolvedValueOnce({
      status: 'active',
      isActive: true,
      tier: 'premium'
    });

    const response = await request(app)
      .get('/v2/payments/subscription');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.subscription.status).toBe('active');
  });
});
