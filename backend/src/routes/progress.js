const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const progressController = require('../controllers/progressController');

router.get('/', authMiddleware, progressController.getUserProgress);
router.post('/', authMiddleware, progressController.createEntry);
router.put('/:id', authMiddleware, progressController.updateEntry);
router.delete('/:id', authMiddleware, progressController.deleteEntry);

module.exports = router;
