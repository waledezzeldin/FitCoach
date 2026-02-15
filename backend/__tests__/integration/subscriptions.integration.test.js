const request = require('supertest');
const express = require('express');
const subscriptionRoutes = require('../../src/routes/subscriptions');
const db = require('../../src/database');

jest.mock('../../src/database');

describe('Subscriptions Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/subscriptions', subscriptionRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should list subscription plans', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'plan-1', name: 'Premium', price: 99 }] });

    const response = await request(app).get('/v2/subscriptions/plans');

    expect(response.status).toBe(200);
    expect(response.body.plans).toHaveLength(1);
  });
});
