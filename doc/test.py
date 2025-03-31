from pymongo import MongoClient
import logging
from pprint import pprint  # 用于美化输出

logging.basicConfig(level=logging.INFO)

def inspect_database(client, db_name):
    """查看指定数据库的所有集合及示例文档"""
    try:
        db = client[db_name]
        collections = db.list_collection_names()
        logging.info(f"数据库 '{db_name}' 中的集合: {collections}")

        for collection_name in collections:
            print(f"\n=== 集合: {collection_name} ===")
            # 获取集合的第一条文档作为示例
            doc = db[collection_name].find_one()
            if doc:
                pprint(doc)
            else:
                print("集合为空")
        return True
    except Exception as e:
        logging.error(f"查询数据库失败: {str(e)}")
        return False

def test_mongo_connection(uri="mongodb://localhost:27017/"):
    try:
        client = MongoClient(uri)
        
        # 获取数据库列表
        db_names = client.list_database_names()
        logging.info(f"成功连接到 MongoDB！数据库列表: {db_names}")

        # 检查特定数据库内容
        target_db = "ai_skincare"
        if target_db in db_names:
            inspect_database(client, target_db)
        else:
            logging.warning(f"数据库 '{target_db}' 不存在")

        return True
    except Exception as e:
        logging.error(f"连接失败: {str(e)}")
        return False

if __name__ == "__main__":
    test_mongo_connection()