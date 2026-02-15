const { body, param, query, validationResult } = require('express-validator');

/**
 * Input Validation Middleware
 * Uses express-validator for comprehensive input validation
 */

/**
 * Handle validation errors
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: err.param,
        message: err.msg,
        value: err.value
      }))
    });
  }
  next();
};

/**
 * Auth Validation Rules
 */
exports.validateSendOTP = [
  body('phoneNumber')
    .trim()
    .notEmpty().withMessage('Phone number is required')
    .matches(/^\+?[1-9]\d{1,14}$/).withMessage('Invalid phone number format')
    .custom((value) => {
      // Saudi phone numbers should start with +966
      if (value.startsWith('+966') && value.length !== 13) {
        throw new Error('Saudi phone number must be 13 characters including +966');
      }
      return true;
    }),
  handleValidationErrors
];

exports.validateVerifyOTP = [
  body('phoneNumber')
    .trim()
    .notEmpty().withMessage('Phone number is required')
    .matches(/^\+?[1-9]\d{1,14}$/).withMessage('Invalid phone number format'),
  body('otpCode')
    .trim()
    .notEmpty().withMessage('OTP code is required')
    .isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits')
    .isNumeric().withMessage('OTP must contain only numbers'),
  handleValidationErrors
];

/**
 * User Validation Rules
 */
exports.validateUpdateProfile = [
  body('fullName')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
  body('email')
    .optional()
    .trim()
    .isEmail().withMessage('Invalid email address')
    .normalizeEmail(),
  body('gender')
    .optional()
    .isIn(['male', 'female', 'other']).withMessage('Invalid gender'),
  body('dateOfBirth')
    .optional()
    .isISO8601().withMessage('Invalid date format')
    .custom((value) => {
      const age = (new Date() - new Date(value)) / (365.25 * 24 * 60 * 60 * 1000);
      if (age < 13) {
        throw new Error('Must be at least 13 years old');
      }
      if (age > 120) {
        throw new Error('Invalid age');
      }
      return true;
    }),
  body('age')
    .optional()
    .isInt({ min: 13, max: 120 }).withMessage('Age must be between 13 and 120'),
  body('height')
    .optional()
    .isFloat({ min: 50, max: 300 }).withMessage('Height must be between 50 and 300 cm'),
  body('weight')
    .optional()
    .isFloat({ min: 20, max: 500 }).withMessage('Weight must be between 20 and 500 kg'),
  handleValidationErrors
];

/**
 * Intake Validation Rules
 */
exports.validateStage1Intake = [
  body('goal')
    .notEmpty().withMessage('Goal is required')
    .isIn(['weight_loss', 'muscle_gain', 'general_fitness', 'athletic_performance'])
    .withMessage('Invalid goal'),
  body('location')
    .notEmpty().withMessage('Location is required')
    .isIn(['gym', 'home']).withMessage('Invalid location'),
  body('trainingDays')
    .notEmpty().withMessage('Training days is required')
    .isInt({ min: 2, max: 7 }).withMessage('Training days must be between 2 and 7'),
  handleValidationErrors
];

exports.validateStage2Intake = [
  body('fitnessLevel')
    .notEmpty().withMessage('Fitness level is required')
    .isIn(['beginner', 'intermediate', 'advanced']).withMessage('Invalid fitness level'),
  body('experience')
    .notEmpty().withMessage('Experience is required')
    .isIn(['none', 'less_than_1', '1_to_3', 'more_than_3']).withMessage('Invalid experience'),
  body('equipment')
    .optional()
    .isArray().withMessage('Equipment must be an array'),
  body('injuries')
    .optional()
    .isArray().withMessage('Injuries must be an array'),
  body('medicalConditions')
    .optional()
    .isArray().withMessage('Medical conditions must be an array'),
  handleValidationErrors
];

/**
 * Message Validation Rules
 */
exports.validateSendMessage = [
  body('content')
    .optional()
    .trim()
    .isLength({ min: 1, max: 5000 }).withMessage('Message must be between 1 and 5000 characters'),
  body('conversationId')
    .optional()
    .isUUID().withMessage('Invalid conversation ID'),
  body('recipientId')
    .optional()
    .isUUID().withMessage('Invalid recipient ID'),
  body('messageType')
    .optional()
    .isIn(['text', 'image', 'file', 'voice']).withMessage('Invalid message type'),
  body()
    .custom((value) => {
      // Either content or attachmentUrl must be provided
      if (!value.content && !value.attachmentUrl) {
        throw new Error('Either content or attachment must be provided');
      }
      // Either conversationId or recipientId must be provided
      if (!value.conversationId && !value.recipientId) {
        throw new Error('Either conversationId or recipientId must be provided');
      }
      return true;
    }),
  handleValidationErrors
];

/**
 * Workout Validation Rules
 */
exports.validateLogWorkout = [
  body('workoutPlanId')
    .notEmpty().withMessage('Workout plan ID is required')
    .isUUID().withMessage('Invalid workout plan ID'),
  body('sessionNumber')
    .notEmpty().withMessage('Session number is required')
    .isInt({ min: 1 }).withMessage('Invalid session number'),
  body('exercises')
    .isArray({ min: 1 }).withMessage('At least one exercise is required'),
  body('exercises.*.exerciseId')
    .notEmpty().withMessage('Exercise ID is required'),
  body('exercises.*.sets')
    .isInt({ min: 0 }).withMessage('Sets must be a positive number'),
  body('exercises.*.reps')
    .isInt({ min: 0 }).withMessage('Reps must be a positive number'),
  body('exercises.*.weight')
    .optional()
    .isFloat({ min: 0 }).withMessage('Weight must be a positive number'),
  handleValidationErrors
];

/**
 * Payment Validation Rules
 */
