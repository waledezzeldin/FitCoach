const request = require('supertest');
const express = require('express');
const messageRoutes = require('../../src/routes/messages');
const db = require('../../src/database');
const quotaService = require('../../src/services/quotaService');
const s3Service = require('../../src/services/s3Service');

jest.mock('../../src/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(),
  pool: { connect: jest.fn() }
}));

jest.mock('../../src/services/quotaService', () => ({
  incrementQuota: jest.fn()
}));

jest.mock('../../src/services/s3Service', () => ({
  uploadFile: jest.fn()
}));

jest.mock('../../src/middleware/chatAttachmentControl', () => ({
  checkAttachmentPermission: (req, res, next) => next()
}));

jest.mock('../../src/middleware/auth', () => {
  const actual = jest.requireActual('../../src/middleware/auth');
  return {
    ...actual,
    authMiddleware: (req, res, next) => {
      req.user = { userId: 'user-1', role: 'user', tier: 'premium' };
      next();
    },
    checkMessageQuota: (req, res, next) => next()
  };
});

describe('Messages Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/messages', messageRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should send a message with an existing conversation', async () => {
    const mockClient = {
      query: jest.fn()
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({ rows: [{ id: 'conv-1', user_id: 'user-1', coach_id: 'coach-1', coach_user_id: 'coach-user-1' }] })
        .mockResolvedValueOnce({ rows: [{ id: 'msg-1', conversation_id: 'conv-1', sender_id: 'user-1', content: 'Hi' }] })
        .mockResolvedValueOnce({}) // update conversation
        .mockResolvedValueOnce({}), // COMMIT
      release: jest.fn()
    };

    db.pool.connect.mockResolvedValue(mockClient);
    db.query.mockResolvedValueOnce({
      rows: [{ id: 'user-1', full_name: 'Test User', profile_picture_url: null }]
    });

    const response = await request(app)
      .post('/v2/messages/send')
      .send({
        conversationId: 'conv-1',
        content: 'Hi',
        messageType: 'text'
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(quotaService.incrementQuota).toHaveBeenCalledWith('user-1', 'messages');
  });

  it('should mark messages as read for a conversation', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [{ user_id: 'user-1', coach_id: 'coach-1' }] })
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({});

    const response = await request(app)
      .patch('/v2/messages/conv-1/read');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  it('should clear all messages in a conversation', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [{ id: 'conv-1' }] })
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({});

    const response = await request(app)
      .delete('/v2/messages/conversations/conv-1/messages');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  it('should upload a message attachment', async () => {
    s3Service.uploadFile.mockResolvedValueOnce({ url: 'https://example.com/file.pdf' });

    const response = await request(app)
      .post('/v2/messages/upload')
      .attach('file', Buffer.from('test-file'), 'file.pdf');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.attachment.url).toBe('https://example.com/file.pdf');
  });
});
