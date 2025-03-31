from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename
import os
import uuid
from datetime import datetime
import json
from bson.objectid import ObjectId

skin_analysis_bp = Blueprint('skin_analysis', __name__)

# 添加专用于Web平台的肌肤分析结果保存路由 - 支持多种路径格式
@skin_analysis_bp.route('/save_web', methods=['POST', 'OPTIONS'])
@skin_analysis_bp.route('/save', methods=['POST', 'OPTIONS']) # 支持简单路径
@jwt_required(optional=True)
def save_skin_analysis_web():
    """专门为Web平台设计的保存肌肤分析结果API，解决CORS问题"""
    # 处理OPTIONS预检请求
    if request.method == 'OPTIONS':
        response = jsonify({'success': True})
        # 手动设置CORS响应头
        response.headers.add('Access-Control-Allow-Origin', '*')  # 或设置为特定的域名
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,Accept')
        response.headers.add('Access-Control-Allow-Methods', 'POST,OPTIONS')
        return response
    
    # 记录请求信息，帮助调试
    current_app.logger.info(f"收到Web平台保存请求 - 路径: {request.path}")
    current_app.logger.info(f"请求头: {dict(request.headers)}")
    
    try:
        # 获取当前用户ID（可选）
        current_user_id = get_jwt_identity()
        if not current_user_id:
            current_app.logger.warning("Web平台请求无用户认证，将使用匿名用户ID")
            current_user_id = "anonymous_web_user"  # 使用匿名用户ID而不是返回错误
            
        # 检查请求数据
        if not request.is_json:
            current_app.logger.error("Web平台请求非JSON格式")
            return jsonify({
                "success": False,
                "error": {
                    "message": "需要JSON格式数据",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
        
        # 获取请求数据
        data = request.get_json()
        current_app.logger.info(f"Web平台请求数据类型: {type(data)}")
        current_app.logger.info(f"Web平台请求数据: {data}")
        
        if 'analysis_result' not in data:
            return jsonify({
                "success": False,
                "error": {
                    "message": "缺少分析结果数据",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
        
        # 提取分析结果和时间
        analysis_result = data['analysis_result']
        analysis_time = data.get('analysis_time', datetime.utcnow().isoformat())
        
        # 图片路径将为空，因为Web平台不上传图片文件
        image_path = ''
        
        # 生成UUID作为唯一标识符
        analysis_id = str(ObjectId())
        
        # 保存分析记录到数据库
        db = current_app.config.get('MONGO_DB')
        if db:
            try:
                # 转换日期格式，避免解析错误
                try:
                    # 处理可能的时间格式
                    if 'Z' in analysis_time:
                        dt = analysis_time.replace('Z', '+00:00')
                    else:
                        dt = analysis_time
                    # 移除可能的毫秒部分
                    if '.' in dt:
                        dt = dt.split('.')[0]
                    created_at = datetime.fromisoformat(dt)
                except ValueError:
                    current_app.logger.warning(f"无法解析时间格式: {analysis_time}，使用当前时间")
                    created_at = datetime.utcnow()
                
                # 检查MongoDB连接
                current_app.logger.info("检查MongoDB连接...")
                # 尝试简单操作测试连接
                db.command('ping')
                current_app.logger.info("MongoDB连接正常")
                
                # 准备数据库记录
                analysis_record = {
                    "_id": ObjectId(analysis_id),
                    "user_id": current_user_id,
                    "image_path": image_path,
                    "result": analysis_result,
                    "created_at": created_at,
                    "platform": "web",
                    "has_image": False
                }
                
                # 插入记录
                current_app.logger.info("正在插入MongoDB记录...")
                result = db.skin_analyses.insert_one(analysis_record)
                current_app.logger.info(f"MongoDB插入结果: {result.acknowledged}, ID: {result.inserted_id}")
                
                current_app.logger.info(f"Web平台肌肤分析结果已成功保存到数据库，ID: {analysis_id}")
            except Exception as mongo_err:
                current_app.logger.error(f"MongoDB操作失败: {str(mongo_err)}")
                return jsonify({
                    "success": False,
                    "error": {
                        "message": f"保存到数据库失败: {str(mongo_err)}",
                        "code": "DATABASE_ERROR"
                    }
                }), 500
        else:
            # 如果没有数据库连接，记录错误
            current_app.logger.error("无法保存Web平台肌肤分析结果：MongoDB连接不可用")
            return jsonify({
                "success": False,
                "error": {
                    "message": "数据库连接不可用",
                    "code": "DATABASE_ERROR"
                }
            }), 500
        
        # 构建响应数据
        response_data = {
            "id": analysis_id,
            "dateTime": analysis_time,
            "saved": True,
            "message": "Web平台肌肤分析结果已成功保存"
        }
        
        return jsonify({
            "success": True,
            "data": response_data
        }), 200
        
    except Exception as e:
        import traceback
        current_app.logger.error(f"保存Web平台肌肤分析结果时出错: {str(e)}")
        current_app.logger.error(f"错误堆栈: {traceback.format_exc()}")
        return jsonify({
            "success": False,
            "error": {
                "message": f"保存失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500

@skin_analysis_bp.route('/detect', methods=['POST'])
@jwt_required()
def detect_skin():
    """接收用户上传的皮肤图片，进行肤质分析"""
    try:
        # 获取当前用户ID
        current_user_id = get_jwt_identity()
        
        # 检查文件是否存在
        if 'image' not in request.files:
            return jsonify({
                "success": False,
                "error": {
                    "message": "没有上传图片",
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
        allowed_extensions = {'png', 'jpg', 'jpeg'}
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
        upload_folder = os.path.join(current_app.config['UPLOAD_FOLDER'], 'skin_analysis')
        os.makedirs(upload_folder, exist_ok=True)
        
        file_path = os.path.join(upload_folder, filename)
        file.save(file_path)
        
        # 这里是分析皮肤的逻辑
        # 为简单起见，直接返回模拟数据
        # TODO: 实现真实的皮肤分析逻辑
        
        # 模拟分析结果数据
        analysis_result = {
            "skinType": "偏干性肌肤",
            "moisture": 45,  # 水分值（百分比）
            "oil": 30,  # 油分值（百分比）
            "sensitivity": 60,  # 敏感度（百分比）
            "pores": 35,  # 毛孔问题（百分比）
            "wrinkles": 25,  # 皱纹问题（百分比）
            "spots": 40,  # 色斑问题（百分比）
            "acne": 20,  # 痘痘问题（百分比）
            "overall": 65,  # 整体肌肤健康度（百分比）
            "concerns": [
                {
                    "type": "dryness",
                    "level": "moderate",
                    "description": "皮肤偏干，特别是T区"
                },
                {
                    "type": "sensitivity",
                    "level": "mild",
                    "description": "存在轻微的敏感迹象"
                }
            ],
            "recommendations": [
                {
                    "category": "cleanser",
                    "description": "使用温和无皂基的洁面产品，避免使用含有酒精的产品"
                },
                {
                    "category": "moisturizer",
                    "description": "选择含有透明质酸、神经酰胺等成分的保湿产品"
                },
                {
                    "category": "sunscreen",
                    "description": "每日使用SPF30以上的防晒产品，保护皮肤"
                }
            ]
        }
        
        # 保存分析记录到数据库
        db = current_app.config.get('MONGO_DB')
        if db:
            analysis_record = {
                "user_id": current_user_id,
                "image_path": f"uploads/skin_analysis/{filename}",
                "result": analysis_result,
                "created_at": datetime.utcnow()
            }
            
            # 插入记录并获取ID
            result = db.skin_analyses.insert_one(analysis_record)
            analysis_id = str(result.inserted_id)
        else:
            # 如果没有数据库连接，生成临时ID
            analysis_id = str(uuid.uuid4())
        
        # 构建响应数据
        response_data = {
            "id": analysis_id,
            "imageUrl": f"/uploads/skin_analysis/{filename}",
            "dateTime": datetime.utcnow().isoformat(),
            "result": analysis_result
        }
        
        return jsonify({
            "success": True,
            "data": response_data
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"肤质分析失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500

@skin_analysis_bp.route('/history', methods=['GET'])
@jwt_required()
def get_analysis_history():
    """获取用户的肤质分析历史记录"""
    try:
        # 获取当前用户ID
        current_user_id = get_jwt_identity()
        
        # 获取分页参数
        page = int(request.args.get('page', 1))
        limit = int(request.args.get('limit', 10))
        
        # 参数验证
        if page < 1:
            page = 1
        if limit < 1 or limit > 50:
            limit = 10
        
        skip = (page - 1) * limit
        
        # 从数据库获取历史记录
        db = current_app.config.get('MONGO_DB')
        
        history_data = []
        total = 0
        
        if db:
            # 查询记录
            cursor = db.skin_analyses.find({"user_id": current_user_id}) \
                       .sort("created_at", -1) \
                       .skip(skip) \
                       .limit(limit)
            
            # 转换为列表
            history_data = []
            for record in cursor:
                history_data.append({
                    "id": str(record["_id"]),
                    "imageUrl": record["image_path"].replace("uploads/", "/uploads/"),
                    "dateTime": record["created_at"].isoformat(),
                    "skinType": record["result"]["skinType"],
                    "overall": record["result"]["overall"]
                })
            
            # 获取总数
            total = db.skin_analyses.count_documents({"user_id": current_user_id})
        else:
            # 如果没有数据库连接，返回模拟数据
            history_data = [
                {
                    "id": "1",
                    "imageUrl": "/uploads/skin_analysis/sample1.jpg",
                    "dateTime": datetime.utcnow().isoformat(),
                    "skinType": "偏干性肌肤",
                    "overall": 65
                },
                {
                    "id": "2",
                    "imageUrl": "/uploads/skin_analysis/sample2.jpg",
                    "dateTime": datetime.utcnow().isoformat(),
                    "skinType": "中性肌肤",
                    "overall": 75
                }
            ]
            total = len(history_data)
        
        # 计算总页数
        total_pages = (total + limit - 1) // limit if total > 0 else 1
        
        # 构建响应数据
        response_data = {
            "history": history_data,
            "total": total,
            "page": page,
            "totalPages": total_pages
        }
        
        return jsonify({
            "success": True,
            "data": response_data
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"获取历史记录失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500

@skin_analysis_bp.route('/<analysis_id>', methods=['GET'])
@jwt_required()
def get_analysis_detail(analysis_id):
    """获取特定肤质分析的详细信息"""
    try:
        # 获取当前用户ID
        current_user_id = get_jwt_identity()
        
        # 从数据库获取分析记录
        db = current_app.config.get('MONGO_DB')
        analysis_record = None
        
        if db:
            # 从MongoDB导入ObjectId
            from bson.objectid import ObjectId
            
            # 查询记录
            try:
                record = db.skin_analyses.find_one({
                    "_id": ObjectId(analysis_id),
                    "user_id": current_user_id
                })
                
                if record:
                    analysis_record = {
                        "id": str(record["_id"]),
                        "imageUrl": record["image_path"].replace("uploads/", "/uploads/"),
                        "dateTime": record["created_at"].isoformat(),
                        "result": record["result"]
                    }
            except:
                # ID格式无效或其他错误
                pass
                
        if not analysis_record:
            # 如果记录不存在，返回模拟数据
            if analysis_id == "1":
                analysis_record = {
                    "id": "1",
                    "imageUrl": "/uploads/skin_analysis/sample1.jpg",
                    "dateTime": datetime.utcnow().isoformat(),
                    "result": {
                        "skinType": "偏干性肌肤",
                        "moisture": 45,
                        "oil": 30,
                        "sensitivity": 60,
                        "pores": 35,
                        "wrinkles": 25,
                        "spots": 40,
                        "acne": 20,
                        "overall": 65,
                        "concerns": [
                            {
                                "type": "dryness",
                                "level": "moderate",
                                "description": "皮肤偏干，特别是T区"
                            },
                            {
                                "type": "sensitivity",
                                "level": "mild",
                                "description": "存在轻微的敏感迹象"
                            }
                        ],
                        "recommendations": [
                            {
                                "category": "cleanser",
                                "description": "使用温和无皂基的洁面产品，避免使用含有酒精的产品"
                            },
                            {
                                "category": "moisturizer",
                                "description": "选择含有透明质酸、神经酰胺等成分的保湿产品"
                            },
                            {
                                "category": "sunscreen",
                                "description": "每日使用SPF30以上的防晒产品，保护皮肤"
                            }
                        ]
                    }
                }
            else:
                return jsonify({
                    "success": False,
                    "error": {
                        "message": "未找到该分析记录",
                        "code": "RESOURCE_NOT_FOUND"
                    }
                }), 404
        
        return jsonify({
            "success": True,
            "data": analysis_record
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"获取分析详情失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500 