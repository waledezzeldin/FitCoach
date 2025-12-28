const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const ratingController = require('../controllers/ratingController');

router.post('/', authMiddleware, ratingController.submitRating);
router.get('/coach/:id', ratingController.getCoachRatings); // Public
router.get('/user/:id', authMiddleware, ratingController.getUserRatings);

module.exports = router;