const request = require('supertest');
const express = require('express');
const orderRoutes = require('../../src/routes/orders');
const db = require('../../src/database');

jest.mock('../../src/database');

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = { userId: 'user-1', role: 'user', tier: 'premium' };
    next();
  },
  roleCheck: () => (req, res, next) => next()
}));

describe('Orders Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/orders', orderRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should create an order', async () => {
    const mockClient = {
      query: jest.fn()
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({ rows: [{ id: 'prod-1', name: 'Test', price: 10, stock_quantity: 10 }] })
        .mockResolvedValueOnce({}) // decrement stock
        .mockResolvedValueOnce({ rows: [{ id: 'order-1' }] })
        .mockResolvedValueOnce({}) // insert order item
        .mockResolvedValueOnce({}), // COMMIT
      release: jest.fn()
    };

    db.getClient.mockResolvedValue(mockClient);
    db.query.mockResolvedValueOnce({ rows: [{ id: 'order-1', items: [] }] });

    const response = await request(app)
      .post('/v2/orders')
      .send({
        items: [{ productId: 'prod-1', quantity: 1 }],
        shippingAddress: { line1: 'Street 1' }
      });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
  });

  it('should track an order', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'order-1', order_number: 'ORD-1', status: 'pending', placed_at: new Date(), updated_at: new Date() }] });

    const response = await request(app)
      .get('/v2/orders/order-1/track');

    expect(response.status).toBe(200);
    expect(response.body.tracking.status).toBe('pending');
  });

  it('should cancel an order via PUT', async () => {
    const mockClient = {
      query: jest.fn()
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({ rows: [{ id: 'order-1', status: 'pending' }] })
        .mockResolvedValueOnce({ rows: [{ product_id: 'prod-1', quantity: 1 }] })
        .mockResolvedValueOnce({})
        .mockResolvedValueOnce({})
        .mockResolvedValueOnce({}), // COMMIT
      release: jest.fn()
    };

    db.getClient.mockResolvedValue(mockClient);

    const response = await request(app)
      .put('/v2/orders/order-1/cancel')
      .send({ reason: 'Changed mind' });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });
});
