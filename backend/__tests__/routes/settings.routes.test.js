const request = require('supertest');
const express = require('express');

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: jest.fn(),
}));

jest.mock('../../src/controllers/settingsController', () => ({
  getNotificationSettings: jest.fn(),
  updateNotificationSettings: jest.fn(),
  getCoachProfile: jest.fn(),
  updateCoachProfile: jest.fn(),
  getAdminProfile: jest.fn(),
  changePassword: jest.fn(),
  deleteAccount: jest.fn(),
}));

const settingsRoutes = require('../../src/routes/settings');

describe('Settings Routes', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/settings', settingsRoutes);
  });

  beforeEach(() => {
    const { authMiddleware } = require('../../src/middleware/auth');
    const controller = require('../../src/controllers/settingsController');

    authMiddleware.mockImplementation((req, res, next) => {
      req.user = { id: 'test-user' };
      next();
    });
    controller.getNotificationSettings.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
    controller.updateNotificationSettings.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
    controller.getCoachProfile.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
    controller.updateCoachProfile.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
    controller.getAdminProfile.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
    controller.changePassword.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
    controller.deleteAccount.mockImplementation((req, res) => {
      res.status(200).json({ ok: true });
    });
  });

  it('GET /v2/settings/notifications', async () => {
    const response = await request(app).get('/v2/settings/notifications');
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });

  it('PUT /v2/settings/notifications', async () => {
    const response = await request(app).put('/v2/settings/notifications').send({ email: true });
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });

  it('GET /v2/settings/coach-profile', async () => {
    const response = await request(app).get('/v2/settings/coach-profile');
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });

  it('PUT /v2/settings/coach-profile', async () => {
    const response = await request(app).put('/v2/settings/coach-profile').send({ bio: 'test' });
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });

  it('GET /v2/settings/admin-profile', async () => {
    const response = await request(app).get('/v2/settings/admin-profile');
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });

  it('POST /v2/settings/change-password', async () => {
    const response = await request(app).post('/v2/settings/change-password').send({ oldPassword: 'a', newPassword: 'b' });
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });

  it('DELETE /v2/settings/delete-account', async () => {
    const response = await request(app).delete('/v2/settings/delete-account');
    expect(response.status).toBe(200);
    expect(response.body.ok).toBe(true);
  });
});
