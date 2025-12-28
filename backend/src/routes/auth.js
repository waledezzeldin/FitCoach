const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const authController = require('../controllers/authController');
const { authMiddleware } = require('../middleware/auth');
const { rateLimiter } = require('../middleware/rateLimiter');

// ============================================
// PHONE OTP AUTHENTICATION
// ============================================

/**
 * @route   POST /api/v2/auth/send-otp
 * @desc    Send OTP to phone number
 * @access  Public
 */
router.post(
  '/send-otp',
  rateLimiter(5, 15), // 5 requests per 15 minutes
  [
    body('phoneNumber')
      .matches(/^\+966[0-9]{9}$/)
      .withMessage('Phone number must be in Saudi format (+966XXXXXXXXX)')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    await authController.sendOTP(req, res);
  }
);

/**
 * @route   POST /api/v2/auth/verify-otp
 * @desc    Verify OTP and login/register user
 * @access  Public
 */
router.post(
  '/verify-otp',
  rateLimiter(5, 15),
  [
    body('phoneNumber')
      .matches(/^\+966[0-9]{9}$/)
      .withMessage('Phone number must be in Saudi format'),
    body('otpCode')
      .isLength({ min: 4, max: 6 })
      .withMessage('OTP code must be 4-6 digits')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    await authController.verifyOTP(req, res);
  }
);

// ============================================
// EMAIL/PASSWORD AUTHENTICATION
// ============================================

/**
 * @route   POST /api/v2/auth/login
 * @desc    Login with email or phone + password
 * @access  Public
 */
router.post(
  '/login',
  rateLimiter(10, 15), // 10 requests per 15 minutes
  [
    body('emailOrPhone')
      .notEmpty()
      .withMessage('Email or phone is required'),
    body('password')
      .notEmpty()
      .withMessage('Password is required')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    await authController.login(req, res);
  }
);

/**
 * @route   POST /api/v2/auth/signup
 * @desc    Signup with email and password
 * @access  Public
 */
router.post(
  '/signup',
  rateLimiter(3, 60), // 3 requests per hour
  [
    body('name')
      .notEmpty()
      .withMessage('Name is required')
      .isLength({ min: 3 })
      .withMessage('Name must be at least 3 characters'),
    body('email')
      .isEmail()
      .withMessage('Valid email is required'),
    body('phone')
      .notEmpty()
      .withMessage('Phone is required'),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    await authController.signup(req, res);
  }
);

// ============================================
// SOCIAL AUTHENTICATION
// ============================================

/**
 * @route   POST /api/v2/auth/social-login
 * @desc    Login with social provider (Google, Facebook, Apple)
 * @access  Public
 */
router.post(
  '/social-login',
  rateLimiter(10, 15),
  [
    body('provider')
      .isIn(['google', 'facebook', 'apple'])
      .withMessage('Invalid provider'),
    body('socialId')
      .notEmpty()
      .withMessage('Social ID is required')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    await authController.socialLogin(req, res);
  }
);

// ============================================
// TOKEN MANAGEMENT
// ============================================

/**
 * @route   POST /api/v2/auth/refresh-token
 * @desc    Refresh JWT token
 * @access  Public
 */
router.post('/refresh-token', authController.refreshToken);

/**
 * @route   POST /api/v2/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post('/logout', authMiddleware, authController.logout);

/**
 * @route   GET /api/v2/auth/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/me', authMiddleware, authController.getCurrentUser);

module.exports = router;