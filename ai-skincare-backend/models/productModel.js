const db = require('../config/db');
const { NotFoundError } = require('../middleware/error');

/**
 * Product Model
 */
const productModel = {
  /**
   * Find product by ID
   * 
   * @param {string} id - Product ID
   * @returns {Promise<Object>} - Product details
   */
  async findById(id) {
    const result = await db.query(
      `SELECT 
        p.id, 
        p.name,
        p.brand, 
        p.description,
        p.price,
        p.image_url,
        p.thumbnail_url,
        p.category,
        p.skin_type,
        p.ingredients,
        p.benefits,
        p.usage,
        p.created_at,
        p.updated_at
      FROM products p
      WHERE p.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      throw new NotFoundError('Product not found');
    }

    return result.rows[0];
  },

  /**
   * Find products with filtering and pagination
   * 
   * @param {Object} filters - Query filters
   * @param {number} page - Page number
   * @param {number} limit - Items per page
   * @returns {Promise<Object>} - Paginated products and metadata
   */
  async findAll(filters = {}, page = 1, limit = 10) {
    // Calculate offset
    const offset = (page - 1) * limit;
    
    // Build WHERE clause
    let whereClause = [];
    let params = [];
    let paramCount = 1;
    
    if (filters.category) {
      whereClause.push(`p.category = $${paramCount}`);
      params.push(filters.category);
      paramCount++;
    }
    
    if (filters.skinType) {
      whereClause.push(`p.skin_type LIKE $${paramCount}`);
      params.push(`%${filters.skinType}%`);
      paramCount++;
    }
    
    if (filters.minPrice) {
      whereClause.push(`p.price >= $${paramCount}`);
      params.push(filters.minPrice);
      paramCount++;
    }
    
    if (filters.maxPrice) {
      whereClause.push(`p.price <= $${paramCount}`);
      params.push(filters.maxPrice);
      paramCount++;
    }
    
    if (filters.brand) {
      whereClause.push(`p.brand = $${paramCount}`);
      params.push(filters.brand);
      paramCount++;
    }
    
    if (filters.search) {
      whereClause.push(`(
        p.name ILIKE $${paramCount} OR 
        p.description ILIKE $${paramCount} OR 
        p.brand ILIKE $${paramCount}
      )`);
      params.push(`%${filters.search}%`);
      paramCount++;
    }
    
    // Construct final WHERE clause
    const finalWhereClause = whereClause.length > 0 
      ? `WHERE ${whereClause.join(' AND ')}` 
      : '';
    
    // Add pagination params
    params.push(limit);
    params.push(offset);
    
    // Execute query
    const result = await db.query(
      `SELECT 
        p.id, 
        p.name,
        p.brand, 
        p.description,
        p.price,
        p.image_url,
        p.thumbnail_url,
        p.category,
        p.skin_type,
        p.created_at,
        p.updated_at
      FROM products p
      ${finalWhereClause}
      ORDER BY p.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      params
    );
    
    // Count total records
    const countResult = await db.query(
      `SELECT COUNT(*) FROM products p ${finalWhereClause}`,
      params.slice(0, params.length - 2) // Remove pagination params
    );
    
    const total = parseInt(countResult.rows[0].count);
    const totalPages = Math.ceil(total / limit);
    
    return {
      products: result.rows,
      pagination: {
        total,
        totalPages,
        currentPage: page,
        limit
      }
    };
  },
  
  /**
   * Get recommended products for skin analysis
   * 
   * @param {Object} skinAnalysis - Skin analysis results
   * @param {number} limit - Maximum number of products to recommend
   * @returns {Promise<Array>} - List of recommended products
   */
  async getRecommendedProducts(skinAnalysis, limit = 5) {
    const { hydration, oil, sensitivity } = skinAnalysis.results;
    
    // Determine skin type from analysis
    let skinType;
    if (hydration.value < 50) {
      skinType = 'dry';
    } else if (oil.value > 70) {
      skinType = 'oily';
    } else if (sensitivity.value > 3) {
      skinType = 'sensitive';
    } else {
      skinType = 'normal';
    }
    
    // Get products suited for the skin type
    const result = await db.query(
      `SELECT 
        p.id, 
        p.name,
        p.brand, 
        p.description,
        p.price,
        p.image_url,
        p.thumbnail_url,
        p.category,
        p.skin_type,
        p.created_at
      FROM products p
      WHERE p.skin_type LIKE $1
      ORDER BY p.created_at DESC
      LIMIT $2`,
      [`%${skinType}%`, limit]
    );
    
    return result.rows;
  }
};

module.exports = productModel; 