const express = require('express');
const router = express.Router();
const { authMiddleware, checkCallQuota } = require('../middleware/auth');

// Placeholder controller
const bookingController = {
  getUserBookings: (req, res) => res.json({ success: true, bookings: [] }),
  createBooking: (req, res) => res.json({ success: true, booking: {} }),
  updateBooking: (req, res) => res.json({ success: true }),
  cancelBooking: (req, res) => res.json({ success: true }),
  getAvailableSlots: (req, res) => res.json({ success: true, slots: [] })
};

router.get('/', authMiddleware, bookingController.getUserBookings);
router.get('/available-slots', authMiddleware, bookingController.getAvailableSlots);
router.post('/', authMiddleware, checkCallQuota, bookingController.createBooking);
router.put('/:id', authMiddleware, bookingController.updateBooking);
router.delete('/:id', authMiddleware, bookingController.cancelBooking);

module.exports = router;
