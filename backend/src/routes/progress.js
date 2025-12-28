const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');

// Placeholder controller
const progressController = {
  getUserProgress: (req, res) => res.json({ success: true, entries: [] }),
  createEntry: (req, res) => res.json({ success: true, entry: {} }),
  updateEntry: (req, res) => res.json({ success: true }),
  deleteEntry: (req, res) => res.json({ success: true })
};

router.get('/', authMiddleware, progressController.getUserProgress);
router.post('/', authMiddleware, progressController.createEntry);
router.put('/:id', authMiddleware, progressController.updateEntry);
router.delete('/:id', authMiddleware, progressController.deleteEntry);

module.exports = router;
