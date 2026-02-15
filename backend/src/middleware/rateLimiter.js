const rateLimit = require('express-rate-limit');

/**
 * Create rate limiter middleware
 * @param {number} max - Maximum number of requests
 * @param {number} windowMinutes - Time window in minutes
 */
exports.rateLimiter = (max = 100, windowMinutes = 15) => {
  return rateLimit({
    windowMs: windowMinutes * 60 * 1000,
    max,
    message: {
      success: false,
      message: 'Too many requests, please try again later'
    },
    standardHeaders: true,
    legacyHeaders: false,
  });
};

/**
 * Strict rate limiter for sensitive endpoints (login, OTP)
 */
exports.strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  message: {
    success: false,
    message: 'Too many attempts, please try again after 15 minutes'
  }
});

/**
 * General API rate limiter
 */
exports.apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: {
    success: false,
    message: 'Rate limit exceeded'
  }
});
