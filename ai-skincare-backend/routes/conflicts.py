from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.product import Product
from bson.objectid import ObjectId

conflicts_bp = Blueprint('conflicts', __name__)

# 定义已知的成分冲突关系
INGREDIENT_CONFLICTS = {
    # 维生素C相关冲突
    "维生素C": ["视黄醇", "水杨酸", "果酸", "酒精"],
    "维生素C衍生物": ["视黄醇", "水杨酸", "果酸"],
    "抗坏血酸": ["视黄醇", "水杨酸", "果酸", "酒精"],
    
    # 视黄醇相关冲突
    "视黄醇": ["维生素C", "抗坏血酸", "水杨酸", "果酸", "乙醇酸", "水杨酸", "苯甲酰过氧化物"],
    "维生素A酸": ["维生素C", "抗坏血酸", "水杨酸", "果酸", "乙醇酸", "水杨酸", "苯甲酰过氧化物"],
    
    # 果酸相关冲突
    "果酸": ["维生素C", "视黄醇", "维生素A酸", "水杨酸"],
    "乙醇酸": ["视黄醇", "维生素A酸"],
    "乳酸": ["视黄醇", "维生素A酸"],
    
    # 其他常见冲突
    "烟酰胺": ["维生素C", "抗坏血酸"],  # 虽然有争议，但有些人认为会相互影响
    "果酸": ["维生素C", "视黄醇"],
    "铜肽": ["维生素C", "抗坏血酸"],
    "氢醌": ["苯甲酰过氧化物"],
    "水杨酸": ["视黄醇", "维生素A酸", "果酸"],
    
    # 防晒成分冲突
    "二氧化钛": ["维生素C"],
    "氧化锌": ["维生素C"]
}

# 成分的别名映射表
INGREDIENT_ALIASES = {
    "维生素C": ["抗坏血酸", "L-抗坏血酸", "Vitamin C", "Ascorbic Acid"],
    "视黄醇": ["维生素A醇", "Retinol", "Vitamin A"],
    "维生素A酸": ["视黄酸", "Retinoic Acid", "Tretinoin"],
    "水杨酸": ["BHA", "Salicylic Acid"],
    "果酸": ["AHA", "Alpha Hydroxy Acid"],
    "乙醇酸": ["Glycolic Acid"],
    "乳酸": ["Lactic Acid"],
    "烟酰胺": ["维生素B3", "Niacinamide", "Vitamin B3"],
    "铜肽": ["铜三肽-1", "Copper Peptide", "GHK-Cu"],
    "氢醌": ["Hydroquinone"],
    "二氧化钛": ["Titanium Dioxide"],
    "氧化锌": ["Zinc Oxide"]
}

def normalize_ingredient(ingredient_name):
    """将成分名称标准化，处理别名"""
    # 转为小写便于比较
    ingredient_name_lower = ingredient_name.lower()
    
    # 查找标准名称
    for standard_name, aliases in INGREDIENT_ALIASES.items():
        if ingredient_name_lower == standard_name.lower() or any(ingredient_name_lower == alias.lower() for alias in aliases):
            return standard_name
            
    # 如果找不到匹配的别名，返回原名称
    return ingredient_name

def check_conflicts(ingredients1, ingredients2):
    """检查两组成分之间的冲突"""
    conflicts = []
    
    # 标准化两组成分名称
    normalized_ingredients1 = [normalize_ingredient(ing) for ing in ingredients1]
    normalized_ingredients2 = [normalize_ingredient(ing) for ing in ingredients2]
    
    # 检查每一对成分是否存在冲突
    for idx1, ing1 in enumerate(normalized_ingredients1):
        if ing1 in INGREDIENT_CONFLICTS:
            for idx2, ing2 in enumerate(normalized_ingredients2):
                if ing2 in INGREDIENT_CONFLICTS[ing1]:
                    conflicts.append({
                        "ingredient1": {
                            "name": ing1,
                            "originalName": ingredients1[idx1]
                        },
                        "ingredient2": {
                            "name": ing2,
                            "originalName": ingredients2[idx2]
                        },
                        "severity": "高",  # 可根据实际情况调整
                        "description": f"{ing1}与{ing2}不宜同时使用，可能导致产品失效或皮肤刺激。"
                    })
    
    return conflicts

