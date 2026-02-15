const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const notificationController = require('../controllers/notificationController');

// Device management
router.post('/register-device', authMiddleware, notificationController.registerDevice);
router.post('/unregister-device', authMiddleware, notificationController.unregisterDevice);

// Preferences
router.get('/preferences', authMiddleware, notificationController.getPreferences);
router.put('/preferences', authMiddleware, notificationController.updatePreferences);

// History
router.get('/history', authMiddleware, notificationController.getHistory);
router.put('/:notificationId/clicked', authMiddleware, notificationController.markAsClicked);

// Test notification
router.post('/test', authMiddleware, notificationController.sendTestNotification);

module.exports = router;
