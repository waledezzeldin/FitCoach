const request = require('supertest');
const express = require('express');

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: jest.fn(),
}));

const progressRoutes = require('../../src/routes/progress');

describe('Progress Routes', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/progress', progressRoutes);
  });

  beforeEach(() => {
    const { authMiddleware } = require('../../src/middleware/auth');
    authMiddleware.mockImplementation((req, res, next) => {
      req.user = { id: 'test-user' };
      next();
    });
  });

  it('GET /v2/progress returns empty entries', async () => {
    const response = await request(app).get('/v2/progress');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ success: true, entries: [] });
  });

  it('POST /v2/progress creates entry', async () => {
    const response = await request(app).post('/v2/progress').send({ type: 'weight' });
    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.entry).toEqual({});
  });

  it('PUT /v2/progress/:id updates entry', async () => {
    const response = await request(app).put('/v2/progress/entry-1').send({ value: 90 });
    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  it('DELETE /v2/progress/:id deletes entry', async () => {
    const response = await request(app).delete('/v2/progress/entry-1');
    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });
});
