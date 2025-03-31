from flask import Flask, jsonify, request, send_from_directory, redirect, url_for
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from pymongo import MongoClient
from dotenv import load_dotenv
import os
import datetime
import logging
from werkzeug.exceptions import NotFound, InternalServerError

# 加载环境变量
load_dotenv()

# 创建Flask应用
app = Flask(__name__)

# 配置应用
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'your-secret-key')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = datetime.timedelta(days=1)
app.config['UPLOAD_FOLDER'] = os.path.join(os.getcwd(), 'uploads')

# 确保上传目录存在
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# 配置CORS，扩展允许源和请求方法
cors = CORS(app, resources={
    r"/api/*": {
        "origins": "*",  # 允许所有源，解决前端访问问题
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Accept"],
        "supports_credentials": True
    }
})

# 全局CORS预检处理
@app.before_request
def handle_preflight():
    if request.method == 'OPTIONS':
        # 特别处理save_web端点的OPTIONS请求
        if '/skin_analysis/save_web' in request.path:
            app.logger.info(f"处理OPTIONS预检请求: {request.path}")
            response = app.make_default_options_response()
            response.headers.add('Access-Control-Allow-Origin', '*')
            response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,Accept')
            response.headers.add('Access-Control-Allow-Methods', 'POST,OPTIONS')
            return response

# 初始化JWT
jwt = JWTManager(app)

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# 连接MongoDB
mongo_uri = os.getenv('MONGO_URI', 'mongodb://localhost:27017/')
mongo_db = os.getenv('MONGO_DB', 'ai_skincare')
try:
    # 打印连接信息以便调试
    app.logger.info(f'尝试连接MongoDB: {mongo_uri}')
    
    mongo_client = MongoClient(mongo_uri, serverSelectionTimeoutMS=5000)
    # 验证连接
    mongo_client.server_info()
    db = mongo_client[mongo_db]
    app.config['MONGO_DB'] = db
    app.config['MONGO_CLIENT'] = mongo_client
    app.logger.info(f'Successfully connected to MongoDB at {mongo_uri}, 数据库: {mongo_db}')
except Exception as e:
    app.logger.error(f'Failed to connect to MongoDB: {str(e)}')
    app.logger.error(f'MongoDB连接URL: {mongo_uri}')
    app.logger.error(f'MongoDB数据库: {mongo_db}')
    app.logger.error(f'请确保MongoDB服务正在运行并可访问')
    db = None
    # 在开发环境中继续运行，生产环境应当退出
    if os.getenv('FLASK_ENV') != 'development':
        raise e

# 导入路由
from routes.auth import auth_bp
from routes.user_products import user_products_bp
from routes.product_analysis import product_analysis_bp
from routes.skin_analysis import skin_analysis_bp
from routes.ingredients import ingredients_bp
from routes.conflicts import conflicts_bp

# 注册蓝图
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(user_products_bp, url_prefix='/api/user/products')
app.register_blueprint(product_analysis_bp, url_prefix='/api/product-analysis')
app.register_blueprint(skin_analysis_bp, url_prefix='/api/skin-analysis')
app.register_blueprint(ingredients_bp, url_prefix='/api/ingredients')
app.register_blueprint(conflicts_bp, url_prefix='/api/conflict')

# 错误处理
@app.errorhandler(NotFound)
def handle_not_found(error):
    return jsonify({
        "success": False,
        "error": {
            "message": "资源不存在",
            "code": "RESOURCE_NOT_FOUND"
        }
    }), 404

@app.errorhandler(InternalServerError)
def handle_internal_error(error):
    return jsonify({
        "success": False,
        "error": {
            "message": "服务器内部错误",
            "code": "SERVER_ERROR"
        }
    }), 500

# 静态文件路由
@app.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# 健康检查
@app.route('/api/health', methods=['GET'])
def health_check():
    mongo_status = "connected" if db else "disconnected"
    
    return jsonify({
        "success": True,
        "status": "healthy",
        "services": {
            "api": "running",
            "mongodb": mongo_status
        },
        "timestamp": str(datetime.datetime.utcnow())
    })

# 主页路由
@app.route('/')
def index():
    return redirect(url_for('api_docs'))

# API文档
@app.route('/api/docs', methods=['GET'])
def api_docs():
    return jsonify({
        "success": True,
        "message": "皮肤护理APP API文档",
        "version": "1.0.0",
        "endpoints": [
            {
                "path": "/api/auth/register",
                "method": "POST",
                "description": "用户注册"
            },
            {
                "path": "/api/auth/login",
                "method": "POST",
                "description": "用户登录"
            },
            {
                "path": "/api/auth/me",
                "method": "GET",
                "description": "获取当前用户信息"
            },
            {
                "path": "/api/user/products",
                "method": "GET",
                "description": "获取用户的产品列表"
            },
            {
                "path": "/api/user/products",
                "method": "POST",
                "description": "创建新产品"
            },
            {
                "path": "/api/product-analysis/scan",
                "method": "POST",
                "description": "扫描产品进行分析"
            },
            {
                "path": "/api/skin-analysis/detect",
                "method": "POST",
                "description": "上传皮肤图片进行分析"
            },
            {
                "path": "/api/ingredients/search",
                "method": "GET",
                "description": "搜索成分"
            },
            {
                "path": "/api/conflict/ingredients",
                "method": "POST",
                "description": "检查成分冲突"
            },
            {
                "path": "/api/conflict/products",
                "method": "POST",
                "description": "检查产品冲突"
            }
        ]
    })

# 调试路由 - 用于测试连接和MongoDB状态
@app.route('/api/debug', methods=['GET'])
def debug_info():
    mongo_status = "connected" if app.config.get('MONGO_DB') else "disconnected"
    mongo_uri = os.getenv('MONGO_URI', 'mongodb://localhost:27017/')
    
    return jsonify({
        "success": True,
        "app": {
            "debug": app.debug,
            "env": os.getenv('FLASK_ENV', 'production')
        },
        "mongodb": {
            "status": mongo_status,
            "uri": mongo_uri.replace("://", "://**:**@"),  # 隐藏凭据
            "database": os.getenv('MONGO_DB', 'ai_skincare')
        },
        "request": {
            "path": request.path,
            "method": request.method,
            "host": request.host,
            "url": request.url
        }
    })

if __name__ == '__main__':
    app.run(debug=os.getenv('FLASK_ENV') == 'development', host='0.0.0.0', port=int(os.getenv('PORT', 5000))) 