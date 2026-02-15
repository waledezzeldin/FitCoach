const videoCallService = require('../../src/services/videoCallService');
const db = require('../../src/database');

jest.mock('../../src/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(),
  pool: { connect: jest.fn() }
}));

describe('VideoCallService', () => {
  afterEach(() => {
    jest.clearAllMocks();
    jest.useRealTimers();
  });

  describe('canJoinCall', () => {
    it('should block too-early joins', async () => {
      jest.useFakeTimers().setSystemTime(new Date('2024-01-01T10:00:00Z'));
      db.query.mockResolvedValue({
        rows: [
          {
            id: 'apt-1',
            user_id: 'user-1',
            coach_user_id: 'coach-1',
            status: 'confirmed',
            scheduled_at: '2024-01-01T10:20:00Z'
          }
        ]
      });

      const result = await videoCallService.canJoinCall('apt-1', 'user-1');

      expect(result.canJoin).toBe(false);
      expect(result.reason).toBe('Too early to join');
    });

    it('should block late joins', async () => {
      jest.useFakeTimers().setSystemTime(new Date('2024-01-01T12:30:00Z'));
      db.query.mockResolvedValue({
        rows: [
          {
            id: 'apt-1',
            user_id: 'user-1',
            coach_user_id: 'coach-1',
            status: 'confirmed',
            scheduled_at: '2024-01-01T10:00:00Z',
            duration_minutes: 30
          }
        ]
      });

      const result = await videoCallService.canJoinCall('apt-1', 'user-1');

      expect(result.canJoin).toBe(false);
      expect(result.reason).toBe('Appointment time has passed');
    });

    it('should allow joins within duration + 15 minutes window', async () => {
      jest.useFakeTimers().setSystemTime(new Date('2024-01-01T10:40:00Z'));
      db.query.mockResolvedValue({
        rows: [
          {
            id: 'apt-1',
            user_id: 'user-1',
            coach_user_id: 'coach-1',
            status: 'confirmed',
            scheduled_at: '2024-01-01T10:00:00Z',
            duration_minutes: 30
          }
        ]
      });

      const result = await videoCallService.canJoinCall('apt-1', 'user-1');

      expect(result.canJoin).toBe(true);
    });

    it('should block unauthorized users', async () => {
      db.query.mockResolvedValue({
        rows: [
          {
            id: 'apt-1',
            user_id: 'user-1',
            coach_user_id: 'coach-1',
            status: 'confirmed',
            scheduled_at: '2024-01-01T10:00:00Z'
          }
        ]
      });

      const result = await videoCallService.canJoinCall('apt-1', 'other-user');

      expect(result.canJoin).toBe(false);
      expect(result.reason).toBe('Not authorized');
    });
  });

  describe('endCallSession', () => {
    it('should complete session and update appointment status', async () => {
      const mockClient = {
        query: jest.fn()
          .mockResolvedValueOnce({}) // BEGIN
          .mockResolvedValueOnce({
            rows: [
              {
                id: 'session-1',
                user_id: 'user-1',
                coach_user_id: 'coach-1'
              }
            ]
          })
          .mockResolvedValueOnce({}) // update video_call_sessions
          .mockResolvedValueOnce({}) // update appointments
          .mockResolvedValueOnce({}) // update users
          .mockResolvedValueOnce({}), // COMMIT
        release: jest.fn()
      };

      db.getClient.mockResolvedValue(mockClient);

      const result = await videoCallService.endCallSession('apt-1', 'user-1', 30);

      expect(result.success).toBe(true);
      expect(result.duration).toBe(30);
      expect(mockClient.query).toHaveBeenCalledWith(
        expect.stringContaining('UPDATE video_call_sessions'),
        expect.any(Array)
      );
      expect(mockClient.query).toHaveBeenCalledWith(
        expect.stringContaining("SET status = 'completed'"),
        expect.any(Array)
      );
      expect(mockClient.query).toHaveBeenCalledWith(
        expect.stringContaining('UPDATE appointments'),
        expect.any(Array)
      );
    });
  });
});
