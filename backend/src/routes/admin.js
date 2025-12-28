const express = require('express');
const router = express.Router();
const { authMiddleware, roleCheck } = require('../middleware/auth');
const adminController = require('../controllers/adminController');

/**
 * @route   GET /api/v2/admin/audit-logs
 * @desc    Get audit logs
 * @access  Private (Admin only)
 */
router.get('/audit-logs', authMiddleware, roleCheck('admin'), adminController.getAuditLogs);

/**
 * @route   GET /api/v2/admin/exercises
 * @desc    Get all exercises
 * @access  Private (Admin only)
 */
router.get('/exercises', authMiddleware, roleCheck('admin'), adminController.getExercises);

/**
 * @route   POST /api/v2/admin/exercises
 * @desc    Create new exercise
 * @access  Private (Admin only)
 */
router.post('/exercises', authMiddleware, roleCheck('admin'), adminController.createExercise);

/**
 * @route   PUT /api/v2/admin/exercises/:id
 * @desc    Update exercise
 * @access  Private (Admin only)
 */
router.put('/exercises/:id', authMiddleware, roleCheck('admin'), adminController.updateExercise);

/**
 * @route   DELETE /api/v2/admin/exercises/:id
 * @desc    Delete exercise
 * @access  Private (Admin only)
 */
router.delete('/exercises/:id', authMiddleware, roleCheck('admin'), adminController.deleteExercise);

/**
 * @route   GET /api/v2/admin/subscription-plans
 * @desc    Get all subscription plans
 * @access  Private (Admin only)
 */
router.get('/subscription-plans', authMiddleware, roleCheck('admin'), adminController.getSubscriptionPlans);

/**
 * @route   PUT /api/v2/admin/subscription-plans/:id
 * @desc    Update subscription plan
 * @access  Private (Admin only)
 */
router.put('/subscription-plans/:id', authMiddleware, roleCheck('admin'), adminController.updateSubscriptionPlan);

/**
 * @route   GET /api/v2/admin/settings
 * @desc    Get system settings
 * @access  Private (Admin only)
 */
router.get('/settings', authMiddleware, roleCheck('admin'), adminController.getSystemSettings);

/**
 * @route   PUT /api/v2/admin/settings
 * @desc    Update system settings
 * @access  Private (Admin only)
 */
router.put('/settings', authMiddleware, roleCheck('admin'), adminController.updateSystemSettings);

module.exports = router;