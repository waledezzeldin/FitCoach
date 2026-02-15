const express = require('express');
const router = express.Router();
const { authMiddleware, roleCheck } = require('../middleware/auth');
const coachController = require('../controllers/coachController');
const coachPlanController = require('../controllers/coachPlanController');

/**
 * @route   GET /api/v2/coaches/:id/profile
 * @desc    Get comprehensive coach profile (public)
 * @access  Public
 */
router.get('/:id/profile', coachController.getCoachProfile);

/**
 * @route   GET /api/v2/coaches
 * @desc    Get all coaches
 * @access  Public
 */
router.get('/', coachController.getAllCoaches);

/**
 * @route   GET /api/v2/coaches/:id
 * @desc    Get coach by ID
 * @access  Public
 */
router.get('/:id', coachController.getCoachById);

/**
 * @route   GET /api/v2/coaches/:id/clients
 * @desc    Get coach's clients
 * @access  Private (Coach/Admin)
 */
router.get('/:id/clients', authMiddleware, roleCheck('coach', 'admin'), coachController.getCoachClients);

/**
 * @route   GET /api/v2/coaches/:id/appointments
 * @desc    Get coach's appointments
 * @access  Private (Coach/Admin)
 */
router.get('/:id/appointments', authMiddleware, roleCheck('coach', 'admin'), coachController.getCoachAppointments);

/**
 * @route   GET /api/v2/coaches/:id/appointments/ics
 * @desc    Export coach appointments as ICS
 * @access  Private (Coach/Admin)
 */
router.get('/:id/appointments/ics', authMiddleware, roleCheck('coach', 'admin'), coachController.exportCoachAppointmentsIcs);

/**
 * @route   POST /api/v2/coaches/:id/appointments
 * @desc    Create appointment
 * @access  Private (Coach/Admin)
 */
router.post('/:id/appointments', authMiddleware, roleCheck('coach', 'admin'), coachController.createAppointment);

/**
 * @route   PUT /api/v2/coaches/:id/appointments/:appointmentId
 * @desc    Update appointment
 * @access  Private (Coach/Admin)
 */
router.put('/:id/appointments/:appointmentId', authMiddleware, roleCheck('coach', 'admin'), coachController.updateAppointment);

/**
 * @route   GET /api/v2/coaches/:id/earnings
 * @desc    Get coach earnings
 * @access  Private (Coach/Admin)
 */
router.get('/:id/earnings', authMiddleware, roleCheck('coach', 'admin'), coachController.getCoachEarnings);

/**
 * @route   PUT /api/v2/coaches/:id/clients/:clientId/fitness-score
 * @desc    Assign fitness score to client
 * @access  Private (Coach)
 */
router.put('/:id/clients/:clientId/fitness-score', authMiddleware, roleCheck('coach'), coachController.assignFitnessScore);

/**
 * @route   GET /api/v2/coaches/:id/analytics
 * @desc    Get coach analytics
 * @access  Private (Coach/Admin)
 */
router.get('/:id/analytics', authMiddleware, roleCheck('coach', 'admin'), coachController.getCoachAnalytics);

/**
 * @route   GET /api/v2/coaches/:id/clients/:clientId/report
 * @desc    Generate client report
 * @access  Private (Coach/Admin)
 */
router.get('/:id/clients/:clientId/report', authMiddleware, roleCheck('coach', 'admin'), coachController.generateClientReport);

/**
 * @route   GET /api/v2/coaches/:id/clients/:clientId/workout-plan
 * @desc    Get client's workout plan
 * @access  Private (Coach/Admin)
 */
router.get('/:id/clients/:clientId/workout-plan', authMiddleware, roleCheck('coach', 'admin'), coachPlanController.getClientWorkoutPlan);

/**
 * @route   PUT /api/v2/coaches/:id/clients/:clientId/workout-plan
 * @desc    Update client's workout plan
 * @access  Private (Coach)
 */
router.put('/:id/clients/:clientId/workout-plan', authMiddleware, roleCheck('coach', 'admin'), coachPlanController.updateClientWorkoutPlan);

/**
 * @route   GET /api/v2/coaches/:id/clients/:clientId/nutrition-plan
 * @desc    Get client's nutrition plan
 * @access  Private (Coach/Admin)
 */
router.get('/:id/clients/:clientId/nutrition-plan', authMiddleware, roleCheck('coach', 'admin'), coachPlanController.getClientNutritionPlan);

/**
 * @route   PUT /api/v2/coaches/:id/clients/:clientId/nutrition-plan
 * @desc    Update client's nutrition plan
 * @access  Private (Coach)
 */
router.put('/:id/clients/:clientId/nutrition-plan', authMiddleware, roleCheck('coach', 'admin'), coachPlanController.updateClientNutritionPlan);

module.exports = router;
