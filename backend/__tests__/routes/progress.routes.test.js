const request = require('supertest');
const express = require('express');
const db = require('../../src/database');

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: jest.fn(),
}));

jest.mock('../../src/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(),
  pool: { connect: jest.fn() }
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
      req.user = { userId: 'test-user' };
      next();
    });
  });

  it('GET /v2/progress returns empty entries', async () => {
    db.query.mockResolvedValueOnce({ rows: [] });
    const response = await request(app).get('/v2/progress');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ success: true, entries: [] });
  });

  it('POST /v2/progress creates entry', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'entry-1' }] });
    const response = await request(app)
      .post('/v2/progress')
      .send({ date: '2026-02-01', weight: 80 });
    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.entry.id).toBe('entry-1');
  });

  it('PUT /v2/progress/:id updates entry', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'entry-1' }] });
    const response = await request(app).put('/v2/progress/entry-1').send({ weight: 90 });
    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  it('DELETE /v2/progress/:id deletes entry', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'entry-1' }] });
    const response = await request(app).delete('/v2/progress/entry-1');
    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });
});
