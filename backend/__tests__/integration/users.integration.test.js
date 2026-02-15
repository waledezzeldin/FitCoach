const request = require('supertest');
const express = require('express');
const usersRoutes = require('../../src/routes/users');
const db = require('../../src/database');

jest.mock('../../src/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(),
  pool: { connect: jest.fn() }
}));

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = { userId: 'user-1', role: 'user', tier: 'freemium' };
    next();
  },
  tierCheck: () => (req, res, next) => next()
}));

jest.mock('../../src/middleware/validation', () => {
  const actual = jest.requireActual('../../src/middleware/validation');
  return {
    ...actual,
    validateUpdateProfile: (req, res, next) => next()
  };
});

describe('Users Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/users', usersRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should update user profile with age/weight/height', async () => {
    db.query.mockResolvedValueOnce({
      rows: [{
        id: 'user-1',
        full_name: 'Updated',
        age: 28,
        weight: 72,
        height: 178,
        gender: 'male'
      }]
    });

    const response = await request(app)
      .put('/v2/users/user-1')
      .send({
        fullName: 'Updated',
        age: 28,
        weight: 72,
        height: 178,
        gender: 'male'
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.user.full_name).toBe('Updated');
  });
});
