const db = require('../database');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

/**
 * Order Controller
 * Handles all order operations
 */

/**
 * Get user's orders
 */
exports.getUserOrders = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { status, limit = 50, offset = 0 } = req.query;

    let query = `
      SELECT 
        o.*,
        COUNT(oi.id) as item_count
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.user_id = $1
    `;

    const params = [userId];
    let paramCount = 2;

    if (status) {
      query += ` AND o.status = $${paramCount}`;
      params.push(status);
      paramCount++;
    }

    query += ` GROUP BY o.id ORDER BY o.created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    res.json({
      success: true,
      orders: result.rows
    });

  } catch (error) {
    logger.error('Get user orders error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get orders'
    });
  }
};

/**
 * Get order by ID
 */
exports.getOrderById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const userRole = req.user.role;

    // Get order
    let orderQuery = 'SELECT * FROM orders WHERE id = $1';
    const orderParams = [id];

    // Non-admin users can only see their own orders
    if (userRole !== 'admin') {
      orderQuery += ' AND user_id = $2';
      orderParams.push(userId);
    }

    const orderResult = await db.query(orderQuery, orderParams);

    if (orderResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    const order = orderResult.rows[0];

    // Get order items with product details
    const itemsResult = await db.query(
      `SELECT 
        oi.*,
        p.name,
        p.name_ar,
        p.images
       FROM order_items oi
       JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = $1`,
      [id]
    );

    res.json({
      success: true,
      order: {
        ...order,
        items: itemsResult.rows
      }
    });

  } catch (error) {
    logger.error('Get order by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get order'
    });
  }
};

/**
 * Create order
 */
exports.createOrder = async (req, res) => {
  const client = await db.getClient();

  try {
    const userId = req.user.userId;
    const {
      items, // [{ productId, quantity, price }]
      shippingAddress,
      paymentMethod = 'card',
      notes
    } = req.body;

    // Validation
    if (!items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Order must contain at least one item'
      });
    }

    if (!shippingAddress) {
      return res.status(400).json({
        success: false,
        message: 'Shipping address is required'
      });
    }

    await client.query('BEGIN');

    // Calculate totals and verify stock
    let subtotal = 0;
    const orderItems = [];

    for (const item of items) {
      // Get product and verify stock
      const productResult = await client.query(
        'SELECT id, name, price, stock_quantity FROM products WHERE id = $1 AND is_active = TRUE',
        [item.productId]
      );

      if (productResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(400).json({
          success: false,
          message: `Product ${item.productId} not found or inactive`
        });
      }

      const product = productResult.rows[0];

      // Check stock
      if (product.stock_quantity < item.quantity) {
        await client.query('ROLLBACK');
        return res.status(400).json({
          success: false,
          message: `Insufficient stock for ${product.name}. Available: ${product.stock_quantity}`
        });
      }

      const itemTotal = product.price * item.quantity;
      subtotal += itemTotal;

      orderItems.push({
        productId: product.id,
        quantity: item.quantity,
        priceAtTime: product.price,
        total: itemTotal
      });

      // Decrement stock
      await client.query(
        'UPDATE products SET stock_quantity = stock_quantity - $1 WHERE id = $2',
        [item.quantity, product.id]
      );
    }

    // Calculate shipping and tax (you can customize this)
    const shippingFee = subtotal > 200 ? 0 : 25; // Free shipping over 200 SAR
    const taxRate = 0.15; // 15% VAT
    const tax = subtotal * taxRate;
    const total = subtotal + shippingFee + tax;

    // Generate order number
    const orderNumber = `ORD-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;

    // Create order
    const orderResult = await client.query(
      `INSERT INTO orders (
        id, user_id, order_number, status, subtotal, tax, shipping_fee, 
        total, currency, shipping_address, payment_method, payment_status,
        notes, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, NOW(), NOW())
      RETURNING *`,
      [
        uuidv4(),
        userId,
        orderNumber,
        'pending',
        subtotal,
        tax,
        shippingFee,
        total,
        'SAR',
        JSON.stringify(shippingAddress),
        paymentMethod,
        'pending',
        notes || null
      ]
    );

    const order = orderResult.rows[0];

    // Create order items
    for (const item of orderItems) {
      await client.query(
        `INSERT INTO order_items (
          id, order_id, product_id, quantity, price_at_time, total,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())`,
        [
          uuidv4(),
          order.id,
          item.productId,
          item.quantity,
          item.priceAtTime,
          item.total
        ]
      );
    }

    await client.query('COMMIT');
    client.release();

    // Get complete order with items
    const completeOrder = await db.query(
      `SELECT 
        o.*,
        json_agg(
          json_build_object(
            'id', oi.id,
            'productId', oi.product_id,
            'productName', p.name,
            'productNameAr', p.name_ar,
            'quantity', oi.quantity,
            'price', oi.price_at_time,
            'total', oi.total
          )
        ) as items
       FROM orders o
       JOIN order_items oi ON o.id = oi.order_id
       JOIN products p ON oi.product_id = p.id
       WHERE o.id = $1
       GROUP BY o.id`,
      [order.id]
    );

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      order: completeOrder.rows[0],
      orderNumber: orderNumber
    });

    logger.info(`Order created: ${orderNumber} by user ${userId}`);

  } catch (error) {
    await client.query('ROLLBACK');
    client.release();
    logger.error('Create order error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create order'
    });
  }
};

