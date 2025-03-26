const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const userModel = require('../models/userModel');
const { ValidationError, UnauthorizedError } = require('../middleware/error');

/**
 * Generate a JWT token for a user
 * 
 * @param {Object} user - User data
 * @returns {string} - JWT token
 */
const generateToken = (user) => {
  return jwt.sign(
    { 
      id: user.id,
      email: user.email,
      username: user.username
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRATION || '24h'
    }
  );
};

/**
 * User registration controller
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const register = async (req, res, next) => {
  try {
    const { username, email, password, phoneNumber } = req.body;
    
    // Validate required fields
    if (!username || !email || !password) {
      throw new ValidationError('Username, email and password are required');
    }
    
    // Check if email already exists
    const existingUser = await userModel.findByEmail(email);
    if (existingUser) {
      throw new ValidationError('Email already in use');
    }
    
    // Create the user
    const user = await userModel.create({
      username,
      email,
      password,
      phoneNumber
    });
    
    // Generate token
    const token = generateToken(user);
    
    // Return user data and token
    res.status(201).json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          avatarUrl: user.avatar_url,
          createdAt: user.created_at
        },
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * User login controller
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    // Validate required fields
    if (!email || !password) {
      throw new ValidationError('Email and password are required');
    }
    
    // Find user by email
    const user = await userModel.findByEmail(email);
    if (!user) {
      throw new UnauthorizedError('Invalid email or password');
    }
    
    // Verify password
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      throw new UnauthorizedError('Invalid email or password');
    }
    
    // Update last login time
    await userModel.updateLastLogin(user.id);
    
    // Generate token
    const token = generateToken(user);
    
    // Return user data and token
    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          avatarUrl: user.avatar_url,
          lastLoginAt: new Date()
        },
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login
}; 