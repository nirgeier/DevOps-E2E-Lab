const request = require('supertest');
const app = require('../app');

describe('GET /', () => {
  it('should return hello message', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.body.message).toBe('Hello from Node.js microservice!');
  });
});

describe('GET /error', () => {
  it('should simulate error', async () => {
    const res = await request(app).get('/error');
    expect(res.statusCode).toEqual(500);
    expect(res.body.error).toBe('Simulated error');
  });
});
