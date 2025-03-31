from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import (
    create_access_token, jwt_required, get_jwt_identity
)
from models.user import User
import re

auth_bp = Blueprint('auth', __name__)

# 邮箱格式验证正则表达式
EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

@auth_bp.route('/register', methods=['POST'])
def register():
    """用户注册"""
    try:
        data = request.get_json()
        
        # 验证必要字段
        if not data or not all(k in data for k in ['username', 'email', 'password']):
            return jsonify({
                "success": False,
                "error": {
                    "message": "用户名、邮箱和密码为必填项",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
            
        # 验证邮箱格式
        if not EMAIL_PATTERN.match(data['email']):
            return jsonify({
                "success": False,
                "error": {
                    "message": "邮箱格式不正确",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
            
        # 验证密码长度
        if len(data['password']) < 6:
            return jsonify({
                "success": False,
                "error": {
                    "message": "密码长度不能少于6位",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
            
        db = current_app.config['MONGO_DB']
        
        # 检查邮箱是否已注册
        if User.find_by_email(db, data['email']):
            return jsonify({
                "success": False,
                "error": {
                    "message": "此邮箱已注册",
                    "code": "EMAIL_EXISTS"
                }
            }), 400
            
        # 检查用户名是否已存在
        if User.find_by_username(db, data['username']):
            return jsonify({
                "success": False,
                "error": {
                    "message": "此用户名已被使用",
                    "code": "USERNAME_EXISTS"
                }
            }), 400
            
        # 创建用户
        user = User.create_user(
            db,
            username=data['username'],
            email=data['email'],
            password=data['password'],
            phone_number=data.get('phoneNumber')
        )
        
        # 生成令牌
        token = create_access_token(identity=user.id)
        
        return jsonify({
            "success": True,
            "data": {
                "token": token,
                "user": user.to_dict()
            },
            "message": "注册成功"
        }), 201
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"服务器错误: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500
        
@auth_bp.route('/login', methods=['POST'])
def login():
    """用户登录"""
    try:
        data = request.get_json()
        
        # 验证必要字段
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({
                "success": False,
                "error": {
                    "message": "邮箱和密码为必填项",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
            
        db = current_app.config['MONGO_DB']
        
        # 根据邮箱查找用户
        user = User.find_by_email(db, data['email'])
        if not user:
            return jsonify({
                "success": False,
                "error": {
                    "message": "用户不存在",
                    "code": "USER_NOT_FOUND"
                }
            }), 404
            
        # 验证密码
        if not user.check_password(data['password']):
            return jsonify({
                "success": False,
                "error": {
                    "message": "密码错误",
                    "code": "INVALID_PASSWORD"
                }
            }), 401
            
        # 生成令牌
        token = create_access_token(identity=user.id)
        
        return jsonify({
            "success": True,
            "data": {
                "token": token,
                "user": user.to_dict()
            },
            "message": "登录成功"
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"服务器错误: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500
        
@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def get_user_info():
    """获取当前用户信息"""
    try:
        user_id = get_jwt_identity()
        db = current_app.config['MONGO_DB']
        
        user = User.find_by_id(db, user_id)
        if not user:
            return jsonify({
                "success": False,
                "error": {
                    "message": "用户不存在",
                    "code": "USER_NOT_FOUND"
                }
            }), 404
            
        return jsonify({
            "success": True,
            "data": user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"服务器错误: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """获取用户个人资料"""
    try:
        user_id = get_jwt_identity()
        db = current_app.config['MONGO_DB']
        
        user = User.find_by_id(db, user_id)
        if not user:
            return jsonify({
                "success": False,
                "error": {
                    "message": "用户不存在",
                    "code": "USER_NOT_FOUND"
                }
            }), 404
            
        return jsonify({
            "success": True,
            "data": user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"服务器错误: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500
        
@auth_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """更新用户个人资料"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        db = current_app.config['MONGO_DB']
        
        user = User.find_by_id(db, user_id)
        if not user:
            return jsonify({
                "success": False,
                "error": {
                    "message": "用户不存在",
                    "code": "USER_NOT_FOUND"
                }
            }), 404
            
        # 如果更新用户名，检查是否已存在
        if 'username' in data and data['username'] != user.username:
            if User.find_by_username(db, data['username']):
                return jsonify({
                    "success": False,
                    "error": {
                        "message": "此用户名已被使用",
                        "code": "USERNAME_EXISTS"
                    }
                }), 400
                
        # 更新用户信息
        updated_user = user.update(
            db,
            username=data.get('username'),
            avatar_url=data.get('avatarUrl'),
            skin_type=data.get('skin_type') or data.get('skinType'),
            skin_concerns=data.get('skin_concerns') or data.get('skinConcerns')
        )
        
        return jsonify({
            "success": True,
            "data": updated_user.to_dict(),
            "message": "个人资料已更新"
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"服务器错误: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500 