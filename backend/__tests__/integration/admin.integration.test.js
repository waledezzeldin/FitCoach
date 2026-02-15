const request = require('supertest');
const express = require('express');
const adminRoutes = require('../../src/routes/admin');
const db = require('../../src/database');

jest.mock('uuid', () => ({
  v4: () => 'test-uuid'
}));

jest.mock('../../src/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(),
  pool: { connect: jest.fn() }
}));

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = {
      userId: 'admin-1',
      role: req.headers['x-role'] || 'admin',
      tier: 'smart_premium'
    };
    next();
  },
  roleCheck: (...roles) => (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }
    return next();
  }
}));

describe('Admin Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/admin', adminRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should assign a coach when updating a user', async () => {
    const userId = '11111111-1111-1111-8111-111111111111';
    const coachId = '22222222-2222-2222-8222-222222222222';

    db.query
      .mockResolvedValueOnce({ rows: [{ id: userId, full_name: 'User', subscription_tier: 'freemium' }] }) // update user
      .mockResolvedValueOnce({ rows: [{ id: coachId, user_id: 'coach-user-id' }] }) // coach lookup
      .mockResolvedValueOnce({ rows: [] }) // deactivate old assignments
      .mockResolvedValueOnce({ rows: [] }) // insert assignment
      .mockResolvedValueOnce({ rows: [] }) // update assigned coach
      .mockResolvedValueOnce({ rows: [] }) // notification to user
      .mockResolvedValueOnce({ rows: [] }) // notification to coach
      .mockResolvedValue({ rows: [] }); // default for any extra calls

    const response = await request(app)
      .put(`/v2/admin/users/${userId}`)
      .send({ coachId });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(db.query).toHaveBeenCalledWith(
      expect.stringContaining('UPDATE users'),
      expect.any(Array)
    );
  });

  it('should create a product as admin', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'prod-1', name: 'Test', price: 10 }] });

    const response = await request(app)
      .post('/v2/admin/products')
      .send({ name: 'Test', category: 'supplements', price: 10 });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.product.id).toBe('prod-1');
  });

  it('should update a product as admin', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'prod-1', name: 'Updated' }] });

    const response = await request(app)
      .put('/v2/admin/products/prod-1')
      .send({ name: 'Updated', price: 12 });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.product.id).toBe('prod-1');
  });

  it('should delete a product as admin', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'prod-1' }] });

    const response = await request(app)
      .delete('/v2/admin/products/prod-1');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  it('should create a subscription plan as admin', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'plan-1', name: 'Premium', price: 100 }] });

    const response = await request(app)
      .post('/v2/admin/subscriptions/plans')
      .send({ name: 'Premium', price: 100, currency: 'SAR', durationMonths: 1, isActive: true });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.plan.id).toBe('plan-1');
  });

  it('should update a subscription plan as admin', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'plan-1', name: 'Premium+', price: 120 }] });

    const response = await request(app)
      .put('/v2/admin/subscriptions/plans/plan-1')
      .send({ name: 'Premium+', price: 120 });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.plan.id).toBe('plan-1');
  });

  it('should delete a subscription plan as admin', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'plan-1' }] });

    const response = await request(app)
      .delete('/v2/admin/subscriptions/plans/plan-1');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  it('should create a coach as admin', async () => {
    const mockClient = {
      query: jest.fn()
        .mockResolvedValueOnce({ rows: [] }) // existing email check
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockResolvedValueOnce({
          rows: [{
            id: 'user-1',
            full_name: 'Coach Route',
            email: 'coach@fitcoach.com',
            phone_number: '+966500000003',
            profile_photo_url: null,
            is_active: true,
            created_at: new Date().toISOString()
          }]
        }) // insert user
        .mockResolvedValueOnce({
          rows: [{
            id: 'coach-1',
            user_id: 'user-1',
            specializations: ['fat_loss'],
            average_rating: null,
            is_approved: false,
            is_active: true,
            created_at: new Date().toISOString(),
            approved_at: null
          }]
        }) // insert coach
        .mockResolvedValueOnce({ rows: [] }), // COMMIT
      release: jest.fn()
    };
    db.pool.connect.mockResolvedValueOnce(mockClient);

    const response = await request(app)
      .post('/v2/admin/coaches')
      .set('x-role', 'admin')
      .send({
        fullName: 'Coach Route',
        email: 'coach@fitcoach.com',
        specializations: ['fat_loss']
      });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.coach.id).toBe('coach-1');
  });

  it('should block non-admin role from creating a coach', async () => {
    const response = await request(app)
      .post('/v2/admin/coaches')
      .set('x-role', 'user')
      .send({
        fullName: 'Coach Route',
        email: 'coach@fitcoach.com'
      });

    expect(response.status).toBe(403);
    expect(response.body.success).toBe(false);
  });
});
