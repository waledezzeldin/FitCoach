const request = require('supertest');
const express = require('express');

jest.mock('../../src/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(),
  pool: { connect: jest.fn() }
}));

jest.mock('../../src/services/s3Service', () => ({
  uploadFile: jest.fn()
}));

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = {
      userId: req.headers['x-user-id'] || 'user-1',
      role: 'user',
      tier: 'freemium'
    };
    next();
  },
  tierCheck: () => (req, res, next) => next()
}));

jest.mock('../../src/middleware/upload', () => ({
  uploadProfilePhoto: (req, res, next) => next()
}));

jest.mock('../../src/middleware/validation', () => ({
  validateUpdateProfile: (req, res, next) => next()
}));

const db = require('../../src/database');
const usersRoutes = require('../../src/routes/users');

describe('Users profile photo route contract', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/users', usersRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('updates profile photo when photoUrl is provided', async () => {
    db.query.mockResolvedValueOnce({ rows: [] });

    const response = await request(app)
      .post('/v2/users/user-1/upload-photo')
      .set('x-user-id', 'user-1')
      .send({ photoUrl: 'https://cdn.fitcoach.com/photo.jpg' });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.photoUrl).toBe('https://cdn.fitcoach.com/photo.jpg');
  });

  it('returns validation error when neither file nor photoUrl is provided', async () => {
    const response = await request(app)
      .post('/v2/users/user-1/upload-photo')
      .set('x-user-id', 'user-1')
      .send({});

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.message).toContain('photo file or photoUrl is required');
  });

  it('rejects upload when requester does not own profile', async () => {
    const response = await request(app)
      .post('/v2/users/user-1/upload-photo')
      .set('x-user-id', 'user-2')
      .send({ photoUrl: 'https://cdn.fitcoach.com/photo.jpg' });

    expect(response.status).toBe(403);
    expect(response.body.success).toBe(false);
  });
});
