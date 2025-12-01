import request from 'supertest';
import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import app from '../src/main';
import { consumeQuota, getQuotaSnapshot } from '../src/subscription/quota.service';

function ensureCoachMessageMock(): jest.Mock {
  if (!(globalThis as any).__coachMessageCreate) {
    (globalThis as any).__coachMessageCreate = jest.fn();
  }
  return (globalThis as any).__coachMessageCreate as jest.Mock;
}

jest.mock('@prisma/client', () => {
  const asyncMock = (value: any = null) => jest.fn(async () => value);
  const createModelMock = () => ({
    findUnique: asyncMock(),
    findMany: asyncMock([]),
    findFirst: asyncMock(),
    create: asyncMock(),
    update: asyncMock(),
    delete: asyncMock(),
    count: asyncMock(0),
    aggregate: asyncMock({ _sum: { amount: 0 } }),
    groupBy: asyncMock([]),
  }) as any;

  return {
    PrismaClient: jest.fn().mockImplementation(() => {
      const coachMessageCreate = ensureCoachMessageMock();
      const base: Record<string, any> = {
        coachMessage: { create: coachMessageCreate },
        session: createModelMock(),
        coach: createModelMock(),
        commission: createModelMock(),
        user: createModelMock(),
        userIntake: createModelMock(),
        milestone: createModelMock(),
        nutritionLog: createModelMock(),
        subscriptionQuota: createModelMock(),
        $transaction: jest.fn(async (cb: any) => (typeof cb === 'function' ? cb(base) : null)),
        $connect: jest.fn(),
        $disconnect: jest.fn(),
        $use: jest.fn(),
      };

      return new Proxy(base, {
        get(target, prop) {
          if (prop in target) {
            return target[prop as keyof typeof target];
          }
          const model = createModelMock();
          target[prop as string] = model;
          return model;
        },
      });
    }),
  };
});

jest.mock('../src/subscription/quota.service', () => ({
  consumeQuota: jest.fn(),
  getQuotaSnapshot: jest.fn(),
}));

const mockConsumeQuota = consumeQuota as unknown as jest.Mock;
const mockGetQuotaSnapshot = getQuotaSnapshot as unknown as jest.Mock;
const coachMessageCreateMock = () => ensureCoachMessageMock();

describe('Coach messaging routes', () => {
  beforeEach(() => {
    coachMessageCreateMock().mockReset();
    mockConsumeQuota.mockReset();
    mockGetQuotaSnapshot.mockReset();
    mockGetQuotaSnapshot.mockImplementation(async () => null);
  });

  it('allows members to send messages when quota permits it', async () => {
    mockConsumeQuota.mockImplementation(async () => ({ allowed: true }));
    coachMessageCreateMock().mockImplementation(async () => ({ id: 'msg-1' }));

    const res = await request(app)
      .post('/v1/coaches/coach-1/messages')
      .send({ userId: 'user-1', sender: 'user', body: 'Need help with macros' });

    expect(res.status).toBe(201);
    expect(mockConsumeQuota).toHaveBeenCalledTimes(1);
    expect(mockConsumeQuota).toHaveBeenCalledWith(expect.anything(), 'user-1', 'message');
    expect(coachMessageCreateMock()).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ userId: 'user-1', sender: 'user', body: 'Need help with macros' }),
      }),
    );
  });

  it('blocks user messages when quota is exhausted', async () => {
    mockConsumeQuota.mockImplementation(async () => ({ allowed: false, reason: 'Message quota exceeded' }));

    const res = await request(app)
      .post('/v1/coaches/coach-1/messages')
      .send({ userId: 'user-1', sender: 'user', body: 'Anyone there?' });

    expect(res.status).toBe(409);
    expect(res.body.reason).toBe('Message quota exceeded');
    expect(coachMessageCreateMock()).not.toHaveBeenCalled();
  });

  it('applies attachment quota when files are uploaded', async () => {
    mockConsumeQuota
      .mockImplementationOnce(async () => ({ allowed: true }))
      .mockImplementationOnce(async () => ({ allowed: true }));
    coachMessageCreateMock().mockImplementation(async () => ({ id: 'msg-attachment' }));

    const res = await request(app)
      .post('/v1/coaches/coach-1/messages')
      .send({
        userId: 'user-2',
        sender: 'user',
        body: 'Sharing today\'s log',
        attachmentUrl: 'https://cdn.fitcoach.dev/logs/attachment.pdf',
        attachmentName: 'log.pdf',
      });

    expect(res.status).toBe(201);
    expect(mockConsumeQuota).toHaveBeenNthCalledWith(1, expect.anything(), 'user-2', 'message');
    expect(mockConsumeQuota).toHaveBeenNthCalledWith(2, expect.anything(), 'user-2', 'attachment');
    expect(coachMessageCreateMock()).toHaveBeenCalled();
  });

  it('rejects payloads without user identifiers', async () => {
    const res = await request(app)
      .post('/v1/coaches/coach-1/messages')
      .send({ sender: 'coach', body: 'Reminder to stretch' });

    expect(res.status).toBe(400);
    expect(mockConsumeQuota).not.toHaveBeenCalled();
  });
});
