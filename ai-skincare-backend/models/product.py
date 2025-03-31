import uuid
from datetime import datetime
from bson import ObjectId

class Product:
    """产品数据模型"""
    
    def __init__(self, id, user_id, name, brand=None, category=None, 
                 description=None, image_path=None, ingredients=None, 
                 analysis=None, analysis_result=None, created_at=None, updated_at=None):
        self.id = str(id)
        self.user_id = user_id
        self.name = name
        self.brand = brand
        self.category = category
        self.description = description
        self.image_path = image_path
        self.ingredients = ingredients or []
        self.analysis = analysis or {}
        self.analysis_result = analysis_result
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
        
    def to_dict(self):
        """
        将产品对象转换为字典
        
        返回:
            dict: 产品信息字典
        """
        return {
            "id": self.id,
            "name": self.name,
            "brandName": self.brand,
            "category": self.category,
            "description": self.description,
            "imageUrl": self.image_path,
            "ingredients": [{"id": str(i), "name": name, "safetyLevel": 50} 
                           for i, name in enumerate(self.ingredients)],
            "analysis": self.analysis,
            "analysisResult": self.analysis_result,
            "createdAt": self.created_at.isoformat() if self.created_at else None,
            "updatedAt": self.updated_at.isoformat() if self.updated_at else None
        }
    
    @classmethod
    def from_dict(cls, data):
        """
        从字典创建产品对象
        
        参数:
            data (dict): 产品数据字典
            
        返回:
            Product: 产品对象
        """
        return cls(
            id=data.get('_id'),
            user_id=data.get('user_id'),
            name=data.get('name'),
            brand=data.get('brand'),
            category=data.get('category'),
            description=data.get('description'),
            image_path=data.get('image_path'),
            ingredients=data.get('ingredients'),
            analysis=data.get('analysis'),
            analysis_result=data.get('analysis_result'),
            created_at=data.get('created_at'),
            updated_at=data.get('updated_at')
        )
    
    @classmethod
    def create_product(cls, db, user_id, name, brand=None, category=None, 
                       description=None, image_path=None, ingredients=None,
                       analysis=None, analysis_result=None):
        """创建新产品"""
        now = datetime.utcnow()
        product_data = {
            "user_id": user_id,
            "name": name,
            "brand": brand,
            "category": category,
            "description": description,
            "image_path": image_path,
            "ingredients": ingredients or [],
            "analysis": analysis or {},
            "analysis_result": analysis_result,
            "created_at": now,
            "updated_at": now
        }
        
        result = db.products.insert_one(product_data)
        product_data['_id'] = result.inserted_id
        
        return cls.from_dict(product_data)
    
    @classmethod
    def find_by_id(cls, db, product_id):
        """根据ID查找产品"""
        try:
            product_data = db.products.find_one({"_id": ObjectId(product_id)})
            if product_data:
                return cls.from_dict(product_data)
            return None
        except:
            return None
    
    @classmethod
    def find_by_user_id(cls, db, user_id, limit=10, skip=0, sort=None):
        """查找用户的所有产品"""
        cursor = db.products.find({"user_id": user_id})
        
        if sort:
            cursor = cursor.sort(sort)
            
        cursor = cursor.skip(skip).limit(limit)
        
        return [cls.from_dict(product) for product in cursor]
    
    @classmethod
    def find_by_query(cls, db, query, limit=10, skip=0, sort=None):
        """根据查询条件查找产品"""
        try:
            cursor = db.products.find(query)
            
            if sort:
                cursor = cursor.sort(sort)
                
            cursor = cursor.skip(skip).limit(limit)
            
            result = []
            for product in cursor:
                result.append(cls.from_dict(product))
            
            return result
        except Exception as e:
            print(f"查询产品错误: {str(e)}")
            return []
    
    def update(self, db, name=None, brand=None, category=None, description=None,
              image_path=None, ingredients=None, analysis=None, analysis_result=None):
        """更新产品信息"""
        update_data = {"updated_at": datetime.utcnow()}
        
        if name is not None:
            update_data["name"] = name
        if brand is not None:
            update_data["brand"] = brand
        if category is not None:
            update_data["category"] = category
        if description is not None:
            update_data["description"] = description
        if image_path is not None:
            update_data["image_path"] = image_path
        if ingredients is not None:
            update_data["ingredients"] = ingredients
        if analysis is not None:
            update_data["analysis"] = analysis
        if analysis_result is not None:
            update_data["analysis_result"] = analysis_result
        
        db.products.update_one(
            {"_id": ObjectId(self.id)},
            {"$set": update_data}
        )
        
        # 更新当前对象
        for key, value in update_data.items():
            setattr(self, key, value)
            
        return self
    
    def delete(self, db):
        """删除产品"""
        db.products.delete_one({"_id": ObjectId(self.id)})
    
    def analyze_ingredients(self):
        """分析成分"""
        # 这里应该调用AI服务分析成分
        # 简单实现：返回一个模拟的分析结果
        return {
            "safetyScore": 85,
            "effectivenessScore": 90,
            "suitabilityScore": 75,
            "highlights": [
                {
                    "type": "good",
                    "description": "含有多种保湿成分，适合干性肌肤"
                },
                {
                    "type": "warning",
                    "description": "可能含有酒精，对敏感肌可能产生刺激"
                }
            ]
        }

    @classmethod
    def analyze(cls, product_data, skin_type=None, skin_status=None):
        """
        分析产品成分，生成AI总结和评分
        这里只是示例，实际实现应调用OpenAI API
        """
        # TODO: 实现AI分析逻辑，调用OpenAI API
        # 示例分析结果
        return {
            "aiSummary": f"这是一个{product_data['name']}的AI分析总结。它含有多种护肤成分，适合{skin_type or '大多数'}肌肤类型。",
            "analysis": {
                "safetyScore": 85,
                "effectivenessScore": 90,
                "suitabilityScore": 75,
                "highlights": [
                    {
                        "type": "good",
                        "description": "含有保湿成分，有助于保持肌肤水分"
                    },
                    {
                        "type": "warning",
                        "description": "含有一些香料成分，敏感肌肤使用需谨慎"
                    }
                ]
            },
            "suitableFor": ["中性肌肤", "干性肌肤"],
            "notSuitableFor": ["敏感肌肤"]
        } 