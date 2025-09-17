import request from 'supertest';
import app from '../src/main';

describe('Users Controller', () => {
  it('should return 200 for GET /v1/users', async () => {
    const res = await request(app).get('/v1/users');
    expect(res.statusCode).toBe(200);
  });
});