/**
 * Update order status (Admin only)
 */
exports.updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, trackingNumber } = req.body;

    const validStatuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
    
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }

    const result = await db.query(
      `UPDATE orders
       SET status = $1,
           tracking_number = COALESCE($2, tracking_number),
           updated_at = NOW(),
           shipped_at = CASE WHEN $1 = 'shipped' THEN NOW() ELSE shipped_at END,
           delivered_at = CASE WHEN $1 = 'delivered' THEN NOW() ELSE delivered_at END
       WHERE id = $3
       RETURNING *`,
      [status, trackingNumber, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    res.json({
      success: true,
      message: 'Order status updated successfully',
      order: result.rows[0]
    });

    logger.info(`Order ${id} status updated to ${status}`);

  } catch (error) {
    logger.error('Update order status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update order status'
    });
  }
};

/**
 * Get all orders (Admin only)
 */
exports.getAllOrders = async (req, res) => {
  try {
    const { status, startDate, endDate, limit = 50, offset = 0 } = req.query;

    let query = `
      SELECT 
        o.*,
        u.full_name as user_name,
        u.email as user_email,
        COUNT(oi.id) as item_count
      FROM orders o
      JOIN users u ON o.user_id = u.id
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE 1=1
    `;

    const params = [];
    let paramCount = 1;

    if (status) {
      query += ` AND o.status = $${paramCount}`;
      params.push(status);
      paramCount++;
    }

    if (startDate) {
      query += ` AND o.created_at >= $${paramCount}`;
      params.push(startDate);
      paramCount++;
    }

    if (endDate) {
      query += ` AND o.created_at <= $${paramCount}`;
      params.push(endDate);
      paramCount++;
    }

    query += ` GROUP BY o.id, u.id ORDER BY o.created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    // Get total count
    const countResult = await db.query('SELECT COUNT(*) FROM orders');
    const total = parseInt(countResult.rows[0].count);

    res.json({
      success: true,
      orders: result.rows,
      pagination: {
        total,
        limit: parseInt(limit),
        offset: parseInt(offset)
      }
    });

  } catch (error) {
    logger.error('Get all orders error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get orders'
    });
  }
};

/**
 * Cancel order
 */
exports.cancelOrder = async (req, res) => {
  const client = await db.getClient();

  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const userRole = req.user.role;
    const { reason } = req.body;

    await client.query('BEGIN');

    // Get order
    let orderQuery = 'SELECT * FROM orders WHERE id = $1';
    const orderParams = [id];

    // Non-admin users can only cancel their own orders
    if (userRole !== 'admin') {
      orderQuery += ' AND user_id = $2';
      orderParams.push(userId);
    }

    const orderResult = await client.query(orderQuery, orderParams);

    if (orderResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    const order = orderResult.rows[0];

    // Check if order can be cancelled
    if (['shipped', 'delivered', 'cancelled'].includes(order.status)) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: 'Order cannot be cancelled in current status'
      });
    }

    // Restore stock
    const itemsResult = await client.query(
      'SELECT product_id, quantity FROM order_items WHERE order_id = $1',
      [id]
    );

    for (const item of itemsResult.rows) {
      await client.query(
        'UPDATE products SET stock_quantity = stock_quantity + $1 WHERE id = $2',
        [item.quantity, item.product_id]
      );
    }

    // Update order status
    await client.query(
      `UPDATE orders
       SET status = 'cancelled',
           cancellation_reason = $1,
           cancelled_at = NOW(),
           updated_at = NOW()
       WHERE id = $2`,
      [reason || 'Cancelled by user', id]
    );

    await client.query('COMMIT');
    client.release();

    res.json({
      success: true,
      message: 'Order cancelled successfully'
    });

    logger.info(`Order ${id} cancelled by user ${userId}`);

  } catch (error) {
    await client.query('ROLLBACK');
    client.release();
    logger.error('Cancel order error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel order'
    });
  }
};

/**
 * Track order status
 */
exports.trackOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const userRole = req.user.role;

    let query = 'SELECT id, order_number, status, placed_at, updated_at FROM orders WHERE id = $1';
    const params = [id];

    if (userRole !== 'admin') {
      query += ' AND user_id = $2';
      params.push(userId);
    }

    const result = await db.query(query, params);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    const order = result.rows[0];

    res.json({
      success: true,
      tracking: {
        orderId: order.id,
        orderNumber: order.order_number,
        status: order.status,
        placedAt: order.placed_at,
        updatedAt: order.updated_at
      }
    });
  } catch (error) {
    logger.error('Track order error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to track order'
    });
  }
};

/**
 * Get order statistics (Admin only)
 */
exports.getOrderStats = async (req, res) => {
  try {
    // Total orders
    const totalResult = await db.query('SELECT COUNT(*) as total FROM orders');

    // Orders by status
    const statusResult = await db.query(
      `SELECT status, COUNT(*) as count
       FROM orders
       GROUP BY status`
    );

    // Revenue
    const revenueResult = await db.query(
      `SELECT 
        COALESCE(SUM(total), 0) as total_revenue,
        COALESCE(SUM(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN total ELSE 0 END), 0) as revenue_last_30_days,
        COALESCE(SUM(CASE WHEN created_at >= NOW() - INTERVAL '7 days' THEN total ELSE 0 END), 0) as revenue_last_7_days
       FROM orders
       WHERE status != 'cancelled'`
    );

    // Top products
    const topProductsResult = await db.query(
      `SELECT 
        p.id,
        p.name,
        p.name_ar,
        SUM(oi.quantity) as total_sold,
        SUM(oi.total) as total_revenue
       FROM order_items oi
       JOIN products p ON oi.product_id = p.id
       JOIN orders o ON oi.order_id = o.id
       WHERE o.status != 'cancelled'
       GROUP BY p.id, p.name, p.name_ar
       ORDER BY total_sold DESC
       LIMIT 10`
    );

    res.json({
      success: true,
      stats: {
        totalOrders: parseInt(totalResult.rows[0].total),
        ordersByStatus: statusResult.rows,
        revenue: revenueResult.rows[0],
        topProducts: topProductsResult.rows
      }
    });

  } catch (error) {
    logger.error('Get order stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get order statistics'
    });
  }
};

module.exports = exports;
