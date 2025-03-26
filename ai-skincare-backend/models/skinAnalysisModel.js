const db = require('../config/db');
const { NotFoundError } = require('../middleware/error');

/**
 * SkinAnalysis model to handle database operations related to skin analysis
 */
const skinAnalysisModel = {
  /**
   * Create a new skin analysis record
   * 
   * @param {Object} analysisData - Analysis data
   * @returns {Promise<Object>} - Created analysis object
   */
  async create(analysisData) {
    const query = `
      INSERT INTO skin_analysis 
      (user_id, image_url, thumbnail_url, quiz_data, results, recommendations)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, user_id, image_url, thumbnail_url, quiz_data, results, recommendations, created_at
    `;
    
    const values = [
      analysisData.userId,
      analysisData.imageUrl,
      analysisData.thumbnailUrl,
      analysisData.quizData || {},
      analysisData.results || {},
      analysisData.recommendations || []
    ];
    
    const result = await db.query(query, values);
    return result.rows[0];
  },
  
  /**
   * Get skin analysis by ID
   * 
   * @param {string} id - Analysis ID
   * @returns {Promise<Object>} - Analysis object
   * @throws {NotFoundError} - If analysis not found
   */
  async findById(id) {
    const query = `
      SELECT id, user_id, image_url, thumbnail_url, quiz_data, results, recommendations, created_at
      FROM skin_analysis
      WHERE id = $1
    `;
    
    const result = await db.query(query, [id]);
    
    if (!result.rows[0]) {
      throw new NotFoundError('Skin analysis record not found');
    }
    
    return result.rows[0];
  },
  
  /**
   * Get user's skin analysis history with pagination
   * 
   * @param {string} userId - User ID
   * @param {number} page - Page number
   * @param {number} limit - Records per page
   * @returns {Promise<Object>} - Paginated analysis records
   */
  async findByUserId(userId, page = 1, limit = 10) {
    // Calculate offset
    const offset = (page - 1) * limit;
    
    // Get total count
    const countQuery = 'SELECT COUNT(*) FROM skin_analysis WHERE user_id = $1';
    const countResult = await db.query(countQuery, [userId]);
    const total = parseInt(countResult.rows[0].count);
    
    // Get paginated records
    const query = `
      SELECT 
        id, 
        thumbnail_url, 
        created_at,
        jsonb_build_object(
          'hydration', COALESCE(results->'hydration'->>'value', '0'),
          'oil', COALESCE(results->'oil'->>'value', '0'),
          'sensitivity', COALESCE(results->'sensitivity'->>'value', '0')
        ) as main_results
      FROM skin_analysis
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3
    `;
    
    const result = await db.query(query, [userId, limit, offset]);
    
    // Calculate pagination data
    const totalPages = Math.ceil(total / limit);
    
    return {
      total,
      pages: totalPages,
      current: page,
      records: result.rows
    };
  },
  
  /**
   * Get latest skin analysis for a user
   * 
   * @param {string} userId - User ID
   * @returns {Promise<Object|null>} - Latest analysis or null
   */
  async findLatestByUserId(userId) {
    const query = `
      SELECT id, user_id, image_url, thumbnail_url, quiz_data, results, recommendations, created_at
      FROM skin_analysis
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT 1
    `;
    
    const result = await db.query(query, [userId]);
    return result.rows[0] || null;
  },
  
  /**
   * Delete a skin analysis record
   * 
   * @param {string} id - Analysis ID
   * @param {string} userId - User ID (for authorization)
   * @returns {Promise<boolean>} - Success status
   */
  async delete(id, userId) {
    const query = 'DELETE FROM skin_analysis WHERE id = $1 AND user_id = $2 RETURNING id';
    const result = await db.query(query, [id, userId]);
    return result.rowCount > 0;
  }
};

module.exports = skinAnalysisModel; 