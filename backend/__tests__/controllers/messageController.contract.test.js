const messageController = require('../../src/controllers/messageController');
const db = require('../../src/database');
const quotaService = require('../../src/services/quotaService');
const s3Service = require('../../src/services/s3Service');
const { mockRequest, mockResponse } = require('../helpers/testHelpers');

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

describe('Message controller response contracts', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('keeps upload attachment wrapper stable', async () => {
    const req = mockRequest({
      user: { userId: 'user-1' },
      file: {
        buffer: Buffer.from('file'),
        originalname: 'file.png',
        mimetype: 'image/png',
        size: 4
      }
    });
    const res = mockResponse();

    s3Service.uploadFile.mockResolvedValueOnce({ url: 'https://cdn.test/file.png' });

    await messageController.uploadAttachment(req, res);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: true,
        attachment: expect.objectContaining({
          url: 'https://cdn.test/file.png',
          type: 'image',
          name: 'file.png',
          size: 4
        })
      })
    );
  });

  it('keeps send message wrapper stable', async () => {
    const req = mockRequest({
      user: { userId: 'user-1' },
      body: {
        conversationId: 'conv-1',
        content: 'hello',
        messageType: 'text'
      }
    });
    const res = mockResponse();

    const mockClient = {
      query: jest.fn()
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({
          rows: [{
            id: 'conv-1',
            user_id: 'user-1',
            coach_id: 'coach-1',
            coach_user_id: 'coach-user-1'
          }]
        })
        .mockResolvedValueOnce({
          rows: [{
            id: 'msg-1',
            conversation_id: 'conv-1',
            sender_id: 'user-1',
            receiver_id: 'coach-user-1',
            content: 'hello',
            message_type: 'text'
          }]
        })
        .mockResolvedValueOnce({}) // update conversation
        .mockResolvedValueOnce({}), // COMMIT
      release: jest.fn()
    };
    db.pool.connect.mockResolvedValueOnce(mockClient);
    db.query.mockResolvedValueOnce({
      rows: [{ id: 'user-1', full_name: 'Test User', profile_picture_url: null }]
    });

    await messageController.sendMessage(req, res);

    expect(quotaService.incrementQuota).toHaveBeenCalledWith('user-1', 'messages');
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: true,
        message: expect.objectContaining({
          id: 'msg-1',
          conversation_id: 'conv-1',
          sender_name: 'Test User'
        }),
        conversationId: 'conv-1'
      })
    );
  });
});
