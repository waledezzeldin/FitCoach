const express = require('express');
const router = express.Router();
const { authMiddleware, roleCheck } = require('../middleware/auth');
const orderController = require('../controllers/orderController');

/**
 * @route   GET /api/v2/orders
 * @desc    Get user's orders
 * @access  Private
 */
router.get('/', authMiddleware, orderController.getUserOrders);

/**
 * @route   GET /api/v2/orders/stats
 * @desc    Get order statistics
 * @access  Private (Admin only)
 */
router.get('/stats', authMiddleware, roleCheck('admin'), orderController.getOrderStats);

/**
 * @route   GET /api/v2/orders/all
 * @desc    Get all orders
 * @access  Private (Admin only)
 */
router.get('/all', authMiddleware, roleCheck('admin'), orderController.getAllOrders);

/**
 * @route   GET /api/v2/orders/:id
 * @desc    Get order by ID
 * @access  Private
 */
router.get('/:id', authMiddleware, orderController.getOrderById);

/**
 * @route   POST /api/v2/orders
 * @desc    Create new order
 * @access  Private
 */
router.post('/', authMiddleware, orderController.createOrder);

/**
 * @route   PUT /api/v2/orders/:id/status
 * @desc    Update order status
 * @access  Private (Admin only)
 */
router.put('/:id/status', authMiddleware, roleCheck('admin'), orderController.updateOrderStatus);

/**
 * @route   POST /api/v2/orders/:id/cancel
 * @desc    Cancel order
 * @access  Private
 */
router.post('/:id/cancel', authMiddleware, orderController.cancelOrder);

module.exports = router;
