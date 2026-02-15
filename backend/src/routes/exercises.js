const express = require('express');
const router = express.Router();
const { authMiddleware, roleCheck } = require('../middleware/auth');
const exerciseController = require('../controllers/exerciseController');

// Public routes (require auth)
router.get('/', authMiddleware, exerciseController.getAllExercises);
router.get('/muscle-group/:muscleGroup', authMiddleware, exerciseController.getExercisesByMuscleGroup);
router.get('/stats', authMiddleware, roleCheck('admin'), exerciseController.getExerciseStats);
router.post('/:id/alternatives', authMiddleware, exerciseController.getExerciseAlternatives);
router.get('/:id', authMiddleware, exerciseController.getExerciseById);

// User favorites
router.get('/favorites/list', authMiddleware, exerciseController.getUserFavorites);
router.post('/favorites', authMiddleware, exerciseController.addToFavorites);
router.delete('/favorites/:exerciseId', authMiddleware, exerciseController.removeFromFavorites);

module.exports = router;