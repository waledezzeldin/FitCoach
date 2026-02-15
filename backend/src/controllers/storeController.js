const db = require('../database');
const logger = require('../utils/logger');

/**
 * Store Controller
 * Handles store-specific compatibility endpoints
 */

exports.checkAvailability = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity = 1 } = req.body;

    const result = await db.query(
      'SELECT stock_quantity, is_active FROM products WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0 || !result.rows[0].is_active) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const stock = result.rows[0].stock_quantity || 0;
    const requested = parseInt(quantity, 10) || 0;

    res.json({
      success: true,
      available: stock >= requested,
      stock
    });
  } catch (error) {
    logger.error('Check availability error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check availability'
    });
  }
};

exports.applyPromoCode = async (req, res) => {
  try {
    const { code, subtotal } = req.body;
    const normalized = (code || '').trim().toUpperCase();
    const subtotalValue = parseFloat(subtotal) || 0;

    let discount = 0;

    if (normalized === 'FIT10') {
      discount = subtotalValue * 0.1;
    }

    res.json({
      success: true,
      code: normalized,
      discount,
      total: Math.max(0, subtotalValue - discount)
    });
  } catch (error) {
    logger.error('Apply promo code error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to apply promo code'
    });
  }
};

exports.calculateShipping = async (req, res) => {
  try {
    const { weight = 0 } = req.body;
    const base = 25;
    const weightSurcharge = Math.max(0, parseFloat(weight) - 1) * 2;
    const shippingCost = base + weightSurcharge;

    res.json({
      success: true,
      shippingCost
    });
  } catch (error) {
    logger.error('Calculate shipping error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate shipping'
    });
  }
};
