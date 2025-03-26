const db = require('../config/db');
const bcrypt = require('bcrypt');
const { NotFoundError } = require('../middleware/error');

/**
 * User model to handle database operations related to users
 */
const userModel = {
  /**
   * Create a new user
   * 
   * @param {Object} userData - User data
   * @returns {Promise<Object>} - Created user object
   */
  async create(userData) {
    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(userData.password, saltRounds);
    
    // Create the user
    const query = `
      INSERT INTO users 
      (username, email, password, phone_number, avatar_url, skin_type, concerns)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id, username, email, phone_number, avatar_url, skin_type, concerns, created_at
    `;
    
    const values = [
      userData.username,
      userData.email,
      hashedPassword,
      userData.phoneNumber || null,
      userData.avatarUrl || null,
      userData.skinType || null,
      userData.concerns || null
    ];
    
    const result = await db.query(query, values);
    return result.rows[0];
  },
  
  /**
   * Find a user by email
   * 
   * @param {string} email - User email
   * @returns {Promise<Object|null>} - Found user or null
   */
  async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await db.query(query, [email]);
    return result.rows[0] || null;
  },
  
  /**
   * Find a user by ID
   * 
   * @param {string} id - User ID
   * @returns {Promise<Object>} - Found user
   * @throws {NotFoundError} - If user not found
   */
  async findById(id) {
    const query = `
      SELECT 
        id, username, email, phone_number, avatar_url, 
        skin_type, concerns, favorites, created_at, last_login_at
      FROM users 
      WHERE id = $1
    `;
    
    const result = await db.query(query, [id]);
    
    if (!result.rows[0]) {
      throw new NotFoundError('User not found');
    }
    
    return result.rows[0];
  },
  
  /**
   * Update a user
   * 
   * @param {string} id - User ID
   * @param {Object} userData - Updated user data
   * @returns {Promise<Object>} - Updated user
   * @throws {NotFoundError} - If user not found
   */
  async update(id, userData) {
    // First check if user exists
    const user = await this.findById(id);
    
    // Prepare update fields
    const updateFields = [];
    const values = [];
    let valueCounter = 1;
    
    // Only update fields that are provided
    if (userData.username !== undefined) {
      updateFields.push(`username = $${valueCounter++}`);
      values.push(userData.username);
    }
    
    if (userData.avatarUrl !== undefined) {
      updateFields.push(`avatar_url = $${valueCounter++}`);
      values.push(userData.avatarUrl);
    }
    
    if (userData.skinType !== undefined) {
      updateFields.push(`skin_type = $${valueCounter++}`);
      values.push(userData.skinType);
    }
    
    if (userData.concerns !== undefined) {
      updateFields.push(`concerns = $${valueCounter++}`);
      values.push(userData.concerns);
    }
    
    if (userData.phoneNumber !== undefined) {
      updateFields.push(`phone_number = $${valueCounter++}`);
      values.push(userData.phoneNumber);
    }
    
    if (userData.password !== undefined) {
      const hashedPassword = await bcrypt.hash(userData.password, 10);
      updateFields.push(`password = $${valueCounter++}`);
      values.push(hashedPassword);
    }
    
    // Add updated_at field
    updateFields.push(`updated_at = now()`);
    
    // If no fields to update, return the current user
    if (updateFields.length === 1) {
      return user;
    }
    
    // Add user ID to values array
    values.push(id);
    
    // Build and execute the update query
    const query = `
      UPDATE users 
      SET ${updateFields.join(', ')} 
      WHERE id = $${valueCounter}
      RETURNING id, username, email, phone_number, avatar_url, skin_type, concerns, created_at, updated_at
    `;
    
    const result = await db.query(query, values);
    return result.rows[0];
  },
  
  /**
   * Update last login time
   * 
   * @param {string} id - User ID
   * @returns {Promise<void>}
   */
  async updateLastLogin(id) {
    const query = 'UPDATE users SET last_login_at = now() WHERE id = $1';
    await db.query(query, [id]);
  },
  
  /**
   * Add a product to user favorites
   * 
   * @param {string} userId - User ID
   * @param {string} productId - Product ID
   * @returns {Promise<Object>} - Updated favorites array
   */
  async addFavorite(userId, productId) {
    const query = `
      UPDATE users 
      SET favorites = array_append(COALESCE(favorites, ARRAY[]::uuid[]), $1::uuid) 
      WHERE id = $2 AND NOT ($1::uuid = ANY(COALESCE(favorites, ARRAY[]::uuid[])))
      RETURNING favorites
    `;
    
    const result = await db.query(query, [productId, userId]);
    return result.rows[0] || { favorites: [] };
  },
  
  /**
   * Remove a product from user favorites
   * 
   * @param {string} userId - User ID
   * @param {string} productId - Product ID
   * @returns {Promise<Object>} - Updated favorites array
   */
  async removeFavorite(userId, productId) {
    const query = `
      UPDATE users 
      SET favorites = array_remove(favorites, $1::uuid) 
      WHERE id = $2
      RETURNING favorites
    `;
    
    const result = await db.query(query, [productId, userId]);
    return result.rows[0] || { favorites: [] };
  }
};

module.exports = userModel; 