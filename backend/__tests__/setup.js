// Test setup and global configuration
require('dotenv').config({ path: '.env.test' });

// Mock logger to reduce noise in tests
jest.mock('../src/utils/logger', () => ({
  info: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  debug: jest.fn()
}));

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-secret-key';
process.env.JWT_EXPIRES_IN = '1h';
process.env.JWT_REFRESH_EXPIRES_IN = '7d';

// Database test config
process.env.DB_HOST = 'localhost';
process.env.DB_PORT = '5432';
process.env.DB_NAME = 'fitcoach_test';
process.env.DB_USER = 'postgres';
process.env.DB_PASSWORD = 'postgres';

// Twilio test config
process.env.TWILIO_ACCOUNT_SID = 'AC123456789012345678901234567890';
process.env.TWILIO_AUTH_TOKEN = 'test_auth_token';
process.env.TWILIO_PHONE_NUMBER = '+15005550006';

// AWS test config
process.env.AWS_ACCESS_KEY_ID = 'test_access_key';
process.env.AWS_SECRET_ACCESS_KEY = 'test_secret_key';
process.env.AWS_REGION = 'me-south-1';
process.env.AWS_S3_BUCKET = 'test-bucket';

// SMTP test config
process.env.SMTP_HOST = 'smtp.test.com';
process.env.SMTP_PORT = '587';
process.env.SMTP_USER = 'test@test.com';
process.env.SMTP_PASSWORD = 'test_password';

// Global test timeout
jest.setTimeout(10000);

// Suppress console.log in tests
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn()
};
