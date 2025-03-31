from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
import re

ingredients_bp = Blueprint('ingredients', __name__)

# 模拟成分数据库
INGREDIENT_DATA = {
    "1": {
        "id": "1",
        "name": "透明质酸钠",
        "aliases": ["玻尿酸", "Sodium Hyaluronate"],
        "description": "透明质酸钠是一种强效保湿成分，能够在皮肤表面形成保湿膜，减少水分流失。它可以吸收自身重量1000倍的水分子，被广泛应用于保湿产品中。",
        "functions": ["保湿", "修复"],
        "safetyLevel": 95,  # 安全等级，0-100
        "irritationLevel": 5,  # 刺激性，0-100
        "comedogenicLevel": 0,  # 致粉刺性，0-5
        "categories": ["保湿剂", "亲水性成分"],
        "benefits": [
            "提高皮肤含水量",
            "改善皮肤弹性",
            "减少细纹"
        ],
        "concerns": [],
        "suitableSkinTypes": ["干性", "中性", "油性", "混合性", "敏感性"],
        "sources": ["人工合成", "发酵技术"]
    },
    "2": {
        "id": "2",
        "name": "烟酰胺",
        "aliases": ["维生素B3", "Niacinamide"],
        "description": "烟酰胺是一种多功能活性成分，具有调节皮脂分泌、提亮肤色、抗炎和增强皮肤屏障功能的作用。它是维生素B3的一种形式，被广泛应用于护肤品中。",
        "functions": ["调节皮脂", "美白", "抗炎", "强化屏障"],
        "safetyLevel": 90,
        "irritationLevel": 10,
        "comedogenicLevel": 0,
        "categories": ["维生素", "活性成分"],
        "benefits": [
            "减少油脂分泌",
            "减轻色素沉着",
            "改善皮肤纹理",
            "减少红肿"
        ],
        "concerns": ["高浓度可能导致轻微刺激"],
        "suitableSkinTypes": ["油性", "痘痘肌", "混合性", "敏感性"],
        "sources": ["人工合成"]
    },
    "3": {
        "id": "3",
        "name": "水杨酸",
        "aliases": ["BHA", "Salicylic Acid"],
        "description": "水杨酸是一种脂溶性β-羟基酸，能够深入毛孔，溶解多余油脂和死皮细胞，具有去角质、抗炎、抗菌的作用。它是痘痘皮肤护理的常用成分。",
        "functions": ["去角质", "抗炎", "抗菌"],
        "safetyLevel": 75,
        "irritationLevel": 30,
        "comedogenicLevel": 0,
        "categories": ["化学去角质剂", "BHA"],
        "benefits": [
            "清除毛孔堵塞",
            "减少黑头和粉刺",
            "控制油脂分泌",
            "舒缓炎症"
        ],
        "concerns": [
            "可能导致皮肤干燥",
            "可能增加光敏感性",
            "孕妇应避免使用"
        ],
        "suitableSkinTypes": ["油性", "痘痘肌", "毛孔粗大肌肤"],
        "sources": ["人工合成", "柳树皮提取"]
    },
    "4": {
        "id": "4",
        "name": "视黄醇",
        "aliases": ["维生素A醇", "Retinol"],
        "description": "视黄醇是一种维生素A的衍生物，具有促进细胞更新、抗皱、抗衰老的作用。它被认为是最有效的抗衰老成分之一，但也可能引起刺激和脱皮。",
        "functions": ["抗皱", "抗衰老", "促进细胞更新"],
        "safetyLevel": 70,
        "irritationLevel": 40,
        "comedogenicLevel": 0,
        "categories": ["维生素", "抗衰老成分"],
        "benefits": [
            "减少细纹和皱纹",
            "改善皮肤纹理",
            "促进胶原蛋白生成",
            "减轻色素沉着"
        ],
        "concerns": [
            "可能导致刺激、发红和脱皮",
            "增加光敏感性",
            "孕妇禁用",
            "初次使用需要逐渐适应"
        ],
        "suitableSkinTypes": ["中性", "油性", "抗衰老需求的皮肤"],
        "sources": ["人工合成"]
    },
    "5": {
        "id": "5",
        "name": "甘油",
        "aliases": ["丙三醇", "Glycerin"],
        "description": "甘油是一种无色无味的液体，具有很强的吸湿性，能够吸收空气中的水分，保持皮肤水润。它是一种温和的保湿剂，适合各种肤质。",
        "functions": ["保湿", "软化"],
        "safetyLevel": 100,
        "irritationLevel": 0,
        "comedogenicLevel": 0,
        "categories": ["保湿剂", "亲水性成分"],
        "benefits": [
            "提高皮肤含水量",
            "软化角质层",
            "改善皮肤屏障功能"
        ],
        "concerns": [],
        "suitableSkinTypes": ["所有肤质", "特别适合干性肌肤"],
        "sources": ["植物油脂", "人工合成"]
    }
}

