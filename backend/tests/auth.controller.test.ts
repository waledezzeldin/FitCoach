import express from 'express';
import request from 'supertest';
import { jest, describe, it, expect, beforeEach } from '@jest/globals';

type User = {
  id: string;
  name: string;
  email: string | null;
  phone: string;
  role: 'user' | 'coach';
};

const mockUserFindUnique: jest.MockedFunction<(args: any) => Promise<User | null>> = jest.fn();
const mockUserCreate: jest.MockedFunction<(args: any) => Promise<User>> = jest.fn();
const mockUserUpdate: jest.MockedFunction<(args: any) => Promise<User>> = jest.fn();
type DecodedToken = { phone_number?: string; name?: string; email?: string | null };
const mockVerifyIdToken: jest.MockedFunction<(token: string) => Promise<DecodedToken>> = jest.fn();

jest.mock('@prisma/client', () => {
  return {
    PrismaClient: jest.fn(() => ({
      user: {
        findUnique: mockUserFindUnique,
        create: mockUserCreate,
        update: mockUserUpdate,
      },
    })),
  };
});

jest.mock('firebase-admin', () => ({
  apps: [],
  credential: { applicationDefault: jest.fn(() => ({})) },
  initializeApp: jest.fn(),
  auth: () => ({ verifyIdToken: mockVerifyIdToken }),
}));

import router from '../src/auth.controller';

process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'test-secret';

describe('POST /auth/firebase/exchange', () => {
    const app = express();
    app.use(express.json());
    app.use(router);

    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('creates a new freemium user when phone is not mapped', async () => {
        mockVerifyIdToken.mockResolvedValue({
            phone_number: '+15551234567',
            name: 'Mina',
            email: null,
        });
        mockUserFindUnique.mockResolvedValue(null);
        mockUserCreate.mockResolvedValue({
            id: 'user_1',
            name: 'Mina',
            email: 'phone_15551234567@fitcoach.app',
            phone: '+15551234567',
            role: 'user',
        });

        const res = await request(app)
            .post('/auth/firebase/exchange')
            .send({ idToken: 'mock-token' })
            .expect(200);

        expect(mockUserCreate).toHaveBeenCalledWith({
            data: expect.objectContaining({
                phone: '+15551234567',
                role: 'user',
            }),
        });
        expect(res.body.subscriptionType).toBe('freemium');
        expect(res.body.user).toMatchObject({
            phone: '+15551234567',
            role: 'user',
        });
    });

    it('promotes mapped phones to coach role and smart premium subscription', async () => {
        mockVerifyIdToken.mockResolvedValue({
            phone_number: '+966507654321',
            name: 'Coach Sarah',
            email: 'coach@fitcoach.com',
        });
        mockUserFindUnique.mockResolvedValue({
            id: 'coach_1',
            name: 'Coach Sarah',
            email: 'coach@fitcoach.com',
            phone: '+966507654321',
            role: 'user',
        });
        mockUserUpdate.mockResolvedValue({
            id: 'coach_1',
            name: 'Coach Sarah',
            email: 'coach@fitcoach.com',
            phone: '+966507654321',
            role: 'coach',
        });

        const res = await request(app)
            .post('/auth/firebase/exchange')
            .send({ idToken: 'coach-token' })
            .expect(200);

        expect(mockUserUpdate).toHaveBeenCalledWith({
            where: { id: 'coach_1' },
            data: { role: 'coach' },
        });
        expect(res.body.subscriptionType).toBe('smart_premium');
        expect(res.body.user).toMatchObject({ role: 'coach' });
    });

    it('rejects requests without an idToken', async () => {
        const res = await request(app)
            .post('/auth/firebase/exchange')
            .send({})
            .expect(400);

        expect(res.body).toHaveProperty('error', 'idToken required.');
        expect(mockVerifyIdToken).not.toHaveBeenCalled();
    });
});
