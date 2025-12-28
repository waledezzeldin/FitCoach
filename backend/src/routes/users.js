const express = require('express');
const router = express.Router();
const { authMiddleware, tierCheck } = require('../middleware/auth');
const userController = require('../controllers/userController');
const settingsController = require('../controllers/settingsController');
const { body } = require('express-validator');
const upload = require('../middleware/upload');

/**
 * @route   GET /api/v2/users/:id
 * @desc    Get user profile
 * @access  Private
 */
router.get('/:id', authMiddleware, userController.getUserProfile);

/**
 * @route   PUT /api/v2/users/:id
 * @desc    Update user profile
 * @access  Private
 */
router.put('/:id', authMiddleware, [
  body('fullName').optional().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('email').optional().isEmail().withMessage('Invalid email format'),
], userController.updateProfile);

/**
 * @route   POST /api/v2/users/first-intake
 * @desc    Complete first intake (5 questions - all users)
 * @access  Private
 */
router.post('/first-intake', authMiddleware, [
  body('goal').isIn(['fat_loss', 'muscle_gain', 'maintenance', 'athletic_performance', 'general_fitness']),
  body('fitnessLevel').isIn(['beginner', 'intermediate', 'advanced', 'expert']),
  body('age').isInt({ min: 13, max: 120 }),
  body('weight').isFloat({ min: 20, max: 300 }),
  body('height').isFloat({ min: 100, max: 250 }),
  body('activityLevel').isIn(['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active']),
], userController.completeFirstIntake);

/**
 * @route   POST /api/v2/users/second-intake
 * @desc    Complete second intake (6 questions - Premium+ only)
 * @access  Private (Premium+ only)
 */
router.post('/second-intake', 
  authMiddleware, 
  tierCheck('premium', 'smart_premium'),
  userController.completeSecondIntake
);

/**
 * @route   GET /api/v2/users/:id/quota
 * @desc    Get user's quota status
 * @access  Private
 */
router.get('/:id/quota', authMiddleware, userController.getQuotaStatus);

/**
 * @route   POST /api/v2/users/start-trial
 * @desc    Start nutrition trial (Freemium only)
 * @access  Private (Freemium only)
 */
router.post('/start-trial', 
  authMiddleware,
  tierCheck('freemium'),
  userController.startNutritionTrial
);

/**
 * @route   POST /api/v2/users/:id/upload-photo
 * @desc    Upload profile photo
 * @access  Private
 */
router.post('/:id/upload-photo', authMiddleware, upload.uploadProfilePhoto, userController.uploadPhoto);

module.exports = router;
