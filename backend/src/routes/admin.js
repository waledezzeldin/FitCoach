const express = require('express');
const router = express.Router();
const { authMiddleware, roleCheck } = require('../middleware/auth');
const adminController = require('../controllers/adminController');

/**
 * @route   GET /api/v2/admin/analytics
 * @desc    Get dashboard analytics
 * @access  Private (Admin only)
 */
router.get('/analytics', authMiddleware, roleCheck('admin'), adminController.getDashboardAnalytics);

/**
 * @route   GET /api/v2/admin/users
 * @desc    Get users with filters
 * @access  Private (Admin only)
 */
router.get('/users', authMiddleware, roleCheck('admin'), adminController.getUsers);

/**
 * @route   GET /api/v2/admin/users/:id
 * @desc    Get user by ID
 * @access  Private (Admin only)
 */
router.get('/users/:id', authMiddleware, roleCheck('admin'), adminController.getUserById);

/**
 * @route   PUT /api/v2/admin/users/:id
 * @desc    Update user details
 * @access  Private (Admin only)
 */
router.put('/users/:id', authMiddleware, roleCheck('admin'), adminController.updateUser);

/**
 * @route   POST /api/v2/admin/users/:id/suspend
 * @desc    Suspend user
 * @access  Private (Admin only)
 */
router.post('/users/:id/suspend', authMiddleware, roleCheck('admin'), adminController.suspendUser);

/**
 * @route   DELETE /api/v2/admin/users/:id
 * @desc    Delete user
 * @access  Private (Admin only)
 */
router.delete('/users/:id', authMiddleware, roleCheck('admin'), adminController.deleteUser);

/**
 * @route   GET /api/v2/admin/coaches
 * @desc    Get coaches with filters
 * @access  Private (Admin only)
 */
router.get('/coaches', authMiddleware, roleCheck('admin'), adminController.getCoaches);

/**
 * @route   POST /api/v2/admin/coaches/:id/approve
 * @desc    Approve coach
 * @access  Private (Admin only)
 */
router.post('/coaches/:id/approve', authMiddleware, roleCheck('admin'), adminController.approveCoach);

/**
 * @route   POST /api/v2/admin/coaches/:id/suspend
 * @desc    Suspend coach
 * @access  Private (Admin only)
 */
router.post('/coaches/:id/suspend', authMiddleware, roleCheck('admin'), adminController.suspendCoach);

/**
 * @route   GET /api/v2/admin/revenue
 * @desc    Get revenue analytics
 * @access  Private (Admin only)
 */
router.get('/revenue', authMiddleware, roleCheck('admin'), adminController.getRevenueAnalytics);

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
