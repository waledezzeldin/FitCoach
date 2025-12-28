const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const { requirePremiumTier } = require('../middleware/premiumFeatureMiddleware');
const inbodyController = require('../controllers/inbodyController');
const upload = require('../middleware/upload');

// InBody scan management (all users)
router.post('/', authMiddleware, inbodyController.saveInBodyScan);
router.get('/', authMiddleware, inbodyController.getAllScans);
router.get('/latest', authMiddleware, inbodyController.getLatestScan);
router.get('/trends', authMiddleware, inbodyController.getTrends);
router.get('/progress', authMiddleware, inbodyController.getProgress);
router.get('/statistics', authMiddleware, inbodyController.getStatistics);
router.get('/:id', authMiddleware, inbodyController.getScanById);
router.put('/:id', authMiddleware, inbodyController.updateScan);
router.delete('/:id', authMiddleware, inbodyController.deleteScan);

// Body composition goals
router.post('/goals', authMiddleware, inbodyController.setGoals);
router.get('/goals/current', authMiddleware, inbodyController.getGoals);

// AI extraction (Premium feature ONLY)
router.post('/upload-image', authMiddleware, requirePremiumTier, upload.uploadImage.single('file'), inbodyController.uploadScanImage);

module.exports = router;
