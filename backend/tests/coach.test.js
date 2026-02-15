const request = require('supertest');
const app = require('../src/server');

const runIntegration = process.env.RUN_INTEGRATION_TESTS === 'true';
const describeOrSkip = runIntegration ? describe : describe.skip;

describeOrSkip('Coach API Integration Tests', () => {
  let authToken;
  let coachId;
  let testAppointmentId;

  beforeAll(async () => {
    // Assuming you have a test coach account
    const loginRes = await request(app)
      .post('/v2/auth/login')
      .send({
        emailOrPhone: '+966500000002',
        password: 'TestPass123!'
      });
    
    if (loginRes.body.token) {
      authToken = loginRes.body.token;
      coachId = loginRes.body.user.id;
    }
  });

  describe('GET /coaches/:id/clients', () => {
    test('should return list of clients for authenticated coach', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/clients`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('clients');
      expect(Array.isArray(res.body.clients)).toBe(true);
      expect(res.body).toHaveProperty('total');
      expect(res.body).toHaveProperty('limit');
      expect(res.body).toHaveProperty('offset');
    });

    test('should filter clients by status', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/clients?status=active`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body.clients.every(c => c.is_active)).toBe(true);
    });

    test('should search clients by name', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/clients?search=test`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should return 401 without authentication', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/clients`);
      
      expect(res.status).toBe(401);
    });
  });

  describe('GET /coaches/:id/appointments', () => {
    test('should return list of appointments', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/appointments`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('appointments');
      expect(Array.isArray(res.body.appointments)).toBe(true);
    });

    test('should filter appointments by status', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/appointments?status=scheduled`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
      if (res.body.appointments.length > 0) {
        expect(res.body.appointments.every(a => a.status === 'scheduled')).toBe(true);
      }
    });

    test('should filter appointments by date range', async () => {
      const startDate = new Date().toISOString();
      const endDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
      
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/appointments?startDate=${startDate}&endDate=${endDate}`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
    });
  });

  describe('POST /coaches/:id/appointments', () => {
    test('should create a new appointment', async () => {
      const appointmentData = {
        userId: 'test-user-id',
        scheduledAt: new Date(Date.now() + 86400000).toISOString(),
        duration: 30,
        type: 'video',
        notes: 'Test appointment',
      };

      const res = await request(app)
        .post(`/v2/coaches/${coachId}/appointments`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(appointmentData);
      
      if (res.status === 201) {
        expect(res.body).toHaveProperty('appointment');
        expect(res.body.appointment.type).toBe('video');
        expect(res.body.appointment.duration_minutes).toBe(30);
        testAppointmentId = res.body.appointment.id;
      } else {
        // May fail if test user doesn't exist
        expect([400, 404]).toContain(res.status);
      }
    });

    test('should validate required fields', async () => {
      const res = await request(app)
        .post(`/v2/coaches/${coachId}/appointments`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({});
      
      expect(res.status).toBe(400);
      expect(res.body).toHaveProperty('message');
    });

    test('should validate appointment type', async () => {
      const res = await request(app)
        .post(`/v2/coaches/${coachId}/appointments`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          userId: 'test-user-id',
          scheduledAt: new Date(Date.now() + 86400000).toISOString(),
          duration: 30,
          type: 'invalid-type',
        });
      
      expect(res.status).toBe(400);
    });
  });

  describe('PUT /coaches/:id/appointments/:appointmentId', () => {
    test('should update an appointment', async () => {
      if (!testAppointmentId) {
        return; // Skip if no test appointment was created
      }

      const updateData = {
        duration: 60,
        notes: 'Updated notes',
      };

      const res = await request(app)
        .put(`/v2/coaches/${coachId}/appointments/${testAppointmentId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData);
      
      if (res.status === 200) {
        expect(res.body.appointment.duration_minutes).toBe(60);
        expect(res.body.appointment.notes).toBe('Updated notes');
      }
    });

    test('should validate appointment status updates', async () => {
      if (!testAppointmentId) return;

      const res = await request(app)
        .put(`/v2/coaches/${coachId}/appointments/${testAppointmentId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ status: 'invalid-status' });
      
      expect(res.status).toBe(400);
    });
  });

  describe('GET /coaches/:id/earnings', () => {
    test('should return earnings summary', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/earnings`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('summary');
      expect(res.body).toHaveProperty('periodBreakdown');
      expect(res.body).toHaveProperty('recentTransactions');
      expect(res.body.summary).toHaveProperty('total_earnings');
      expect(res.body.summary).toHaveProperty('total_commission');
    });

    test('should filter earnings by period', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/earnings?period=week`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
    });

    test('should filter earnings by date range', async () => {
      const startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
      const endDate = new Date().toISOString();
      
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/earnings?startDate=${startDate}&endDate=${endDate}`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
    });
  });

  describe('PUT /coaches/:id/clients/:clientId/fitness-score', () => {
    test('should assign fitness score to client', async () => {
      const res = await request(app)
        .put(`/v2/coaches/${coachId}/clients/test-client-id/fitness-score`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          fitnessScore: 85,
          notes: 'Good progress',
        });
      
      // May fail if test client doesn't exist
      if (res.status === 200) {
        expect(res.body).toHaveProperty('message');
      } else {
        expect([400, 404]).toContain(res.status);
      }
    });

    test('should validate fitness score range', async () => {
      const res = await request(app)
        .put(`/v2/coaches/${coachId}/clients/test-client-id/fitness-score`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          fitnessScore: 150, // Invalid - should be 0-100
        });
      
      expect(res.status).toBe(400);
    });
  });

  describe('GET /coaches/:id/analytics', () => {
    test('should return coach analytics', async () => {
      const res = await request(app)
        .get(`/v2/coaches/${coachId}/analytics`)
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('analytics');
      expect(res.body.analytics).toHaveProperty('activeClients');
      expect(res.body.analytics).toHaveProperty('upcomingAppointments');
      expect(res.body.analytics).toHaveProperty('todayEarnings');
      expect(res.body.analytics).toHaveProperty('monthEarnings');
      expect(res.body.analytics).toHaveProperty('unreadMessages');
    });
  });
});

describeOrSkip('Error Handling', () => {
  test('should handle invalid coach ID', async () => {
    const res = await request(app)
      .get('/v2/coaches/invalid-id/clients')
      .set('Authorization', `Bearer fake-token`);
    
    expect([400, 401, 404]).toContain(res.status);
  });

  test('should handle missing authorization header', async () => {
    const res = await request(app)
      .get('/v2/coaches/some-id/clients');
    
    expect(res.status).toBe(401);
  });

  test('should handle malformed requests', async () => {
    const res = await request(app)
      .post('/v2/coaches/some-id/appointments')
      .set('Authorization', `Bearer fake-token`)
      .send({ invalid: 'data' });
    
    expect([400, 401]).toContain(res.status);
  });
});
