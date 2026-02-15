const twilio = require('twilio');
const logger = require('../utils/logger');

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

/**
 * Send OTP via SMS
 */
exports.sendOTPSMS = async (phoneNumber, otpCode) => {
  try {
    const message = await client.messages.create({
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
    const result = await client.messages.create({
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
