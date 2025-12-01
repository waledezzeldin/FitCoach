"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = require("supertest");
const main_1 = require("../src/main");
const globals_1 = require("@jest/globals");
globals_1.jest.mock('@prisma/client', () => {
    const actual = globals_1.jest.requireActual('@prisma/client');
    const mockUserFindMany = globals_1.jest.fn();
    globalThis.__mockUserFindMany = mockUserFindMany;
    return {
        ...actual,
        PrismaClient: globals_1.jest.fn(() => ({
            user: {
                findMany: mockUserFindMany,
            },
        })),
    };
});
process.env.NODE_ENV = 'test';
const getMockUserFindMany = () => globalThis.__mockUserFindMany;
(0, globals_1.describe)('Users Controller', () => {
    (0, globals_1.beforeEach)(() => {
        const mock = getMockUserFindMany();
        mock.mockReset();
        mock.mockResolvedValue([
            { id: 'user-1', email: 'user1@example.com', name: 'User One' },
        ]);
    });
    (0, globals_1.it)('should return 200 for GET /v1/users', async () => {
        const res = await (0, supertest_1.default)(main_1.default).get('/v1/users');
        (0, globals_1.expect)(res.statusCode).toBe(200);
        (0, globals_1.expect)(getMockUserFindMany()).toHaveBeenCalled();
    });
});
//# sourceMappingURL=users.controller.test.js.map