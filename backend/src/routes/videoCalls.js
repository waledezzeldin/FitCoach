const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const videoCallController = require('../controllers/videoCallController');

/**
 * @route   POST /api/v2/video-calls/:appointmentId/start
 * @desc    Start video call for appointment
 * @access  Private
 */
router.post('/:appointmentId/start', authMiddleware, videoCallController.startCall);

/**
 * @route   GET /api/v2/video-calls/:appointmentId/token
 * @desc    Get token to join existing call
 * @access  Private
 */
router.get('/:appointmentId/token', authMiddleware, videoCallController.getToken);

/**
 * @route   POST /api/v2/video-calls/:appointmentId/end
 * @desc    End video call
 * @access  Private
 */
router.post('/:appointmentId/end', authMiddleware, videoCallController.endCall);

/**
 * @route   GET /api/v2/video-calls/:appointmentId/can-join
 * @desc    Check if user can join call
 * @access  Private
 */
router.get('/:appointmentId/can-join', authMiddleware, videoCallController.canJoin);

/**
 * @route   GET /api/v2/video-calls/:appointmentId/status
 * @desc    Get call session status
 * @access  Private
 */
router.get('/:appointmentId/status', authMiddleware, videoCallController.getCallStatus);

module.exports = router;
