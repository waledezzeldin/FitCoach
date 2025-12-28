const express = require('express');
const router = express.Router();
const { authMiddleware, roleCheck } = require('../middleware/auth');
const workoutController = require('../controllers/workoutController');

// Template routes (public - can be viewed by authenticated users)
router.get('/templates', authMiddleware, workoutController.getTemplates);
router.get('/templates/:id', authMiddleware, workoutController.getTemplateById);
router.post('/generate-from-template', authMiddleware, workoutController.generateFromTemplate);
router.get('/recommend-template/:userId?', authMiddleware, workoutController.getRecommendedTemplate);

// User routes
router.get('/', authMiddleware, workoutController.getUserWorkouts);
router.get('/:id', authMiddleware, workoutController.getWorkoutById);
router.post('/:id/exercises/:exerciseId/complete', authMiddleware, workoutController.completeExercise);
router.get('/:id/progress', authMiddleware, workoutController.getProgress);
router.post('/:id/substitute-exercise', authMiddleware, workoutController.substituteExercise);

// Coach routes
router.post('/', authMiddleware, roleCheck('coach', 'admin'), workoutController.createWorkoutPlan);
router.put('/:id', authMiddleware, roleCheck('coach', 'admin'), workoutController.updateWorkoutPlan);
router.delete('/:id', authMiddleware, roleCheck('coach', 'admin'), workoutController.deleteWorkoutPlan);
router.post('/:id/clone', authMiddleware, roleCheck('coach', 'admin'), workoutController.cloneWorkoutPlan);
router.put('/:id/exercises/:exerciseId', authMiddleware, roleCheck('coach', 'admin'), workoutController.updateExerciseForUser);
router.post('/:id/days/:dayId/note', authMiddleware, roleCheck('coach', 'admin'), workoutController.addCustomNoteToDay);
router.get('/customization-history/:userId', authMiddleware, roleCheck('coach', 'admin'), workoutController.getCustomizationHistory);

module.exports = router;