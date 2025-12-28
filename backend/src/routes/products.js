const express = require('express');
const router = express.Router();
const { authMiddleware, roleCheck } = require('../middleware/auth');
const productController = require('../controllers/productController');

/**
 * @route   GET /api/v2/products
 * @desc    Get all products (with search and filters)
 * @access  Public
 */
router.get('/', productController.getAllProducts);

/**
 * @route   GET /api/v2/products/categories
 * @desc    Get product categories
 * @access  Public
 */
router.get('/categories', productController.getCategories);

/**
 * @route   GET /api/v2/products/featured
 * @desc    Get featured products
 * @access  Public
 */
router.get('/featured', productController.getFeaturedProducts);

/**
 * @route   GET /api/v2/products/:id
 * @desc    Get product by ID
 * @access  Public
 */
router.get('/:id', productController.getProductById);

/**
 * @route   POST /api/v2/products
 * @desc    Create new product
 * @access  Private (Admin only)
 */
router.post('/', authMiddleware, roleCheck('admin'), productController.createProduct);

/**
 * @route   PUT /api/v2/products/:id
 * @desc    Update product
 * @access  Private (Admin only)
 */
router.put('/:id', authMiddleware, roleCheck('admin'), productController.updateProduct);

/**
 * @route   DELETE /api/v2/products/:id
 * @desc    Delete product (soft delete)
 * @access  Private (Admin only)
 */
router.delete('/:id', authMiddleware, roleCheck('admin'), productController.deleteProduct);

/**
 * @route   POST /api/v2/products/:id/reviews
 * @desc    Add product review
 * @access  Private
 */
router.post('/:id/reviews', authMiddleware, productController.addReview);

/**
 * @route   PUT /api/v2/products/:id/stock
 * @desc    Update product stock
 * @access  Private (Admin only)
 */
router.put('/:id/stock', authMiddleware, roleCheck('admin'), productController.updateStock);

module.exports = router;
