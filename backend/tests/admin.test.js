const request = require('supertest');
const app = require('../src/server');

const runIntegration = process.env.RUN_INTEGRATION_TESTS === 'true';
const describeOrSkip = runIntegration ? describe : describe.skip;

describeOrSkip('Admin API Integration Tests', () => {
  let adminToken;
  let testUserId;
  let testCoachId;

  beforeAll(async () => {
    // Login as admin
    const loginRes = await request(app)
      .post('/v2/auth/login')
      .send({
        emailOrPhone: '+966500000001',
        password: 'TestPass123!'
      });
    
    if (loginRes.body.token) {
      adminToken = loginRes.body.token;
    }
  });

  describe('GET /admin/analytics', () => {
    test('should return dashboard analytics', async () => {
      const res = await request(app)
        .get('/v2/admin/analytics')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('analytics');
      expect(res.body.analytics).toHaveProperty('users');
      expect(res.body.analytics).toHaveProperty('coaches');
      expect(res.body.analytics).toHaveProperty('subscriptions');
      expect(res.body.analytics).toHaveProperty('revenue');
      expect(res.body.analytics).toHaveProperty('growth');
      expect(res.body.analytics).toHaveProperty('sessions');
    });

    test('should return correct data structure', async () => {
      const res = await request(app)
        .get('/v2/admin/analytics')
        .set('Authorization', `Bearer ${adminToken}`);
      
      if (res.status === 200) {
        expect(res.body.analytics.users).toHaveProperty('total');
        expect(res.body.analytics.users).toHaveProperty('active');
        expect(res.body.analytics.coaches).toHaveProperty('total');
        expect(res.body.analytics.coaches).toHaveProperty('active');
        expect(Array.isArray(res.body.analytics.subscriptions)).toBe(true);
      }
    });

    test('should deny access for non-admin users', async () => {
      const res = await request(app)
        .get('/v2/admin/analytics')
        .set('Authorization', 'Bearer fake-token');
      
      expect(res.status).toBe(401);
    });
  });

  describe('GET /admin/users', () => {
    test('should return list of users', async () => {
      const res = await request(app)
        .get('/v2/admin/users')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('users');
      expect(Array.isArray(res.body.users)).toBe(true);
      expect(res.body).toHaveProperty('total');
    });

    test('should filter users by subscription tier', async () => {
      const res = await request(app)
        .get('/v2/admin/users?subscriptionTier=premium')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      if (res.body.users.length > 0) {
        expect(res.body.users.every(u => u.subscription_tier === 'premium')).toBe(true);
      }
    });

    test('should filter users by status', async () => {
      const res = await request(app)
        .get('/v2/admin/users?status=active')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should search users by name or email', async () => {
      const res = await request(app)
        .get('/v2/admin/users?search=test')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should support pagination', async () => {
      const res = await request(app)
        .get('/v2/admin/users?limit=10&offset=0')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body.users.length).toBeLessThanOrEqual(10);
    });
  });

  describe('GET /admin/users/:id', () => {
    beforeAll(async () => {
      const usersRes = await request(app)
        .get('/v2/admin/users?limit=1')
        .set('Authorization', `Bearer ${adminToken}`);
      
      if (usersRes.body.users.length > 0) {
        testUserId = usersRes.body.users[0].id;
      }
    });

    test('should return user details', async () => {
      if (!testUserId) return;

      const res = await request(app)
        .get(`/v2/admin/users/${testUserId}`)
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('user');
      expect(res.body.user.id).toBe(testUserId);
    });

    test('should return 404 for non-existent user', async () => {
      const res = await request(app)
        .get('/v2/admin/users/non-existent-id')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(404);
    });
  });

  describe('PUT /admin/users/:id', () => {
    test('should update user details', async () => {
      if (!testUserId) return;

      const updateData = {
        subscriptionTier: 'premium',
        isActive: true,
      };

      const res = await request(app)
        .put(`/v2/admin/users/${testUserId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(updateData);
      
      if (res.status === 200) {
        expect(res.body).toHaveProperty('user');
        expect(res.body.user.subscription_tier).toBe('premium');
      }
    });

    test('should validate subscription tier', async () => {
      if (!testUserId) return;

      const res = await request(app)
        .put(`/v2/admin/users/${testUserId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ subscriptionTier: 'invalid-tier' });
      
      expect(res.status).toBe(400);
    });
  });

  describe('POST /admin/users/:id/suspend', () => {
    test('should suspend a user', async () => {
      if (!testUserId) return;

      const res = await request(app)
        .post(`/v2/admin/users/${testUserId}/suspend`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ reason: 'Test suspension' });
      
      if (res.status === 200) {
        expect(res.body).toHaveProperty('message');
      }
    });

    test('should require a reason', async () => {
      if (!testUserId) return;

      const res = await request(app)
        .post(`/v2/admin/users/${testUserId}/suspend`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({});
      
      expect(res.status).toBe(400);
    });
  });

  describe('DELETE /admin/users/:id', () => {
    test('should delete a user', async () => {
      // Create a test user first or use a specific test user
      // This is a destructive operation, so be careful in real tests
      const res = await request(app)
        .delete('/v2/admin/users/test-delete-user-id')
        .set('Authorization', `Bearer ${adminToken}`);
      
      // Should return 200 or 404 if user doesn't exist
      expect([200, 404]).toContain(res.status);
    });
  });

  describe('GET /admin/coaches', () => {
    test('should return list of coaches', async () => {
      const res = await request(app)
        .get('/v2/admin/coaches')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('coaches');
      expect(Array.isArray(res.body.coaches)).toBe(true);
    });

    test('should filter coaches by approval status', async () => {
      const res = await request(app)
        .get('/v2/admin/coaches?approved=false')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      if (res.body.coaches.length > 0) {
        expect(res.body.coaches.every(c => !c.is_approved)).toBe(true);
      }
    });

    test('should filter coaches by status', async () => {
      const res = await request(app)
        .get('/v2/admin/coaches?status=active')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should search coaches', async () => {
      const res = await request(app)
        .get('/v2/admin/coaches?search=coach')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });
  });

  describe('POST /admin/coaches/:id/approve', () => {
    beforeAll(async () => {
      const coachesRes = await request(app)
        .get('/v2/admin/coaches?approved=false&limit=1')
        .set('Authorization', `Bearer ${adminToken}`);
      
      if (coachesRes.body.coaches.length > 0) {
        testCoachId = coachesRes.body.coaches[0].id;
      }
    });

    test('should approve a pending coach', async () => {
      if (!testCoachId) return;

      const res = await request(app)
        .post(`/v2/admin/coaches/${testCoachId}/approve`)
        .set('Authorization', `Bearer ${adminToken}`);
      
      if (res.status === 200) {
        expect(res.body).toHaveProperty('message');
      }
    });

    test('should return 404 for non-existent coach', async () => {
      const res = await request(app)
        .post('/v2/admin/coaches/non-existent-id/approve')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(404);
    });
  });

  describe('POST /admin/coaches/:id/suspend', () => {
    test('should suspend a coach', async () => {
      if (!testCoachId) return;

      const res = await request(app)
        .post(`/v2/admin/coaches/${testCoachId}/suspend`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ reason: 'Test suspension' });
      
      if (res.status === 200) {
        expect(res.body).toHaveProperty('message');
      }
    });

    test('should require a reason', async () => {
      if (!testCoachId) return;

      const res = await request(app)
        .post(`/v2/admin/coaches/${testCoachId}/suspend`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({});
      
      expect(res.status).toBe(400);
    });
  });

  describe('GET /admin/revenue', () => {
    test('should return revenue analytics', async () => {
      const res = await request(app)
        .get('/v2/admin/revenue')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('revenue');
      expect(res.body.revenue).toHaveProperty('total');
      expect(res.body.revenue).toHaveProperty('transactionCount');
      expect(res.body.revenue).toHaveProperty('byPeriod');
      expect(res.body.revenue).toHaveProperty('byTier');
    });

    test('should filter revenue by period', async () => {
      const res = await request(app)
        .get('/v2/admin/revenue?period=week')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should filter revenue by date range', async () => {
      const startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
      const endDate = new Date().toISOString();
      
      const res = await request(app)
        .get(`/v2/admin/revenue?startDate=${startDate}&endDate=${endDate}`)
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });
  });

  describe('GET /admin/audit-logs', () => {
    test('should return audit logs', async () => {
      const res = await request(app)
        .get('/v2/admin/audit-logs')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('logs');
      expect(Array.isArray(res.body.logs)).toBe(true);
    });

    test('should filter logs by action', async () => {
      const res = await request(app)
        .get('/v2/admin/audit-logs?action=user_created')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should filter logs by user', async () => {
      const res = await request(app)
        .get('/v2/admin/audit-logs?userId=some-user-id')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should filter logs by date range', async () => {
      const startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
      const endDate = new Date().toISOString();
      
      const res = await request(app)
        .get(`/v2/admin/audit-logs?startDate=${startDate}&endDate=${endDate}`)
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should support pagination', async () => {
      const res = await request(app)
        .get('/v2/admin/audit-logs?limit=50&offset=0')
        .set('Authorization', `Bearer ${adminToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body.logs.length).toBeLessThanOrEqual(50);
    });
  });
});

describeOrSkip('Admin Authorization', () => {
  test('should deny access to non-admin users', async () => {
    const res = await request(app)
      .get('/v2/admin/analytics')
      .set('Authorization', 'Bearer non-admin-token');
    
    expect(res.status).toBe(401);
  });

  test('should deny access without token', async () => {
    const res = await request(app)
      .get('/v2/admin/analytics');
    
    expect(res.status).toBe(401);
  });
});
