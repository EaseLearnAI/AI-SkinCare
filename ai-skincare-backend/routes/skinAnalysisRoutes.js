const express = require('express');
const router = express.Router();
const skinAnalysisController = require('../controllers/skinAnalysisController');
const { authenticateToken } = require('../middleware/auth');

// All skin analysis routes require authentication
router.use(authenticateToken);

// Skin analysis routes
router.post('/detect', skinAnalysisController.detectSkin);
router.get('/history', skinAnalysisController.getHistory);
router.get('/:analysisId', skinAnalysisController.getAnalysisById);

module.exports = router; 