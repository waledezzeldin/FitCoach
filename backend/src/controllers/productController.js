const db = require('../database');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

/**
 * Product Controller
 * Handles all product/store operations
 */

/**
 * Get all products (with search and filters)
 */
exports.getAllProducts = async (req, res) => {
  try {
    const {
      search,
      category,
      minPrice,
      maxPrice,
      featured,
      inStock,
      sortBy = 'created_at',
      sortOrder = 'DESC',
      limit = 20,
      offset = 0
    } = req.query;

    let query = `
      SELECT 
        p.*,
        COALESCE(AVG(pr.rating), 0) as average_rating,
        COUNT(pr.id) as review_count
      FROM products p
      LEFT JOIN product_reviews pr ON p.id = pr.product_id
      WHERE p.is_active = TRUE
    `;

    const params = [];
    let paramCount = 1;

    // Search by name or description
    if (search) {
      query += ` AND (
        p.name ILIKE $${paramCount} OR 
        p.name_ar ILIKE $${paramCount} OR
        p.description ILIKE $${paramCount} OR
        p.description_ar ILIKE $${paramCount}
      )`;
      params.push(`%${search}%`);
      paramCount++;
    }

    // Filter by category
    if (category) {
      query += ` AND p.category = $${paramCount}`;
      params.push(category);
      paramCount++;
    }

    // Filter by price range
    if (minPrice) {
      query += ` AND p.price >= $${paramCount}`;
      params.push(parseFloat(minPrice));
      paramCount++;
    }

    if (maxPrice) {
      query += ` AND p.price <= $${paramCount}`;
      params.push(parseFloat(maxPrice));
      paramCount++;
    }

    // Filter featured products
    if (featured !== undefined) {
      query += ` AND p.is_featured = $${paramCount}`;
      params.push(featured === 'true');
      paramCount++;
    }

    // Filter in-stock products
    if (inStock === 'true') {
      query += ` AND p.stock_quantity > 0`;
    }

    query += ` GROUP BY p.id`;

    // Sorting
    const validSortFields = ['name', 'price', 'created_at', 'stock_quantity'];
    const sortField = validSortFields.includes(sortBy) ? sortBy : 'created_at';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    
    query += ` ORDER BY p.${sortField} ${order}`;

    // Pagination
    query += ` LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM products WHERE is_active = TRUE';
    const countParams = [];
    let countParamIndex = 1;

    if (search) {
      countQuery += ` AND (name ILIKE $${countParamIndex} OR name_ar ILIKE $${countParamIndex} OR description ILIKE $${countParamIndex})`;
      countParams.push(`%${search}%`);
      countParamIndex++;
    }

    if (category) {
      countQuery += ` AND category = $${countParamIndex}`;
      countParams.push(category);
      countParamIndex++;
    }

    const countResult = await db.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      success: true,
      products: result.rows,
      pagination: {
        total,
        limit: parseInt(limit),
        offset: parseInt(offset),
        hasMore: (parseInt(offset) + result.rows.length) < total
      }
    });

  } catch (error) {
    logger.error('Get products error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get products'
    });
  }
};

/**
 * Get product by ID
 */
exports.getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT 
        p.*,
        COALESCE(AVG(pr.rating), 0) as average_rating,
        COUNT(pr.id) as review_count
       FROM products p
       LEFT JOIN product_reviews pr ON p.id = pr.product_id
       WHERE p.id = $1 AND p.is_active = TRUE
       GROUP BY p.id`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Get reviews
    const reviewsResult = await db.query(
      `SELECT 
        pr.*,
        u.full_name,
        u.profile_photo_url
       FROM product_reviews pr
       JOIN users u ON pr.user_id = u.id
       WHERE pr.product_id = $1
       ORDER BY pr.created_at DESC
       LIMIT 10`,
      [id]
    );

    res.json({
      success: true,
      product: {
        ...result.rows[0],
        reviews: reviewsResult.rows
      }
    });

  } catch (error) {
    logger.error('Get product by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get product'
    });
  }
};

/**
 * Get product categories
 */
exports.getCategories = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT 
        category,
        COUNT(*) as product_count
       FROM products
       WHERE is_active = TRUE
       GROUP BY category
       ORDER BY category`
    );

    res.json({
      success: true,
      categories: result.rows
    });

  } catch (error) {
    logger.error('Get categories error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get categories'
    });
  }
};

/**
 * Get featured products
 */
exports.getFeaturedProducts = async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    const result = await db.query(
      `SELECT 
        p.*,
        COALESCE(AVG(pr.rating), 0) as average_rating,
        COUNT(pr.id) as review_count
       FROM products p
       LEFT JOIN product_reviews pr ON p.id = pr.product_id
       WHERE p.is_active = TRUE AND p.is_featured = TRUE
       GROUP BY p.id
       ORDER BY p.created_at DESC
       LIMIT $1`,
      [parseInt(limit)]
    );

    res.json({
      success: true,
      products: result.rows
    });

  } catch (error) {
    logger.error('Get featured products error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get featured products'
    });
  }
};

/**
 * Get product reviews (paginated)
 */
exports.getReviews = async (req, res) => {
  try {
    const { id } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT 
        pr.*,
        u.full_name,
        u.profile_photo_url
       FROM product_reviews pr
       JOIN users u ON pr.user_id = u.id
       WHERE pr.product_id = $1
       ORDER BY pr.created_at DESC
       LIMIT $2 OFFSET $3`,
      [id, parseInt(limit), parseInt(offset)]
    );

    res.json({
      success: true,
      reviews: result.rows
    });
  } catch (error) {
    logger.error('Get product reviews error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get reviews'
    });
  }
};

