const express = require('express');
const router = express.Router();
const { authMiddleware, checkCallQuota } = require('../middleware/auth');
const bookingController = require('../controllers/bookingController');

router.get('/', authMiddleware, bookingController.getUserBookings);
router.get('/available-slots', authMiddleware, bookingController.getAvailableSlots);
router.post('/', authMiddleware, checkCallQuota, bookingController.createBooking);
router.put('/:id', authMiddleware, bookingController.updateBooking);
router.delete('/:id', authMiddleware, bookingController.cancelBooking);

module.exports = router;
