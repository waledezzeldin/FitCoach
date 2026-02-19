const twilio = require('twilio');
const logger = require('../utils/logger');
const { isBypassEnabled } = require('../utils/featureFlags');

let client;

const getClient = () => {
  if (isBypassEnabled('BYPASS_TWILIO')) {
    return null;
  }

  if (!client) {
    client = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
  }

  return client;
};

/**
 * Send OTP via SMS
 */
exports.sendOTPSMS = async (phoneNumber, otpCode) => {
  try {
    if (isBypassEnabled('BYPASS_TWILIO')) {
      logger.info(`Twilio bypass enabled, skipping OTP SMS to ${phoneNumber}`);
      return {
        sid: `bypass_twilio_${Date.now()}`,
        status: 'bypassed',
        to: phoneNumber
      };
    }

    const twilioClient = getClient();
    const message = await twilioClient.messages.create({
      body: `Your FitCoach+ verification code is: ${otpCode}. Valid for 5 minutes.`,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: phoneNumber
    });
    
    logger.info(`OTP SMS sent to ${phoneNumber}, SID: ${message.sid}`);
    return message;
    
  } catch (error) {
    logger.error('Twilio SMS error:', error);
    throw new Error('Failed to send SMS');
  }
};

/**
 * Send notification SMS
 */
exports.sendNotificationSMS = async (phoneNumber, message) => {
  try {
    if (isBypassEnabled('BYPASS_TWILIO')) {
      logger.info(`Twilio bypass enabled, skipping notification SMS to ${phoneNumber}`);
      return {
        sid: `bypass_twilio_${Date.now()}`,
        status: 'bypassed',
        to: phoneNumber
      };
    }

    const twilioClient = getClient();
    const result = await twilioClient.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: phoneNumber
    });
    
    logger.info(`Notification SMS sent to ${phoneNumber}`);
    return result;
    
  } catch (error) {
    logger.error('Twilio SMS error:', error);
    throw new Error('Failed to send notification');
  }
};
