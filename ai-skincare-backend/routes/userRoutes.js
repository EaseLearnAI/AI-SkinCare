const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticateToken } = require('../middleware/auth');

// All user routes require authentication
router.use(authenticateToken);

// User profile routes
router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);

// Favorites routes
router.post('/favorites/:productId', userController.addFavorite);
router.delete('/favorites/:productId', userController.removeFavorite);

module.exports = router; 