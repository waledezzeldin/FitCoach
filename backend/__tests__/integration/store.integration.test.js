const request = require('supertest');
const express = require('express');
const storeRoutes = require('../../src/routes/store');
const db = require('../../src/database');

jest.mock('../../src/database');

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = { userId: 'user-1', role: 'user', tier: 'premium' };
    next();
  }
}));

describe('Store Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/store', storeRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should list products', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [{ id: 'prod-1', name: 'Test', price: 10 }] })
      .mockResolvedValueOnce({ rows: [{ count: '1' }] });

    const response = await request(app).get('/v2/store/products');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.products).toHaveLength(1);
  });

  it('should list categories', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ category: 'supplements', product_count: '2' }] });

    const response = await request(app).get('/v2/store/categories');

    expect(response.status).toBe(200);
    expect(response.body.categories[0].category).toBe('supplements');
  });

  it('should check product availability', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ stock_quantity: 5, is_active: true }] });

    const response = await request(app)
      .post('/v2/store/products/prod-1/check-availability')
      .send({ quantity: 3 });

    expect(response.status).toBe(200);
    expect(response.body.available).toBe(true);
  });

  it('should apply promo code', async () => {
    const response = await request(app)
      .post('/v2/store/promo-codes/apply')
      .send({ code: 'FIT10', subtotal: 100 });

    expect(response.status).toBe(200);
    expect(response.body.discount).toBe(10);
  });

  it('should calculate shipping', async () => {
    const response = await request(app)
      .post('/v2/store/shipping/calculate')
      .send({ address: 'Riyadh', weight: 2 });

    expect(response.status).toBe(200);
    expect(response.body.shippingCost).toBeGreaterThan(0);
  });
});
