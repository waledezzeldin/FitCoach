const request = require('supertest');
const express = require('express');

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: jest.fn(),
}));

jest.mock('../../src/controllers/ratingController', () => ({
  submitRating: jest.fn(),
  getCoachRatings: jest.fn(),
  getUserRatings: jest.fn(),
}));

const ratingsRoutes = require('../../src/routes/ratings');

describe('Ratings Routes', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/ratings', ratingsRoutes);
  });

  beforeEach(() => {
    const { authMiddleware } = require('../../src/middleware/auth');
    const ratingController = require('../../src/controllers/ratingController');

    authMiddleware.mockImplementation((req, res, next) => {
      req.user = { id: 'test-user' };
      next();
    });
    ratingController.submitRating.mockImplementation((req, res) => {
      res.status(201).json({ ok: true });
    });
    ratingController.getCoachRatings.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
    ratingController.getUserRatings.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
  });

  it('POST /v2/ratings should call submitRating', async () => {
    const response = await request(app).post('/v2/ratings').send({ rating: 5 });
    expect(response.status).toBe(201);
    expect(response.body.ok).toBe(true);
  });

  it('GET /v2/ratings/coach/:id should call getCoachRatings', async () => {
    const response = await request(app).get('/v2/ratings/coach/coach-1');
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });

  it('GET /v2/ratings/user/:id should call getUserRatings', async () => {
    const response = await request(app).get('/v2/ratings/user/user-1');
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });
});