exports.validateCreateCheckout = [
  body('tier')
    .notEmpty().withMessage('Tier is required')
    .isIn(['premium', 'smart_premium']).withMessage('Invalid subscription tier'),
  body('billingCycle')
    .optional()
    .isIn(['monthly', 'yearly']).withMessage('Invalid billing cycle'),
  body('provider')
    .optional()
    .isIn(['stripe', 'tap']).withMessage('Invalid payment provider'),
  handleValidationErrors
];

/**
 * Booking Validation Rules
 */
exports.validateCreateBooking = [
  body('coachId')
    .notEmpty().withMessage('Coach ID is required')
    .isUUID().withMessage('Invalid coach ID'),
  body('scheduledFor')
    .notEmpty().withMessage('Scheduled time is required')
    .isISO8601().withMessage('Invalid date format')
    .custom((value) => {
      const scheduledDate = new Date(value);
      const now = new Date();
      const maxAdvance = new Date();
      maxAdvance.setDate(maxAdvance.getDate() + 60); // Max 60 days in advance
      
      if (scheduledDate < now) {
        throw new Error('Cannot schedule calls in the past');
      }
      if (scheduledDate > maxAdvance) {
        throw new Error('Cannot schedule calls more than 60 days in advance');
      }
      return true;
    }),
  body('duration')
    .optional()
    .isInt({ min: 15, max: 120 }).withMessage('Duration must be between 15 and 120 minutes'),
  body('notes')
    .optional()
    .trim()
    .isLength({ max: 500 }).withMessage('Notes must be less than 500 characters'),
  handleValidationErrors
];

/**
 * Rating Validation Rules
 */
exports.validateCreateRating = [
  body('targetId')
    .notEmpty().withMessage('Target ID is required')
    .isUUID().withMessage('Invalid target ID'),
  body('targetType')
    .notEmpty().withMessage('Target type is required')
    .isIn(['coach', 'workout', 'nutrition', 'booking']).withMessage('Invalid target type'),
  body('rating')
    .notEmpty().withMessage('Rating is required')
    .isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('comment')
    .optional()
    .trim()
    .isLength({ max: 1000 }).withMessage('Comment must be less than 1000 characters'),
  handleValidationErrors
];

/**
 * Progress Validation Rules
 */
exports.validateLogProgress = [
  body('weight')
    .optional()
    .isFloat({ min: 20, max: 500 }).withMessage('Weight must be between 20 and 500 kg'),
  body('bodyFatPercentage')
    .optional()
    .isFloat({ min: 3, max: 60 }).withMessage('Body fat must be between 3 and 60%'),
  body('muscleMass')
    .optional()
    .isFloat({ min: 0, max: 300 }).withMessage('Invalid muscle mass'),
  body('waistCircumference')
    .optional()
    .isFloat({ min: 30, max: 200 }).withMessage('Waist must be between 30 and 200 cm'),
  handleValidationErrors
];

/**
 * Nutrition Validation Rules
 */
exports.validateLogMeal = [
  body('mealType')
    .notEmpty().withMessage('Meal type is required')
    .isIn(['breakfast', 'lunch', 'dinner', 'snack']).withMessage('Invalid meal type'),
  body('foodItems')
    .isArray({ min: 1 }).withMessage('At least one food item is required'),
  body('calories')
    .optional()
    .isInt({ min: 0, max: 10000 }).withMessage('Calories must be between 0 and 10000'),
  body('protein')
    .optional()
    .isFloat({ min: 0, max: 1000 }).withMessage('Invalid protein amount'),
  body('carbs')
    .optional()
    .isFloat({ min: 0, max: 1000 }).withMessage('Invalid carbs amount'),
  body('fats')
    .optional()
    .isFloat({ min: 0, max: 1000 }).withMessage('Invalid fats amount'),
  handleValidationErrors
];

/**
 * Admin Validation Rules
 */
exports.validateAssignCoach = [
  body('userId')
    .notEmpty().withMessage('User ID is required')
    .isUUID().withMessage('Invalid user ID'),
  body('coachId')
    .notEmpty().withMessage('Coach ID is required')
    .isUUID().withMessage('Invalid coach ID'),
  handleValidationErrors
];

/**
 * Query Parameter Validation
 */
exports.validatePagination = [
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('offset')
    .optional()
    .isInt({ min: 0 }).withMessage('Offset must be a positive number'),
  handleValidationErrors
];

exports.validateUUIDParam = [
  param('id')
    .isUUID().withMessage('Invalid ID format'),
  handleValidationErrors
];

/**
 * File Upload Validation
 */
exports.validateFileUpload = (allowedTypes = [], maxSize = 5 * 1024 * 1024) => {
  return (req, res, next) => {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    // Check file size
    if (req.file.size > maxSize) {
      return res.status(400).json({
        success: false,
        message: `File size must not exceed ${maxSize / (1024 * 1024)}MB`
      });
    }

    // Check file type
    if (allowedTypes.length > 0 && !allowedTypes.includes(req.file.mimetype)) {
      return res.status(400).json({
        success: false,
        message: `Invalid file type. Allowed types: ${allowedTypes.join(', ')}`
      });
    }

    next();
  };
};

/**
 * Sanitize user input (additional layer of security)
 */
exports.sanitizeInput = (req, res, next) => {
  // Remove any potential script tags from all string inputs
  const sanitize = (obj) => {
    for (let key in obj) {
      if (typeof obj[key] === 'string') {
        obj[key] = obj[key]
          .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
          .replace(/javascript:/gi, '')
          .replace(/on\w+\s*=/gi, '');
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        sanitize(obj[key]);
      }
    }
  };

  if (req.body) sanitize(req.body);
  if (req.query) sanitize(req.query);
  if (req.params) sanitize(req.params);

  next();
};

module.exports = exports;
