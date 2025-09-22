"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = require("supertest");
const main_1 = require("../src/main");
describe('Users Controller', () => {
    it('should return 200 for GET /v1/users', async () => {
        const res = await (0, supertest_1.default)(main_1.default).get('/v1/users');
        expect(res.statusCode).toBe(200);
    });
});
//# sourceMappingURL=users.controller.test.js.map