const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const productController = require('../controllers/productController');
const storeController = require('../controllers/storeController');

// Product browsing
router.get('/products', productController.getAllProducts);
router.get('/products/:id', productController.getProductById);
router.get('/products/:id/reviews', productController.getReviews);
router.post('/products/:id/reviews', authMiddleware, productController.addReview);
router.post('/products/:id/check-availability', authMiddleware, storeController.checkAvailability);

// Categories
router.get('/categories', productController.getCategories);

// Promo codes
router.post('/promo-codes/apply', authMiddleware, storeController.applyPromoCode);

// Shipping calculation
router.post('/shipping/calculate', authMiddleware, storeController.calculateShipping);

module.exports = router;
