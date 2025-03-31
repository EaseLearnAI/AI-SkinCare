from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from bson import ObjectId

class User:
    """用户数据模型"""
    
    def __init__(self, id, username, email, password_hash=None, 
                 phone_number=None, avatar_url=None, skin_type=None, 
                 skin_concerns=None, favorites=None, created_at=None, updated_at=None):
        self.id = str(id)
        self.username = username
        self.email = email
        self.password_hash = password_hash
        self.phone_number = phone_number
        self.avatar_url = avatar_url
        self.skin_type = skin_type
        self.skin_concerns = skin_concerns or []
        self.favorites = favorites or []
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
        
    def check_password(self, password):
        """验证密码"""
        return check_password_hash(self.password_hash, password)
        
    def to_dict(self):
        """将用户对象转换为字典"""
        return {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "phoneNumber": self.phone_number,
            "avatarUrl": self.avatar_url,
            "skinType": self.skin_type,
            "skinConcerns": self.skin_concerns,
            "favorites": self.favorites,
            "createdAt": self.created_at.isoformat() if self.created_at else None,
            "updatedAt": self.updated_at.isoformat() if self.updated_at else None
        }
    
    @classmethod
    def from_dict(cls, data):
        """从字典创建用户对象"""
        return cls(
            id=data.get('_id'),
            username=data.get('username'),
            email=data.get('email'),
            password_hash=data.get('password_hash'),
            phone_number=data.get('phone_number'),
            avatar_url=data.get('avatar_url'),
            skin_type=data.get('skin_type'),
            skin_concerns=data.get('skin_concerns'),
            favorites=data.get('favorites'),
            created_at=data.get('created_at'),
            updated_at=data.get('updated_at')
        )
    
    @classmethod
    def create_user(cls, db, username, email, password, phone_number=None):
        """创建新用户"""
        # 检查邮箱是否已存在
        if db.users.find_one({"email": email}):
            return None
            
        # 检查用户名是否已存在
        if db.users.find_one({"username": username}):
            return None
            
        now = datetime.utcnow()
        user_data = {
            "username": username,
            "email": email,
            "password_hash": generate_password_hash(password),
            "phone_number": phone_number,
            "avatar_url": None,
            "skin_type": None,
            "skin_concerns": [],
            "favorites": [],
            "created_at": now,
            "updated_at": now
        }
        
        result = db.users.insert_one(user_data)
        user_data['_id'] = result.inserted_id
        
        return cls.from_dict(user_data)
    
    @classmethod
    def find_by_id(cls, db, user_id):
        """根据ID查找用户"""
        try:
            user_data = db.users.find_one({"_id": ObjectId(user_id)})
            if user_data:
                return cls.from_dict(user_data)
            return None
        except:
            return None
    
    @classmethod
    def find_by_email(cls, db, email):
        """根据邮箱查找用户"""
        user_data = db.users.find_one({"email": email})
        if user_data:
            return cls.from_dict(user_data)
        return None
        
    @classmethod
    def find_by_username(cls, db, username):
        """根据用户名查找用户"""
        user_data = db.users.find_one({"username": username})
        if user_data:
            return cls.from_dict(user_data)
        return None
        
    def update(self, db, username=None, avatar_url=None, skin_type=None, skin_concerns=None):
        """更新用户信息"""
        update_data = {"updated_at": datetime.utcnow()}
        
        if username is not None:
            update_data["username"] = username
        if avatar_url is not None:
            update_data["avatar_url"] = avatar_url
        if skin_type is not None:
            update_data["skin_type"] = skin_type
        if skin_concerns is not None:
            update_data["skin_concerns"] = skin_concerns
        
        db.users.update_one(
            {"_id": ObjectId(self.id)},
            {"$set": update_data}
        )
        
        # 更新当前对象
        for key, value in update_data.items():
            setattr(self, key, value)
            
        return self
        
    def add_favorite(self, db, product_id):
        """添加收藏产品"""
        if product_id not in self.favorites:
            self.favorites.append(product_id)
            db.users.update_one(
                {"_id": ObjectId(self.id)},
                {
                    "$push": {"favorites": product_id},
                    "$set": {"updated_at": datetime.utcnow()}
                }
            )
        return self
        
    def remove_favorite(self, db, product_id):
        """移除收藏产品"""
        if product_id in self.favorites:
            self.favorites.remove(product_id)
            db.users.update_one(
                {"_id": ObjectId(self.id)},
                {
                    "$pull": {"favorites": product_id},
                    "$set": {"updated_at": datetime.utcnow()}
                }
            )
        return self
        
    def change_password(self, db, password):
        """修改密码"""
        password_hash = generate_password_hash(password)
        db.users.update_one(
            {"_id": ObjectId(self.id)},
            {
                "$set": {
                    "password_hash": password_hash,
                    "updated_at": datetime.utcnow()
                }
            }
        )
        self.password_hash = password_hash
        return self 