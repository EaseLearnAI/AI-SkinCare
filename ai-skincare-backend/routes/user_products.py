from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename
from models.product import Product
import os
import uuid
from bson import ObjectId

user_products_bp = Blueprint('user_products', __name__)

@user_products_bp.route('/', methods=['GET', 'POST', 'OPTIONS'])
@user_products_bp.route('', methods=['GET', 'POST', 'OPTIONS'])
@jwt_required(optional=True)
def get_or_create_user_products():
    """获取或创建用户产品"""
    # 根据请求方法进行不同处理
    if request.method == 'OPTIONS':
        response = jsonify({'success': True})
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
        response.headers.add('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
        return response
    
    # 验证认证状态
    current_user_id = get_jwt_identity()
    if not current_user_id:
        return jsonify({
            "success": False,
            "error": {
                "message": "需要登录",
                "code": "AUTHENTICATION_ERROR"
            }
        }), 401
    
    # GET请求处理
    if request.method == 'GET':
        try:
            db = current_app.config['MONGO_DB']
            
            # 获取分页参数
            page = int(request.args.get('page', 1))
            limit = int(request.args.get('limit', 50))
            category = request.args.get('category')
            sort_by = request.args.get('sortBy', 'date_desc')
            
            # 参数验证
            if page < 1:
                page = 1
            if limit < 1 or limit > 100:
                limit = 50
                
            skip = (page - 1) * limit
            
            # 构建查询条件
            query = {"user_id": current_user_id}
            if category:
                query["category"] = category
                
            # 构建排序条件
            sort_options = []
            if sort_by == "name_asc":
                sort_options = [("name", 1)]
            elif sort_by == "name_desc":
                sort_options = [("name", -1)]
            elif sort_by == "date_asc":
                sort_options = [("created_at", 1)]
            else:  # 默认按创建时间倒序
                sort_options = [("created_at", -1)]
            
            # 获取产品列表
            products = Product.find_by_query(
                db=db,
                query=query,
                limit=limit,
                skip=skip,
                sort=sort_options
            )
            
            # 获取总数
            total = db.products.count_documents(query)
            total_pages = (total + limit - 1) // limit if total > 0 else 1
            
            return jsonify({
                "success": True,
                "data": {
                    "products": [product.to_dict() for product in products],
                    "total": total,
                    "page": page,
                    "totalPages": total_pages
                }
            }), 200
            
        except Exception as e:
            return jsonify({
                "success": False,
                "error": {
                    "message": f"获取产品列表失败: {str(e)}",
                    "code": "SERVER_ERROR"
                }
            }), 500
    
    # POST请求处理
    elif request.method == 'POST':
        try:
            db = current_app.config['MONGO_DB']
            
            if not request.is_json:
                return jsonify({
                    "success": False,
                    "error": {
                        "message": "请求必须是JSON格式",
                        "code": "INVALID_REQUEST"
                    }
                }), 400
            
            data = request.get_json()
            if not data:
                return jsonify({
                    "success": False,
                    "error": {
                        "message": "请求数据为空",
                        "code": "INVALID_REQUEST"
                    }
                }), 400
            
            # 创建产品
            product = Product.create_product(
                db=db,
                user_id=current_user_id,
                name=data.get('name', '未命名产品'),
                brand=data.get('brand_name') or data.get('brandName'),
                category=data.get('category'),
                description=data.get('description', ''),
                image_path=data.get('image_url') or data.get('imageUrl'),
                ingredients=data.get('ingredients', []),
                analysis=data.get('analysis', {}),
                analysis_result=data.get('analysis_result') or data.get('analysisResult')
            )
            
            return jsonify({
                "success": True,
                "data": product.to_dict()
            }), 201
            
        except Exception as e:
            print(f"保存产品错误: {str(e)}")
            return jsonify({
                "success": False,
                "error": {
                    "message": f"保存产品失败: {str(e)}",
                    "code": "SERVER_ERROR"
                }
            }), 500

@user_products_bp.route('/<product_id>', methods=['GET', 'PUT', 'DELETE', 'OPTIONS'])
@jwt_required(optional=True)
def handle_product(product_id):
    """处理单个产品请求"""
    # OPTIONS请求处理
    if request.method == 'OPTIONS':
        response = jsonify({'success': True})
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
        response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,DELETE,OPTIONS')
        return response
    
    # 验证认证状态
    current_user_id = get_jwt_identity()
    if not current_user_id:
        return jsonify({
            "success": False,
            "error": {
                "message": "需要登录",
                "code": "AUTHENTICATION_ERROR"
            }
        }), 401
    
    try:
        db = current_app.config['MONGO_DB']
        
        # 查找产品
        product = Product.find_by_id(db, product_id)
        if not product:
            return jsonify({
                "success": False,
                "error": {
                    "message": "产品不存在",
                    "code": "NOT_FOUND"
                }
            }), 404
            
        # 验证所有权
        if product.user_id != current_user_id:
            return jsonify({
                "success": False,
                "error": {
                    "message": "无权访问此产品",
                    "code": "FORBIDDEN"
                }
            }), 403
        
        # 根据请求方法处理
        if request.method == 'GET':
            return jsonify({
                "success": True,
                "data": product.to_dict()
            }), 200
            
        elif request.method == 'PUT':
            # 获取更新数据
            data = request.get_json()
            if not data:
                return jsonify({
                    "success": False,
                    "error": {
                        "message": "请求数据为空",
                        "code": "INVALID_REQUEST"
                    }
                }), 400
                
            # 更新产品
            updated_product = product.update(
                db=db,
                name=data.get('name'),
                brand=data.get('brand_name') or data.get('brandName'),
                category=data.get('category'),
                description=data.get('description'),
                image_path=data.get('image_url') or data.get('imageUrl'),
                ingredients=data.get('ingredients'),
                analysis=data.get('analysis'),
                analysis_result=data.get('analysis_result') or data.get('analysisResult')
            )
            
            return jsonify({
                "success": True,
                "data": updated_product.to_dict()
            }), 200
            
        elif request.method == 'DELETE':
            # 删除产品
            product.delete(db)
            
            return jsonify({
                "success": True,
                "message": "产品已删除"
            }), 200
            
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"产品操作失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500

@user_products_bp.route('/<product_id>/image', methods=['POST', 'OPTIONS'])
@jwt_required(optional=True)
def upload_product_image(product_id):
    """上传产品图片"""
    # OPTIONS请求处理
    if request.method == 'OPTIONS':
        response = jsonify({'success': True})
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
        response.headers.add('Access-Control-Allow-Methods', 'POST,OPTIONS')
        return response
    
    # 验证认证状态
    current_user_id = get_jwt_identity()
    if not current_user_id:
        return jsonify({
            "success": False,
            "error": {
                "message": "需要登录",
                "code": "AUTHENTICATION_ERROR"
            }
        }), 401
    
    try:
        db = current_app.config['MONGO_DB']
        
        # 查找产品
        product = Product.find_by_id(db, product_id)
        if not product:
            return jsonify({
                "success": False,
                "error": {
                    "message": "产品不存在",
                    "code": "NOT_FOUND"
                }
            }), 404
            
        # 验证所有权
        if product.user_id != current_user_id:
            return jsonify({
                "success": False,
                "error": {
                    "message": "无权操作此产品",
                    "code": "FORBIDDEN"
                }
            }), 403
            
        # 检查文件是否存在
        if 'image' not in request.files:
            return jsonify({
                "success": False,
                "error": {
                    "message": "没有上传文件",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
            
        file = request.files['image']
        if file.filename == '':
            return jsonify({
                "success": False,
                "error": {
                    "message": "没有选择文件",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
            
        # 验证文件格式
        allowed_extensions = {'png', 'jpg', 'jpeg', 'gif'}
        if '.' not in file.filename or \
           file.filename.rsplit('.', 1)[1].lower() not in allowed_extensions:
            return jsonify({
                "success": False,
                "error": {
                    "message": "不支持的文件格式",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
            
        # 保存文件
        filename = secure_filename(file.filename)
        filename = f"{str(uuid.uuid4())}_{filename}"  # 添加UUID前缀避免文件名冲突
        
        # 确定存储路径
        upload_folder = os.path.join(current_app.config['UPLOAD_FOLDER'], 'products')
        os.makedirs(upload_folder, exist_ok=True)
        
        file_path = os.path.join(upload_folder, filename)
        file.save(file_path)
        
        # 更新产品图片路径
        image_url = f"/uploads/products/{filename}"
        product.update(db, image_path=image_url)
        
        return jsonify({
            "success": True,
            "data": {
                "imageUrl": image_url
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"上传图片失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500 