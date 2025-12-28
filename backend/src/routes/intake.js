const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const intakeController = require('../controllers/intakeController');

/**
 * Intake Routes
 * Two-stage intake system
 */

// Stage 1: Basic intake (3 questions - all users)
router.post('/stage1', authMiddleware, intakeController.submitStage1);

// Stage 2: Full intake (Premium+ only)
router.post('/stage2', authMiddleware, intakeController.submitStage2);

// Get intake status
router.get('/status', authMiddleware, intakeController.getStatus);

// Check if user should be prompted for Stage 2
router.get('/prompt', authMiddleware, intakeController.checkPrompt);

module.exports = router;