@ingredients_bp.route('/search', methods=['GET'])
def search_ingredients():
    """搜索成分"""
    try:
        # 获取搜索参数
        query = request.args.get('query', '')
        page = int(request.args.get('page', 1))
        limit = int(request.args.get('limit', 10))
        
        # 参数验证
        if page < 1:
            page = 1
        if limit < 1 or limit > 50:
            limit = 10
            
        # 搜索成分
        results = []
        if query:
            # 模拟搜索逻辑，在真实场景中应该连接到数据库
            for ingredient_id, ingredient in INGREDIENT_DATA.items():
                # 在名称、别名、描述中搜索
                name_match = query.lower() in ingredient['name'].lower()
                alias_match = any(query.lower() in alias.lower() for alias in ingredient['aliases'])
                desc_match = query.lower() in ingredient['description'].lower()
                
                if name_match or alias_match or desc_match:
                    results.append({
                        "id": ingredient['id'],
                        "name": ingredient['name'],
                        "description": ingredient['description'][:100] + "..." if len(ingredient['description']) > 100 else ingredient['description'],
                        "safetyLevel": ingredient['safetyLevel'],
                        "functions": ingredient['functions']
                    })
        else:
            # 如果没有搜索词，返回所有成分
            results = [
                {
                    "id": ingredient['id'],
                    "name": ingredient['name'],
                    "description": ingredient['description'][:100] + "..." if len(ingredient['description']) > 100 else ingredient['description'],
                    "safetyLevel": ingredient['safetyLevel'],
                    "functions": ingredient['functions']
                }
                for ingredient_id, ingredient in INGREDIENT_DATA.items()
            ]
        
        # 分页处理
        total = len(results)
        skip = (page - 1) * limit
        results = results[skip:skip+limit]
        
        # 计算总页数
        total_pages = (total + limit - 1) // limit if total > 0 else 1
        
        # 构建响应数据
        response_data = {
            "ingredients": results,
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
                "message": f"搜索成分失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500

@ingredients_bp.route('/<ingredient_id>', methods=['GET'])
def get_ingredient_detail(ingredient_id):
    """获取成分详情"""
    try:
        # 在真实场景中应该从数据库获取
        if ingredient_id in INGREDIENT_DATA:
            return jsonify({
                "success": True,
                "data": INGREDIENT_DATA[ingredient_id]
            }), 200
        else:
            return jsonify({
                "success": False,
                "error": {
                    "message": "成分不存在",
                    "code": "RESOURCE_NOT_FOUND"
                }
            }), 404
            
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"获取成分详情失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500

@ingredients_bp.route('/analyze', methods=['POST'])
@jwt_required()
def analyze_ingredients():
    """分析产品成分"""
    try:
        # 获取当前用户
        current_user_id = get_jwt_identity()
        
        # 获取请求数据
        data = request.json
        if not data or not data.get('ingredients'):
            return jsonify({
                "success": False,
                "error": {
                    "message": "缺少成分列表",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
            
        # 获取成分列表
        ingredients_list = data.get('ingredients')
        if not isinstance(ingredients_list, list):
            return jsonify({
                "success": False,
                "error": {
                    "message": "成分列表格式不正确",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
        
        # 这里是分析成分的逻辑
        # 在真实项目中，应该使用NLP或其他算法分析成分
        # 这里使用简单的模拟逻辑
        
        # 模拟识别到的成分
        recognized_ingredients = []
        safety_score = 0
        effectiveness_score = 0
        suitable_count = 0
        total_recognized = 0
        
        skin_type = "中性"  # 默认中性肌肤
        user_skin_concerns = []
        
        # 获取用户皮肤信息
        db = current_app.config.get('MONGO_DB')
        if db:
            from bson.objectid import ObjectId
            user = db.users.find_one({"_id": ObjectId(current_user_id)})
            if user and user.get("skin_type"):
                skin_type = user.get("skin_type")
                user_skin_concerns = user.get("skin_concerns", [])
        
        # 分析每个成分
        for idx, ingredient_name in enumerate(ingredients_list):
            # 简单模拟成分识别
            found = False
            for ingredient_id, ingredient_data in INGREDIENT_DATA.items():
                # 检查成分名称和别名
                if (ingredient_name.lower() in ingredient_data['name'].lower() or 
                    any(ingredient_name.lower() in alias.lower() for alias in ingredient_data['aliases'])):
                    total_recognized += 1
                    found = True
                    
                    # 复制成分数据
                    ingredient_info = ingredient_data.copy()
                    
                    # 添加适合当前用户肤质的标志
                    is_suitable = skin_type in ingredient_info.get('suitableSkinTypes', []) or "所有肤质" in ingredient_info.get('suitableSkinTypes', [])
                    if is_suitable:
                        suitable_count += 1
                        
                    # 计算安全分数和功效分数
                    safety_score += ingredient_info.get('safetyLevel', 0)
                    
                    # 计算功效分数（根据成分功能是否匹配用户需求）
                    user_needs_met = sum(1 for concern in user_skin_concerns if any(function.lower() in concern.lower() for function in ingredient_info.get('functions', [])))
                    effectiveness_weight = (user_needs_met / len(user_skin_concerns)) if user_skin_concerns else 0.5
                    effectiveness_score += 70 + (30 * effectiveness_weight)  # 基础分70，额外30分根据匹配度
                    
                    # 添加到已识别成分列表
                    recognized_ingredients.append({
                        "id": ingredient_info['id'],
                        "name": ingredient_info['name'],
                        "originalName": ingredient_name,
                        "position": idx + 1,
                        "safetyLevel": ingredient_info['safetyLevel'],
                        "functions": ingredient_info['functions'],
                        "concerns": ingredient_info['concerns'],
                        "isSuitable": is_suitable
                    })
                    break
            
            # 如果没有找到成分，添加未识别成分
            if not found:
                recognized_ingredients.append({
                    "id": f"unknown_{idx}",
                    "name": ingredient_name,
                    "originalName": ingredient_name,
                    "position": idx + 1,
                    "safetyLevel": 50,  # 未知成分默认安全等级
                    "functions": ["未知"],
                    "concerns": ["成分信息不完整"],
                    "isSuitable": False
                })
        
        # 计算最终分数
        if total_recognized > 0:
            safety_score = int(safety_score / total_recognized)
            effectiveness_score = int(effectiveness_score / total_recognized)
        else:
            safety_score = 50
            effectiveness_score = 50
            
        # 计算适合度分数
        suitability_score = int((suitable_count / len(ingredients_list)) * 100) if ingredients_list else 50
        
        # 生成分析结果
        analysis_result = {
            "safetyScore": safety_score,
            "effectivenessScore": effectiveness_score,
            "suitabilityScore": suitability_score,
            "recognizedIngredients": recognized_ingredients,
            "highlights": [
                {
                    "type": "good" if safety_score >= 80 else "warning" if safety_score >= 60 else "bad",
                    "description": f"产品整体安全评分为{safety_score}分" + ("，安全性较高" if safety_score >= 80 else "，安全性一般" if safety_score >= 60 else "，安全性较低")
                },
                {
                    "type": "good" if effectiveness_score >= 80 else "info" if effectiveness_score >= 60 else "warning",
                    "description": f"产品功效评分为{effectiveness_score}分，" + ("有效成分比例较高" if effectiveness_score >= 80 else "有效成分适中" if effectiveness_score >= 60 else "有效成分较少")
                },
                {
                    "type": "good" if suitability_score >= 80 else "info" if suitability_score >= 60 else "warning",
                    "description": f"产品与您的{skin_type}肤质适合度为{suitability_score}分"
                }
            ],
            "summary": f"该产品包含{len(ingredients_list)}种成分，其中{total_recognized}种已识别。整体安全评分{safety_score}分，功效评分{effectiveness_score}分，适合{skin_type}肤质的程度为{suitability_score}分。" + (
                "该产品安全有效，适合您使用。" if (safety_score >= 70 and effectiveness_score >= 70 and suitability_score >= 70) else
                "该产品整体合格，可以考虑使用。" if (safety_score >= 60 and effectiveness_score >= 60 and suitability_score >= 60) else
                "该产品部分指标较低，请谨慎使用。"
            )
        }
        
        return jsonify({
            "success": True,
            "data": analysis_result
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"分析成分失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500 