const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

// Public subscription plans list (Flutter compatibility)
router.get('/plans', adminController.getSubscriptionPlans);

module.exports = router;
