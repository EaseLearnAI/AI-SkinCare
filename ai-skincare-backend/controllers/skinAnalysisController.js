const multer = require('multer');
const skinAnalysisModel = require('../models/skinAnalysisModel');
const { uploadImage } = require('../utils/fileUpload');
const { ValidationError, NotFoundError } = require('../middleware/error');

// Configure multer for memory storage
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
}).single('image');

/**
 * Upload and analyze skin image
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const detectSkin = async (req, res, next) => {
  // Use multer to process the upload
  upload(req, res, async (err) => {
    try {
      if (err) {
        throw new ValidationError(err.message);
      }
      
      if (!req.file) {
        throw new ValidationError('Image file is required');
      }
      
      const userId = req.user.id;
      
      // Parse quiz data if provided
      let quizData = {};
      if (req.body.quizData) {
        try {
          quizData = JSON.parse(req.body.quizData);
        } catch (err) {
          throw new ValidationError('Invalid quiz data format');
        }
      }
      
      // Upload image to storage
      const { url: imageUrl, thumbnail: thumbnailUrl } = await uploadImage(
        req.file.buffer,
        'skin-analysis',
        `${Date.now()}_${req.file.originalname}`
      );
      
      // TODO: Integrate with AI model for skin analysis
      // For now, we'll just use mock results
      const results = generateMockAnalysisResults(quizData);
      const recommendations = generateMockRecommendations(results);
      
      // Save analysis to database
      const analysis = await skinAnalysisModel.create({
        userId,
        imageUrl,
        thumbnailUrl,
        quizData,
        results,
        recommendations
      });
      
      res.status(201).json({
        success: true,
        data: {
          analysisId: analysis.id,
          status: 'completed',
          results: analysis.results,
          recommendations: analysis.recommendations,
          createdAt: analysis.created_at
        }
      });
    } catch (error) {
      next(error);
    }
  });
};

/**
 * Get skin analysis history
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const getHistory = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    
    const history = await skinAnalysisModel.findByUserId(userId, page, limit);
    
    res.json({
      success: true,
      data: history
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get skin analysis by ID
 * 
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 * @param {Function} next - Express next middleware
 */
const getAnalysisById = async (req, res, next) => {
  try {
    const { analysisId } = req.params;
    const userId = req.user.id;
    
    // Get analysis
    const analysis = await skinAnalysisModel.findById(analysisId);
    
    // Check if analysis belongs to the current user
    if (analysis.user_id !== userId) {
      throw new NotFoundError('Analysis not found');
    }
    
    res.json({
      success: true,
      data: {
        analysisId: analysis.id,
        status: 'completed',
        results: analysis.results,
        recommendations: analysis.recommendations,
        createdAt: analysis.created_at
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Generate mock analysis results based on quiz data
 * 
 * @param {Object} quizData - Quiz data
 * @returns {Object} - Mock analysis results
 */
const generateMockAnalysisResults = (quizData) => {
  // Base values
  const base = {
    hydration: {
      value: 65 + Math.floor(Math.random() * 20),
      status: "皮肤水分充足，继续保持喵～",
      trend: "+5%",
      trendUp: true
    },
    oil: {
      value: 50 + Math.floor(Math.random() * 30),
      status: "T区油分略偏高，建议使用控油产品喵～"
    },
    sensitivity: {
      value: 1 + Math.floor(Math.random() * 4),
      maxValue: 5,
      status: "轻度敏感，建议使用温和产品喵～"
    },
    pores: {
      value: 20 + Math.floor(Math.random() * 50),
      status: "毛孔状况良好"
    },
    wrinkles: {
      value: 10 + Math.floor(Math.random() * 30),
      status: "几乎无细纹"
    },
    pigmentation: {
      value: 15 + Math.floor(Math.random() * 40),
      status: "轻微色素沉着"
    }
  };
  
  // Adjust based on skin type if available in quiz data
  if (quizData.skinType === '干性') {
    base.hydration.value = Math.max(40, base.hydration.value - 20);
    base.hydration.status = "皮肤偏干，需要补充水分喵～";
    base.oil.value = Math.max(30, base.oil.value - 20);
  } else if (quizData.skinType === '油性') {
    base.oil.value = Math.min(90, base.oil.value + 20);
    base.oil.status = "皮肤偏油，注意控油喵～";
  } else if (quizData.skinType === '敏感性') {
    base.sensitivity.value = Math.min(5, base.sensitivity.value + 2);
    base.sensitivity.status = "皮肤敏感度高，需谨慎选择产品喵～";
  }
  
  return base;
};

/**
 * Generate mock recommendations based on analysis results
 * 
 * @param {Object} results - Analysis results
 * @returns {Array} - Mock recommendations
 */
const generateMockRecommendations = (results) => {
  const recommendations = [];
  
  // Hydration recommendation
  if (results.hydration.value < 60) {
    recommendations.push({
      id: `rec_${Date.now()}_1`,
      title: "加强保湿防护",
      description: "建议使用含玻尿酸的保湿精华，提升肌肤水润度",
      iconType: "shield",
      priority: "高",
      timing: "建议立即使用",
      recommendedProducts: []
    });
  }
  
  // Oil control recommendation
  if (results.oil.value > 70) {
    recommendations.push({
      id: `rec_${Date.now()}_2`,
      title: "控油护理",
      description: "T区油分较高，建议使用控油产品，并定期清洁毛孔",
      iconType: "droplet",
      priority: "中",
      timing: "每日使用",
      recommendedProducts: []
    });
  }
  
  // Sensitivity recommendation
  if (results.sensitivity.value > 3) {
    recommendations.push({
      id: `rec_${Date.now()}_3`,
      title: "舒缓敏感",
      description: "皮肤敏感度较高，建议使用无刺激性的温和产品",
      iconType: "alert",
      priority: "高",
      timing: "持续使用",
      recommendedProducts: []
    });
  }
  
  // Default recommendation
  if (recommendations.length === 0) {
    recommendations.push({
      id: `rec_${Date.now()}_4`,
      title: "防晒提醒",
      description: "记得每日涂抹防晒，避免紫外线损伤肌肤喵～",
      iconType: "sun",
      priority: "中",
      timing: "外出前使用",
      recommendedProducts: []
    });
  }
  
  return recommendations;
};

module.exports = {
  detectSkin,
  getHistory,
  getAnalysisById
}; 