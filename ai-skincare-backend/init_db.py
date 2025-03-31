#!/usr/bin/env python3
"""
MongoDB 数据库初始化脚本
用于创建必要的集合和索引
"""

import os
import sys
from pymongo import MongoClient, ASCENDING, TEXT
from dotenv import load_dotenv

def init_db():
    # 加载环境变量
    load_dotenv()
    
    # 连接MongoDB
    mongo_uri = os.environ.get('MONGO_URI', 'mongodb://localhost:27017/')
    db_name = os.environ.get('MONGO_DB', 'ai_skincare')
    
    try:
        print(f"正在连接到 MongoDB: {mongo_uri}")
        client = MongoClient(mongo_uri)
        db = client[db_name]
        print(f"已连接到数据库: {db_name}")
    except Exception as e:
        print(f"MongoDB连接错误: {e}")
        sys.exit(1)
    
    # 创建用户集合
    print("创建用户集合和索引...")
    db.users.create_index([("email", ASCENDING)], unique=True)
    db.users.create_index([("username", ASCENDING)], unique=True)
    db.users.create_index([("email", TEXT), ("username", TEXT)])  # 全文搜索
    
    # 创建产品集合
    print("创建产品集合和索引...")
    db.products.create_index([("user_id", ASCENDING)])
    db.products.create_index([("name", TEXT), ("brand", TEXT), ("category", TEXT)])  # 全文搜索
    
    # 创建皮肤分析集合
    print("创建皮肤分析集合和索引...")
    db.skin_analyses.create_index([("user_id", ASCENDING)])
    db.skin_analyses.create_index([("created_at", ASCENDING)])
    
    # 创建成分集合
    print("创建成分集合和索引...")
    db.ingredients.create_index([("name", TEXT), ("aliases", TEXT)])  # 全文搜索
    
    # 检查所有集合是否创建成功
    collections = db.list_collection_names()
    required_collections = ["users", "products", "skin_analyses", "ingredients"]
    
    missing_collections = [coll for coll in required_collections if coll not in collections]
    if missing_collections:
        print(f"警告: 以下集合未成功创建: {', '.join(missing_collections)}")
    else:
        print("所有必要的集合已成功创建")
    
    # 添加测试数据（可选）
    if "--with-sample-data" in sys.argv:
        add_sample_data(db)
    
    print("数据库初始化完成!")
    return True

def add_sample_data(db):
    """添加测试数据到数据库"""
    from werkzeug.security import generate_password_hash
    import datetime
    
    print("添加测试数据...")
    
    # 添加测试用户
    if db.users.count_documents({}) == 0:
        print("添加测试用户...")
        db.users.insert_one({
            "username": "testuser",
            "email": "test@example.com",
            "password_hash": generate_password_hash("password123"),
            "skin_type": "中性",
            "skin_concerns": ["干燥", "敏感"],
            "created_at": datetime.datetime.utcnow(),
            "updated_at": datetime.datetime.utcnow()
        })
    
    # 添加测试成分
    if db.ingredients.count_documents({}) == 0:
        print("添加测试成分...")
        ingredients = [
            {
                "name": "透明质酸钠",
                "aliases": ["玻尿酸", "Sodium Hyaluronate"],
                "description": "透明质酸钠是一种强效保湿成分，能够在皮肤表面形成保湿膜，减少水分流失。",
                "functions": ["保湿", "修复"],
                "safety_level": 95,
                "irritation_level": 5,
                "categories": ["保湿剂", "亲水性成分"],
                "suitable_skin_types": ["干性", "中性", "油性", "混合性", "敏感性"]
            },
            {
                "name": "烟酰胺",
                "aliases": ["维生素B3", "Niacinamide"],
                "description": "烟酰胺是一种多功能活性成分，具有调节皮脂分泌、提亮肤色、抗炎和增强皮肤屏障功能的作用。",
                "functions": ["调节皮脂", "美白", "抗炎", "强化屏障"],
                "safety_level": 90,
                "irritation_level": 10,
                "categories": ["维生素", "活性成分"],
                "suitable_skin_types": ["油性", "痘痘肌", "混合性", "敏感性"]
            },
            {
                "name": "视黄醇",
                "aliases": ["维生素A醇", "Retinol"],
                "description": "视黄醇是一种维生素A的衍生物，具有促进细胞更新、抗皱、抗衰老的作用。",
                "functions": ["抗皱", "抗衰老", "促进细胞更新"],
                "safety_level": 70,
                "irritation_level": 40,
                "categories": ["维生素", "抗衰老成分"],
                "suitable_skin_types": ["中性", "油性", "抗衰老需求的皮肤"]
            }
        ]
        
        db.ingredients.insert_many(ingredients)
    
    print("测试数据添加完成!")

if __name__ == "__main__":
    init_db() 