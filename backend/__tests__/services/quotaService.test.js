const quotaService = require('../../src/services/quotaService');
const db = require('../../src/database');

jest.mock('../../src/database');

describe('QuotaService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('resetMonthlyQuotas', () => {
    it('should reset monthly quotas and return affected users', async () => {
      const rows = [{ id: 'user-1' }, { id: 'user-2' }];
      db.query.mockResolvedValue({ rows });

      const result = await quotaService.resetMonthlyQuotas();

      expect(db.query).toHaveBeenCalled();
      expect(result).toEqual(rows);
    });

    it('should throw on database error', async () => {
      db.query.mockRejectedValue(new Error('Database error'));

      await expect(quotaService.resetMonthlyQuotas()).rejects.toThrow('Database error');
    });
  });

  describe('incrementMessageCount', () => {
    it('should increment message count', async () => {
      db.query.mockResolvedValue({ rowCount: 1 });

      await quotaService.incrementMessageCount('test-user-id');

      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining('messages_sent_this_month = messages_sent_this_month + 1'),
        ['test-user-id']
      );
    });

    it('should throw on database error', async () => {
      db.query.mockRejectedValue(new Error('Database error'));

      await expect(
        quotaService.incrementMessageCount('test-user-id')
      ).rejects.toThrow('Database error');
    });
  });

  describe('incrementCallCount', () => {
    it('should increment call count', async () => {
      db.query.mockResolvedValue({ rowCount: 1 });

      await quotaService.incrementCallCount('test-user-id');

      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining('video_calls_this_month = video_calls_this_month + 1'),
        ['test-user-id']
      );
    });

    it('should throw on database error', async () => {
      db.query.mockRejectedValue(new Error('Database error'));

      await expect(
        quotaService.incrementCallCount('test-user-id')
      ).rejects.toThrow('Database error');
    });
  });

  describe('incrementQuota', () => {
    it('should increment message quota for messages type', async () => {
      db.query.mockResolvedValue({ rowCount: 1 });

      await quotaService.incrementQuota('test-user-id', 'messages');

      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining('messages_sent_this_month = messages_sent_this_month + 1'),
        ['test-user-id']
      );
    });

    it('should increment call quota for videoCalls type', async () => {
      db.query.mockResolvedValue({ rowCount: 1 });

      await quotaService.incrementQuota('test-user-id', 'videoCalls');

      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining('video_calls_this_month = video_calls_this_month + 1'),
        ['test-user-id']
      );
    });

    it('should throw for unsupported types', async () => {
      await expect(
        quotaService.incrementQuota('test-user-id', 'invalid')
      ).rejects.toThrow('Unsupported quota type: invalid');
    });
  });

  describe('getQuotaStatus', () => {
    it('should return quota status row when present', async () => {
      const row = {
        user_id: 'test-user-id',
        subscription_tier: 'freemium',
        message_quota: 20,
        call_quota: 1,
        messages_sent_this_month: 5,
        video_calls_this_month: 0
      };

      db.query.mockResolvedValue({ rows: [row] });

      const result = await quotaService.getQuotaStatus('test-user-id');

      expect(db.query).toHaveBeenCalled();
      expect(result).toEqual(row);
    });

    it('should return null when user not found', async () => {
      db.query.mockResolvedValue({ rows: [] });

      const result = await quotaService.getQuotaStatus('missing-id');

      expect(result).toBeNull();
    });
  });

  describe('canSendMessage', () => {
    it('should return false when no quota status', async () => {
      db.query.mockResolvedValue({ rows: [] });

      const result = await quotaService.canSendMessage('missing-id');

      expect(result).toBe(false);
    });

    it('should allow unlimited messages when quota is -1', async () => {
      db.query.mockResolvedValue({
        rows: [{ message_quota: -1, messages_sent_this_month: 999 }]
      });

      const result = await quotaService.canSendMessage('test-user-id');

      expect(result).toBe(true);
    });

    it('should allow messages when under quota', async () => {
      db.query.mockResolvedValue({
        rows: [{ message_quota: 20, messages_sent_this_month: 5 }]
      });

      const result = await quotaService.canSendMessage('test-user-id');

      expect(result).toBe(true);
    });

    it('should block messages when quota exceeded', async () => {
      db.query.mockResolvedValue({
        rows: [{ message_quota: 20, messages_sent_this_month: 20 }]
      });

      const result = await quotaService.canSendMessage('test-user-id');

      expect(result).toBe(false);
    });
  });

  describe('canBookCall', () => {
    it('should return false when no quota status', async () => {
      db.query.mockResolvedValue({ rows: [] });

      const result = await quotaService.canBookCall('missing-id');

      expect(result).toBe(false);
    });

    it('should allow calls when under quota', async () => {
      db.query.mockResolvedValue({
        rows: [{ call_quota: 2, video_calls_this_month: 1 }]
      });

      const result = await quotaService.canBookCall('test-user-id');

      expect(result).toBe(true);
    });

    it('should block calls when quota exceeded', async () => {
      db.query.mockResolvedValue({
        rows: [{ call_quota: 2, video_calls_this_month: 2 }]
      });

      const result = await quotaService.canBookCall('test-user-id');

      expect(result).toBe(false);
    });
  });

  describe('startNutritionTrial', () => {
    it('should start nutrition trial for freemium user', async () => {
      db.query.mockResolvedValue({ rowCount: 1 });

      await quotaService.startNutritionTrial('test-user-id');

      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining('nutrition_trial_active = TRUE'),
        ['test-user-id']
      );
    });

    it('should throw on database error', async () => {
      db.query.mockRejectedValue(new Error('Database error'));

      await expect(
        quotaService.startNutritionTrial('test-user-id')
      ).rejects.toThrow('Database error');
    });
  });
});
