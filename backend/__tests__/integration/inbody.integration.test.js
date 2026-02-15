const request = require('supertest');
const express = require('express');
const inbodyRoutes = require('../../src/routes/inbody');
const db = require('../../src/database');
const s3Service = require('../../src/services/s3Service');
const aiExtractionService = require('../../src/services/aiExtractionService');

jest.mock('../../src/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(),
  pool: { connect: jest.fn() }
}));

jest.mock('../../src/services/s3Service', () => ({
  uploadFile: jest.fn()
}));

jest.mock('../../src/services/aiExtractionService', () => ({
  validateInBodyImage: jest.fn(),
  extractInBodyData: jest.fn()
}));

jest.mock('../../src/middleware/auth', () => ({
  authMiddleware: (req, res, next) => {
    req.user = { userId: 'user-1', role: 'user', tier: 'premium' };
    next();
  }
}));

jest.mock('../../src/middleware/premiumFeatureMiddleware', () => ({
  requirePremiumTier: (req, res, next) => next()
}));

describe('InBody Integration Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/v2/inbody', inbodyRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should save a manual InBody scan', async () => {
    db.query.mockResolvedValueOnce({
      rows: [{ id: 'scan-1', weight: 80, bmi: 25, percent_body_fat: 20 }]
    });

    const response = await request(app)
      .post('/v2/inbody')
      .send({
        weight: 80,
        bmi: 25,
        percentBodyFat: 20,
        scanDate: '2026-02-01'
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.scan.id).toBe('scan-1');
  });

  it('should upload an InBody scan image for AI extraction', async () => {
    s3Service.uploadFile.mockResolvedValueOnce({ url: 'https://example.com/scan.jpg' });
    aiExtractionService.extractInBodyData.mockResolvedValueOnce({
      data: { weight: 80, bmi: 25, percentBodyFat: 20 },
      confidence: 0.92
    });

    const response = await request(app)
      .post('/v2/inbody/upload-image')
      .attach('file', Buffer.from('test-image'), 'scan.jpg');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.imageUrl).toBe('https://example.com/scan.jpg');
    expect(response.body.extractedData.weight).toBe(80);
  });

  it('should return InBody trends', async () => {
    db.query.mockResolvedValueOnce({
      rows: [{ scan_date: '2026-02-01', weight: 80 }]
    });

    const response = await request(app).get('/v2/inbody/trends');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.trends).toHaveLength(1);
  });

  it('should return InBody statistics', async () => {
    db.query.mockResolvedValueOnce({
      rows: [{ total_scans: '2', min_weight: 75, max_weight: 82 }]
    });

    const response = await request(app).get('/v2/inbody/statistics');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.statistics.total_scans).toBe('2');
  });
});
