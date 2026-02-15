const request = require('supertest');
const express = require('express');
const progressRoutes = require('../../src/routes/progress');
const db = require('../../src/database');

jest.mock('../../src/database');

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = { userId: 'user-1', role: 'user', tier: 'premium' };
    next();
  }
}));

describe('Progress Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/progress', progressRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should list progress entries', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'entry-1' }] });

    const response = await request(app).get('/v2/progress');

    expect(response.status).toBe(200);
    expect(response.body.entries).toHaveLength(1);
  });

  it('should create a progress entry', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'entry-1' }] });

    const response = await request(app)
      .post('/v2/progress')
      .send({ date: '2026-02-01', weight: 80 });

    expect(response.status).toBe(201);
    expect(response.body.entry.id).toBe('entry-1');
  });

  it('should update a progress entry', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'entry-1', weight: 82 }] });

    const response = await request(app)
      .put('/v2/progress/entry-1')
      .send({ weight: 82 });

    expect(response.status).toBe(200);
    expect(response.body.entry.id).toBe('entry-1');
  });

  it('should delete a progress entry', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'entry-1' }] });

    const response = await request(app)
      .delete('/v2/progress/entry-1');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });
});
