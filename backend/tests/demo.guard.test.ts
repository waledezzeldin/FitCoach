import express from 'express';
import request from 'supertest';
import { describe, it, expect, beforeEach, jest } from '@jest/globals';

import demoRouter from '../src/demo.controller';
import paymentsRouter from '../src/payments.controller';
import notificationsRouter from '../src/notifications.controller';
import createDemoModeGuard from '../src/middleware/demo-mode.guard';

const mockSendPush = jest.fn();

// Shared types so generic mock inference works outside the jest.mock factory.
type Payment = { id: string; status: string; userId?: string };
type Notification = { id: string; read: boolean; userId?: string; title?: string; message?: string };

type MockFn<T extends (...args: any[]) => any> = jest.MockedFunction<T>;
type PrismaMockBucket = {
  paymentCreate: MockFn<(data?: unknown) => Promise<Payment>>;
  paymentFindMany: MockFn<() => Promise<Payment[]>>;
  notificationFindMany: MockFn<() => Promise<Notification[]>>;
  notificationCreate: MockFn<(data?: unknown) => Promise<Notification>>;
  notificationUpdate: MockFn<(data?: unknown) => Promise<Notification>>;
};

const getPrismaMocks = (): PrismaMockBucket => (globalThis as any).__prismaMocks;

jest.mock('../src/notifications/push.service', () => ({
  sendPushNotification: (...args: any[]) => mockSendPush(...args),
}));

jest.mock('@prisma/client', () => {
  const bucket: PrismaMockBucket = {
    paymentCreate: jest.fn(),
    paymentFindMany: jest.fn(),
    notificationFindMany: jest.fn(),
    notificationCreate: jest.fn(),
    notificationUpdate: jest.fn(),
  };
  (globalThis as any).__prismaMocks = bucket;
  return {
    PrismaClient: jest.fn(() => ({
      payment: {
        create: bucket.paymentCreate,
        findMany: bucket.paymentFindMany,
      },
      notification: {
        findMany: bucket.notificationFindMany,
        create: bucket.notificationCreate,
        update: bucket.notificationUpdate,
      },
    })),
  };
});

const {
  paymentCreate: mockPaymentCreate,
  paymentFindMany: mockPaymentFindMany,
  notificationFindMany: mockNotificationFindMany,
  notificationCreate: mockNotificationCreate,
  notificationUpdate: mockNotificationUpdate,
} = getPrismaMocks();

const buildApp = () => {
  const app = express();
  app.use(express.json());
  app.use(createDemoModeGuard());
  app.use(demoRouter);
  app.use('/v1/payments', paymentsRouter);
  app.use('/v1/notifications', notificationsRouter);
  app.post('/mutations', (_req, res) => res.status(201).json({ ok: true }));
  return app;
};

describe('Demo fixtures & guard middleware', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockPaymentCreate.mockResolvedValue({
      id: 'payment_1',
      status: 'pending',
    });
    mockNotificationCreate.mockResolvedValue({
      id: 'notification_1',
      read: false,
    });
    mockNotificationUpdate.mockResolvedValue({
      id: 'notification_1',
      read: true,
    });
  });

  it('serves persona-specific fixtures', async () => {
    const res = await request(buildApp())
      .get('/v1/demo/fixtures?persona=coach')
      .expect(200);

    expect(res.body.persona).toBe('coach');
    expect(res.body.user).toMatchObject({ role: 'coach' });
    expect(Array.isArray(res.body.availablePersonas)).toBe(true);
  });

  it('blocks mutating routes when the demo header is present', async () => {
    await request(buildApp())
      .post('/mutations')
      .set('X-Demo-Mode', '1')
      .send({})
      .expect(403);
  });

  it('allows mutations when no demo header is provided', async () => {
    await request(buildApp())
      .post('/mutations')
      .send({})
      .expect(201);
  });

  it('simulates payments without hitting the database in demo mode', async () => {
    const res = await request(buildApp())
      .post('/v1/payments')
      .set('X-Demo-Mode', '1')
      .send({ userId: 'u1', amount: 25, provider: 'stripe' })
      .expect(200);

    expect(res.body.demo).toBe(true);
    expect(res.body.status).toBe('simulated');
    expect(mockPaymentCreate).not.toHaveBeenCalled();
  });

  it('persists payments normally outside demo mode', async () => {
    const app = buildApp();
    mockPaymentCreate.mockResolvedValueOnce({
      id: 'payment_live',
      userId: 'live',
      status: 'pending',
    });

    const res = await request(app)
      .post('/v1/payments')
      .send({ userId: 'live', amount: 10, provider: 'stripe' })
      .expect(201);

    expect(res.body).toMatchObject({ id: 'payment_live' });
    expect(mockPaymentCreate).toHaveBeenCalled();
  });

  it('skips notification writes and push delivery inside demo mode', async () => {
    const res = await request(buildApp())
      .post('/v1/notifications')
      .set('X-Demo-Mode', '1')
      .send({ userId: 'u1', title: 'Hello', message: 'Demo', deviceToken: 'token' })
      .expect(200);

    expect(res.body.demo).toBe(true);
    expect(mockNotificationCreate).not.toHaveBeenCalled();
    expect(mockSendPush).not.toHaveBeenCalled();
  });
});