@conflicts_bp.route('/ingredients', methods=['POST'])
def check_ingredient_conflicts():
    """检查成分列表中的冲突"""
    try:
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
        ingredients = data.get('ingredients')
        
        # 检查格式
        if not isinstance(ingredients, list):
            return jsonify({
                "success": False,
                "error": {
                    "message": "成分列表格式不正确",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
        
        # 查找成分之间的冲突
        conflicts = []
        
        for i in range(len(ingredients)):
            for j in range(i+1, len(ingredients)):
                # 检查成分i和成分j之间是否有冲突
                ing_conflicts = check_conflicts([ingredients[i]], [ingredients[j]])
                conflicts.extend(ing_conflicts)
        
        # 构建响应数据
        response_data = {
            "conflicts": conflicts,
            "hasConflicts": len(conflicts) > 0
        }
        
        return jsonify({
            "success": True,
            "data": response_data
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"检测成分冲突失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500

@conflicts_bp.route('/products', methods=['POST'])
@jwt_required()
def check_product_conflicts():
    """检查多个产品之间的成分冲突"""
    try:
        # 获取当前用户ID
        current_user_id = get_jwt_identity()
        
        # 获取请求数据
        data = request.json
        if not data or not data.get('productIds'):
            return jsonify({
                "success": False,
                "error": {
                    "message": "缺少产品ID列表",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
        
        # 获取产品ID列表
        product_ids = data.get('productIds')
        
        # 检查格式
        if not isinstance(product_ids, list) or len(product_ids) < 2:
            return jsonify({
                "success": False,
                "error": {
                    "message": "产品ID列表格式不正确或数量不足",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
        
        # 获取数据库连接
        db = current_app.config.get('MONGO_DB')
        
        products = []
        not_found_ids = []
        
        # 获取产品详情
        if db:
            for product_id in product_ids:
                try:
                    # 从数据库获取产品
                    product = db.products.find_one({
                        "_id": ObjectId(product_id),
                        "user_id": current_user_id
                    })
                    
                    if product:
                        products.append({
                            "id": str(product["_id"]),
                            "name": product.get("name", "未命名产品"),
                            "ingredients": product.get("ingredients", [])
                        })
                    else:
                        not_found_ids.append(product_id)
                except:
                    not_found_ids.append(product_id)
        
        # 如果没有找到任何产品，返回错误
        if not products:
            return jsonify({
                "success": False,
                "error": {
                    "message": "未找到任何指定的产品",
                    "code": "RESOURCE_NOT_FOUND"
                }
            }), 404
        
        # 检查产品之间的成分冲突
        all_conflicts = []
        
        for i in range(len(products)):
            for j in range(i+1, len(products)):
                product1 = products[i]
                product2 = products[j]
                
                # 检查两个产品的成分是否有冲突
                conflicts = check_conflicts(product1.get("ingredients", []), product2.get("ingredients", []))
                
                if conflicts:
                    all_conflicts.append({
                        "product1": {
                            "id": product1["id"],
                            "name": product1["name"]
                        },
                        "product2": {
                            "id": product2["id"],
                            "name": product2["name"]
                        },
                        "conflicts": conflicts
                    })
        
        # 构建响应数据
        response_data = {
            "products": products,
            "conflicts": all_conflicts,
            "hasConflicts": len(all_conflicts) > 0,
            "notFoundIds": not_found_ids
        }
        
        return jsonify({
            "success": True,
            "data": response_data
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"检测产品冲突失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500
        
@conflicts_bp.route('/routines', methods=['POST'])
@jwt_required()
def check_routine_conflicts():
    """检查护肤流程中产品的冲突和顺序"""
    try:
        # 获取当前用户ID
        current_user_id = get_jwt_identity()
        
        # 获取请求数据
        data = request.json
        if not data or not data.get('routine'):
            return jsonify({
                "success": False,
                "error": {
                    "message": "缺少护肤流程数据",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
        
        # 获取护肤流程
        routine = data.get('routine')
        
        # 检查格式
        if not isinstance(routine, list):
            return jsonify({
                "success": False,
                "error": {
                    "message": "护肤流程格式不正确",
                    "code": "VALIDATION_ERROR"
                }
            }), 400
        
        # 获取数据库连接
        db = current_app.config.get('MONGO_DB')
        
        # 处理护肤流程
        steps = []
        product_ids = []
        not_found_ids = []
        
        for step in routine:
            if not isinstance(step, dict) or 'productId' not in step or 'stepType' not in step:
                continue
                
            product_id = step.get('productId')
            step_type = step.get('stepType')
            
            try:
                # 从数据库获取产品
                if db:
                    product = db.products.find_one({
                        "_id": ObjectId(product_id),
                        "user_id": current_user_id
                    })
                    
                    if product:
                        steps.append({
                            "productId": product_id,
                            "productName": product.get("name", "未命名产品"),
                            "stepType": step_type,
                            "ingredients": product.get("ingredients", [])
                        })
                        product_ids.append(product_id)
                    else:
                        not_found_ids.append(product_id)
                else:
                    # 如果没有数据库连接，模拟数据
                    steps.append({
                        "productId": product_id,
                        "productName": f"产品 {product_id}",
                        "stepType": step_type,
                        "ingredients": []
                    })
                    product_ids.append(product_id)
            except:
                not_found_ids.append(product_id)
        
        # 检查流程中的冲突
        conflicts = []
        order_issues = []
        
        # 产品顺序建议
        STEP_ORDER = {
            "cleanser": 1,       # 洁面
            "toner": 2,          # 爽肤水
            "essence": 3,        # 精华
            "serum": 4,          # 精华
            "ampoule": 5,        # 安瓶
            "eye_cream": 6,      # 眼霜
            "moisturizer": 7,    # 面霜
            "oil": 8,            # 面油
            "sunscreen": 9,      # 防晒
            "mask": 10           # 面膜
        }
        
        # 检查产品使用顺序是否合理
        if len(steps) >= 2:
            for i in range(len(steps)-1):
                step1 = steps[i]
                step2 = steps[i+1]
                
                # 获取步骤类型的推荐顺序
                order1 = STEP_ORDER.get(step1.get("stepType"), 999)
                order2 = STEP_ORDER.get(step2.get("stepType"), 999)
                
                # 如果顺序不对，添加到顺序问题列表
                if order1 > order2 and order1 != 999 and order2 != 999:
                    order_issues.append({
                        "step1": {
                            "productId": step1.get("productId"),
                            "productName": step1.get("productName"),
                            "stepType": step1.get("stepType")
                        },
                        "step2": {
                            "productId": step2.get("productId"),
                            "productName": step2.get("productName"),
                            "stepType": step2.get("stepType")
                        },
                        "recommendation": f"建议{step2.get('stepType')}（{step2.get('productName')}）在{step1.get('stepType')}（{step1.get('productName')}）之前使用"
                    })
        
        # 检查产品之间的成分冲突
        for i in range(len(steps)):
            for j in range(i+1, len(steps)):
                step1 = steps[i]
                step2 = steps[j]
                
                # 检查两个产品的成分是否有冲突
                ing_conflicts = check_conflicts(step1.get("ingredients", []), step2.get("ingredients", []))
                
                if ing_conflicts:
                    conflicts.append({
                        "product1": {
                            "id": step1.get("productId"),
                            "name": step1.get("productName")
                        },
                        "product2": {
                            "id": step2.get("productId"),
                            "name": step2.get("productName")
                        },
                        "conflicts": ing_conflicts
                    })
        
        # 生成护肤流程优化建议
        recommendations = []
        
        # 基于冲突添加建议
        if conflicts:
            for conflict in conflicts:
                product1 = conflict.get("product1", {}).get("name", "")
                product2 = conflict.get("product2", {}).get("name", "")
                
                ing_conflicts = conflict.get("conflicts", [])
                if ing_conflicts:
                    ing1 = ing_conflicts[0].get("ingredient1", {}).get("name", "")
                    ing2 = ing_conflicts[0].get("ingredient2", {}).get("name", "")
                    
                    recommendations.append(f"不建议同时使用{product1}和{product2}，因为它们含有互相冲突的成分（{ing1}和{ing2}）")
        
        # 基于顺序问题添加建议
        if order_issues:
            for issue in order_issues:
                recommendations.append(issue.get("recommendation"))
        
        # 构建响应数据
        response_data = {
            "steps": steps,
            "conflicts": conflicts,
            "orderIssues": order_issues,
            "recommendations": recommendations,
            "hasIssues": len(conflicts) > 0 or len(order_issues) > 0,
            "notFoundIds": not_found_ids
        }
        
        return jsonify({
            "success": True,
            "data": response_data
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": {
                "message": f"检测护肤流程冲突失败: {str(e)}",
                "code": "SERVER_ERROR"
            }
        }), 500 