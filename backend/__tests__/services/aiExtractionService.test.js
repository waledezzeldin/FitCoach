const aiExtractionService = require('../../src/services/aiExtractionService');

describe('aiExtractionService.extractInBodyData', () => {
  const originalEnableFlag = process.env.ENABLE_SIMULATED_AI_EXTRACTION;
  const originalDelay = process.env.AI_EXTRACTION_DELAY_MS;

  afterEach(() => {
    process.env.ENABLE_SIMULATED_AI_EXTRACTION = originalEnableFlag;
    process.env.AI_EXTRACTION_DELAY_MS = originalDelay;
  });

  it('returns 503-style error when simulated extraction is disabled', async () => {
    process.env.ENABLE_SIMULATED_AI_EXTRACTION = 'false';

    await expect(
      aiExtractionService.extractInBodyData(Buffer.from('demo'), 'image/png')
    ).rejects.toMatchObject({
      message: 'AI extraction is currently disabled',
      statusCode: 503,
    });
  });

  it('returns simulated extraction payload when flag is enabled', async () => {
    process.env.ENABLE_SIMULATED_AI_EXTRACTION = 'true';
    process.env.AI_EXTRACTION_DELAY_MS = '0';

    const result = await aiExtractionService.extractInBodyData(
      Buffer.from('demo'),
      'image/png'
    );

    expect(result.success).toBe(true);
    expect(result.extractionMethod).toBe('simulated_ai_ocr');
    expect(result.data).toHaveProperty('weight');
  });
});
