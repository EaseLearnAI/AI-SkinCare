const userModel = require('../models/userModel');
const { NotFoundError, ForbiddenError } = require('../middleware/error');

/**
 * Get current user's profile
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const getProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    // Get user data
    const user = await userModel.findById(userId);
    
    // Transform data for response
    const response = {
      id: user.id,
      username: user.username,
      email: user.email,
      phoneNumber: user.phone_number,
      avatarUrl: user.avatar_url,
      skinType: user.skin_type,
      concerns: user.concerns,
      favorites: user.favorites,
      createdAt: user.created_at,
      lastLoginAt: user.last_login_at
    };
    
    res.json({
      success: true,
      data: response
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update user profile
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const updateProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { username, avatarUrl, skinType, concerns, phoneNumber } = req.body;
    
    // Update user data
    const updatedUser = await userModel.update(userId, {
      username,
      avatarUrl,
      skinType,
      concerns,
      phoneNumber
    });
    
    // Transform data for response
    const response = {
      id: updatedUser.id,
      username: updatedUser.username,
      email: updatedUser.email,
      avatarUrl: updatedUser.avatar_url,
      skinType: updatedUser.skin_type,
      concerns: updatedUser.concerns,
      updatedAt: updatedUser.updated_at
    };
    
    res.json({
      success: true,
      data: response
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Add product to favorites
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const addFavorite = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { productId } = req.body;
    
    if (!productId) {
      throw new Error('Product ID is required');
    }
    
    const result = await userModel.addFavorite(userId, productId);
    
    res.json({
      success: true,
      data: {
        favorites: result.favorites
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Remove product from favorites
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const removeFavorite = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { productId } = req.params;
    
    if (!productId) {
      throw new Error('Product ID is required');
    }
    
    const result = await userModel.removeFavorite(userId, productId);
    
    res.json({
      success: true,
      data: {
        favorites: result.favorites
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProfile,
  updateProfile,
  addFavorite,
  removeFavorite
}; 