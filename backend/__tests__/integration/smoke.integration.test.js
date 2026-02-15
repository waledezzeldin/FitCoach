const request = require('supertest');
const express = require('express');
const videoRoutes = require('../../src/routes/videoCalls');
const videoCallService = require('../../src/services/videoCallService');

jest.mock('../../src/services/videoCallService', () => ({
  canJoinCall: jest.fn()
}));

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = { userId: 'user-1', role: 'user', tier: 'premium' };
    next();
  }
}));

describe('Smoke Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/video-calls', videoRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should allow can-join check for video calls', async () => {
    videoCallService.canJoinCall.mockResolvedValue({ canJoin: true });

    const response = await request(app)
      .get('/v2/video-calls/appointment-1/can-join');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(videoCallService.canJoinCall).toHaveBeenCalledWith('appointment-1', 'user-1');
  });
});
