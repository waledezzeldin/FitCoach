const crypto = require('crypto');
const paymentController = require('../../src/controllers/paymentController');
const paymentService = require('../../src/services/paymentService');
const { mockRequest, mockResponse } = require('../helpers/testHelpers');

jest.mock('../../src/services/paymentService', () => ({
  handleTapWebhook: jest.fn(),
}));

jest.mock('stripe', () => () => ({
  webhooks: {
    constructEvent: jest.fn(),
  },
}));

describe('PaymentController.tapWebhook', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    process.env.TAP_WEBHOOK_SECRET = 'tap-webhook-secret';
  });

  it('rejects webhook when signature is invalid', async () => {
    const payload = { id: 'ch_1', status: 'CAPTURED' };
    const req = mockRequest({
      body: payload,
      rawBody: JSON.stringify(payload),
      headers: { 'tap-signature': 'invalid-signature' },
    });
    const res = mockResponse();

    await paymentController.tapWebhook(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(paymentService.handleTapWebhook).not.toHaveBeenCalled();
  });

  it('accepts webhook when signature is valid', async () => {
    const payload = { id: 'ch_2', status: 'CAPTURED', metadata: { userId: 'u-1' } };
    const rawBody = JSON.stringify(payload);
    const signature = crypto
      .createHmac('sha256', process.env.TAP_WEBHOOK_SECRET)
      .update(rawBody)
      .digest('hex');

    const req = mockRequest({
      body: payload,
      rawBody,
      headers: { 'tap-signature': signature },
    });
    const res = mockResponse();

    await paymentController.tapWebhook(req, res);

    expect(paymentService.handleTapWebhook).toHaveBeenCalledWith(payload);
    expect(res.json).toHaveBeenCalledWith({ received: true });
  });
});
