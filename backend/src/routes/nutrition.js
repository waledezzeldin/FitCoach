const express = require('express');
const router = express.Router();
const { authMiddleware, roleCheck } = require('../middleware/auth');
const { checkNutritionAccess, addNutritionAccessInfo } = require('../middleware/nutritionAccessControl');
const nutritionController = require('../controllers/nutritionController');

// Access status routes (no access check needed)
router.get('/access-status', authMiddleware, nutritionController.getAccessStatus);
router.get('/trial-status', authMiddleware, nutritionController.getTrialStatusCompat);
router.post('/unlock-trial', authMiddleware, nutritionController.unlockTrial);

// Generate nutrition plan (requires access)
router.post('/generate', authMiddleware, checkNutritionAccess, nutritionController.generatePlan);

// Flutter-compatible routes
router.get('/plan', authMiddleware, checkNutritionAccess, nutritionController.getActivePlanCompat);
router.post('/meals/:mealId/log', authMiddleware, checkNutritionAccess, nutritionController.logMealCompat);
router.get('/history', authMiddleware, checkNutritionAccess, nutritionController.getNutritionHistoryCompat);

// Protected nutrition routes (require access)
router.get('/', authMiddleware, checkNutritionAccess, nutritionController.getUserPlans);
router.get('/:id', authMiddleware, checkNutritionAccess, nutritionController.getPlanById);
router.post('/:id/meals/:mealId/complete', authMiddleware, checkNutritionAccess, nutritionController.completeMeal);

// Coach/Admin routes (bypass access check)
router.post('/', authMiddleware, roleCheck('coach', 'admin'), nutritionController.createPlan);
router.put('/:id', authMiddleware, roleCheck('coach', 'admin'), nutritionController.updatePlan);
router.delete('/:id', authMiddleware, roleCheck('coach', 'admin'), nutritionController.deletePlan);

module.exports = router;