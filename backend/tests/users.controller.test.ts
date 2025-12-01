import request from 'supertest';
import app from '../src/main';
import { describe, it, expect, beforeEach, jest } from '@jest/globals';

jest.mock('@prisma/client', () => {
  const actual = jest.requireActual<typeof import('@prisma/client')>('@prisma/client');
  const mockUserFindMany = jest.fn();
  (globalThis as any).__mockUserFindMany = mockUserFindMany;
  return {
    ...actual,
    PrismaClient: jest.fn(() => ({
      user: {
        findMany: mockUserFindMany,
      },
    })),
  };
});

process.env.NODE_ENV = 'test';

const getMockUserFindMany = () =>
  (globalThis as any).__mockUserFindMany as jest.MockedFunction<(args?: any) => Promise<any>>;

describe('Users Controller', () => {
  beforeEach(() => {
    const mock = getMockUserFindMany();
    mock.mockReset();
    mock.mockResolvedValue([
      { id: 'user-1', email: 'user1@example.com', name: 'User One' },
    ]);
  });

  it('should return 200 for GET /v1/users', async () => {
    const res = await request(app).get('/v1/users');
    expect(res.statusCode).toBe(200);
    expect(getMockUserFindMany()).toHaveBeenCalled();
  });
});