/**
 * Create product (Admin only)
 */
exports.createProduct = async (req, res) => {
  try {
    const {
      name,
      nameAr,
      description,
      descriptionAr,
      category,
      price,
      currency = 'SAR',
      stockQuantity,
      images,
      isFeatured = false,
      specifications
    } = req.body;

    // Validation
    if (!name || !price || !category) {
      return res.status(400).json({
        success: false,
        message: 'Name, price, and category are required'
      });
    }

    const result = await db.query(
      `INSERT INTO products (
        id, name, name_ar, name_en, description, description_ar, description_en,
        category, price, currency, stock_quantity, images, is_featured, 
        specifications, is_active, created_at, updated_at
      ) VALUES ($1, $2, $3, $2, $4, $5, $4, $6, $7, $8, $9, $10, $11, $12, TRUE, NOW(), NOW())
      RETURNING *`,
      [
        uuidv4(),
        name,
        nameAr || name,
        description || '',
        descriptionAr || description || '',
        category,
        parseFloat(price),
        currency,
        parseInt(stockQuantity) || 0,
        JSON.stringify(images || []),
        isFeatured,
        JSON.stringify(specifications || {})
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Product created successfully',
      product: result.rows[0]
    });

    logger.info(`Product created: ${result.rows[0].id}`);

  } catch (error) {
    logger.error('Create product error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create product'
    });
  }
};

/**
 * Update product (Admin only)
 */
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      nameAr,
      description,
      descriptionAr,
      category,
      price,
      stockQuantity,
      images,
      isFeatured,
      specifications,
      isActive
    } = req.body;

    const result = await db.query(
      `UPDATE products
       SET name = COALESCE($1, name),
           name_ar = COALESCE($2, name_ar),
           name_en = COALESCE($1, name_en),
           description = COALESCE($3, description),
           description_ar = COALESCE($4, description_ar),
           description_en = COALESCE($3, description_en),
           category = COALESCE($5, category),
           price = COALESCE($6, price),
           stock_quantity = COALESCE($7, stock_quantity),
           images = COALESCE($8, images),
           is_featured = COALESCE($9, is_featured),
           specifications = COALESCE($10, specifications),
           is_active = COALESCE($11, is_active),
           updated_at = NOW()
       WHERE id = $12
       RETURNING *`,
      [
        name,
        nameAr,
        description,
        descriptionAr,
        category,
        price ? parseFloat(price) : null,
        stockQuantity ? parseInt(stockQuantity) : null,
        images ? JSON.stringify(images) : null,
        isFeatured,
        specifications ? JSON.stringify(specifications) : null,
        isActive,
        id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    res.json({
      success: true,
      message: 'Product updated successfully',
      product: result.rows[0]
    });

    logger.info(`Product updated: ${id}`);

  } catch (error) {
    logger.error('Update product error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update product'
    });
  }
};

/**
 * Delete product (Admin only)
 */
exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    // Soft delete (set is_active to false)
    const result = await db.query(
      'UPDATE products SET is_active = FALSE, updated_at = NOW() WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    res.json({
      success: true,
      message: 'Product deleted successfully'
    });

    logger.info(`Product deleted: ${id}`);

  } catch (error) {
    logger.error('Delete product error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete product'
    });
  }
};

/**
 * Add product review
 */
exports.addReview = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const { rating, comment } = req.body;

    // Validation
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }

    // Check if product exists
    const productCheck = await db.query(
      'SELECT id FROM products WHERE id = $1 AND is_active = TRUE',
      [id]
    );

    if (productCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Check if user already reviewed
    const existingReview = await db.query(
      'SELECT id FROM product_reviews WHERE product_id = $1 AND user_id = $2',
      [id, userId]
    );

    if (existingReview.rows.length > 0) {
      // Update existing review
      const result = await db.query(
        `UPDATE product_reviews
         SET rating = $1, comment = $2, updated_at = NOW()
         WHERE product_id = $3 AND user_id = $4
         RETURNING *`,
        [rating, comment, id, userId]
      );

      return res.json({
        success: true,
        message: 'Review updated successfully',
        review: result.rows[0]
      });
    }

    // Create new review
    const result = await db.query(
      `INSERT INTO product_reviews (
        id, product_id, user_id, rating, comment, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
      RETURNING *`,
      [uuidv4(), id, userId, rating, comment]
    );

    res.status(201).json({
      success: true,
      message: 'Review added successfully',
      review: result.rows[0]
    });

    logger.info(`Review added for product ${id} by user ${userId}`);

  } catch (error) {
    logger.error('Add review error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add review'
    });
  }
};

/**
 * Update stock quantity (Admin only)
 */
exports.updateStock = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity, operation = 'set' } = req.body;

    if (quantity === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Quantity is required'
      });
    }

    let query;
    if (operation === 'increment') {
      query = 'UPDATE products SET stock_quantity = stock_quantity + $1, updated_at = NOW() WHERE id = $2 RETURNING *';
    } else if (operation === 'decrement') {
      query = 'UPDATE products SET stock_quantity = GREATEST(stock_quantity - $1, 0), updated_at = NOW() WHERE id = $2 RETURNING *';
    } else {
      query = 'UPDATE products SET stock_quantity = $1, updated_at = NOW() WHERE id = $2 RETURNING *';
    }

    const result = await db.query(query, [parseInt(quantity), id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    res.json({
      success: true,
      message: 'Stock updated successfully',
      product: result.rows[0]
    });

    logger.info(`Stock updated for product ${id}: ${operation} ${quantity}`);

  } catch (error) {
    logger.error('Update stock error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update stock'
    });
  }
};

module.exports = exports;
