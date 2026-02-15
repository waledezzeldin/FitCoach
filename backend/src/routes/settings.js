const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const settingsController = require('../controllers/settingsController');

/**
 * @route   GET /api/v2/settings/notifications
 * @desc    Get user notification settings
 * @access  Private
 */
router.get('/notifications', authMiddleware, settingsController.getNotificationSettings);

/**
 * @route   PUT /api/v2/settings/notifications
 * @desc    Update notification settings
 * @access  Private
 */
router.put('/notifications', authMiddleware, settingsController.updateNotificationSettings);

/**
 * @route   GET /api/v2/settings/coach-profile
 * @desc    Get coach profile (coaches only)
 * @access  Private (Coaches only)
 */
router.get('/coach-profile', authMiddleware, settingsController.getCoachProfile);

/**
 * @route   PUT /api/v2/settings/coach-profile
 * @desc    Update coach profile
 * @access  Private (Coaches only)
 */
router.put('/coach-profile', authMiddleware, settingsController.updateCoachProfile);

/**
 * @route   GET /api/v2/settings/admin-profile
 * @desc    Get admin profile (admins only)
 * @access  Private (Admins only)
 */
router.get('/admin-profile', authMiddleware, settingsController.getAdminProfile);

/**
 * @route   POST /api/v2/settings/change-password
 * @desc    Change user password
 * @access  Private
 */
router.post('/change-password', authMiddleware, settingsController.changePassword);

/**
 * @route   DELETE /api/v2/settings/delete-account
 * @desc    Delete user account (soft delete)
 * @access  Private
 */
router.delete('/delete-account', authMiddleware, settingsController.deleteAccount);

module.exports = router;
