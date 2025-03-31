# AI 肌肤检测应用程序 API 文档

## 概述

本文档详细描述了AI肌肤检测应用程序的后端API接口。该应用程序提供肌肤分析、产品分析、成分冲突检测等功能，所有API均基于RESTful架构设计，返回JSON格式数据。该后端使用Python Flask框架实现，数据存储使用MongoDB。

## 基础信息

- 基础URL: `https://api.ai-skincare.com/v1`
- 认证方式: Bearer Token (JWT)
- 所有请求头需包含 `Content-Type: application/json`
- 所有请求头需包含 `Authorization: Bearer {token}`（除登录/注册接口外）

## 错误处理

所有API遵循统一的错误响应格式：

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述信息"
  }
}
```

常见错误码：
- `AUTHENTICATION_ERROR`: 认证失败
- `PERMISSION_DENIED`: 权限不足
- `RESOURCE_NOT_FOUND`: 资源不存在
- `VALIDATION_ERROR`: 请求参数验证失败
- `SERVER_ERROR`: 服务器内部错误
- `AI_SERVICE_ERROR`: AI服务调用失败

## API 端点

### 1. 用户认证

#### 1.1 用户注册

- **URL**: `/auth/register`
- **方法**: `POST`
- **描述**: 注册新用户
- **请求体**:
```json
{
  "username": "用户名",
  "email": "邮箱地址",
  "password": "密码",
  "phoneNumber": "手机号码"
}
```
- **响应**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "用户ID",
      "username": "用户名",
      "email": "邮箱地址",
      "avatarUrl": "头像URL",
      "createdAt": "创建时间"
    },
    "token": "JWT令牌"
  }
}
```

#### 1.2 用户登录

- **URL**: `/auth/login`
- **方法**: `POST`
- **描述**: 用户登录并获取认证令牌
- **请求体**:
```json
{
  "email": "邮箱地址",
  "password": "密码"
}
```
- **响应**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "用户ID",
      "username": "用户名",
      "email": "邮箱地址",
      "avatarUrl": "头像URL",
      "skinType": "肌肤类型",
      "lastLoginAt": "最后登录时间"
    },
    "token": "JWT令牌"
  }
}
```

### 2. 用户信息

#### 2.1 获取用户信息

- **URL**: `/users/me`
- **方法**: `GET`
- **描述**: 获取当前登录用户的详细信息
- **响应**:
```json
{
  "success": true,
  "data": {
    "id": "用户ID",
    "username": "用户名",
    "email": "邮箱地址",
    "phoneNumber": "手机号码",
    "avatarUrl": "头像URL",
    "skinType": "肌肤类型",
    "skinStatus": "肌肤状态",
    "skinAiSummary": "肌肤AI总结",
    "concerns": ["干燥", "敏感"],
    "favorites": ["产品ID列表"],
    "products": [
      {
        "id": "产品ID",
        "name": "产品名称",
        "ingredients": "产品成分",
        "aiSummary": "AI总结"
      }
    ],
    "createdAt": "创建时间",
    "lastLoginAt": "最后登录时间"
  }
}
```

#### 2.2 更新用户信息

- **URL**: `/users/me`
- **方法**: `PUT`
- **描述**: 更新当前用户的信息
- **请求体**:
```json
{
  "username": "新用户名",
  "avatarUrl": "新头像URL",
  "skinType": "新肌肤类型",
  "skinStatus": "新肌肤状态",
  "concerns": ["新肌肤问题列表"]
}
```
- **响应**:
```json
{
  "success": true,
  "data": {
    "id": "用户ID",
    "username": "更新后的用户名",
    "email": "邮箱地址",
    "avatarUrl": "更新后的头像URL",
    "skinType": "更新后的肌肤类型",
    "skinStatus": "更新后的肌肤状态",
    "concerns": ["更新后的肌肤问题列表"],
    "updatedAt": "更新时间"
  }
}
```

### 3. 肌肤分析

#### 3.1 上传图片分析

- **URL**: `/skin-analysis/detect`
- **方法**: `POST`
- **描述**: 上传肌肤照片进行AI分析
- **请求体**: 
  - `Content-Type: multipart/form-data`
  - `image`: 图片文件
  - `skinStatus` (可选): 用户描述的肌肤状态
- **响应**:
```json
{
  "success": true,
  "data": {
    "analysisId": "分析记录ID",
    "imageUrl": "分析图片URL",
    "thumbnailUrl": "缩略图URL",
    "status": "completed",
    "results": {
      "hydration": {
        "value": 75,
        "status": "皮肤水分充足"
      },
      "oil": {
        "value": 60,
        "status": "T区油分略偏高，建议使用控油产品"
      },
      "sensitivity": {
        "value": 2,
        "maxValue": 5,
        "status": "轻度敏感，建议使用温和产品"
      },
      "pores": {
        "value": 30,
        "status": "毛孔状况良好"
      },
      "wrinkles": {
        "value": 15,
        "status": "几乎无细纹"
      },
      "pigmentation": {
        "value": 25,
        "status": "轻微色素沉着"
      }
    },
    "skinAiSummary": "AI生成的肌肤状态总结和护理建议",
    "recommendations": [
      {
        "id": "推荐ID",
        "title": "加强保湿防护",
        "description": "建议使用含玻尿酸的保湿精华，提升肌肤水润度",
        "iconType": "shield",
        "priority": "高",
        "timing": "建议立即使用",
        "recommendedProducts": ["产品ID列表"]
      }
    ],
    "createdAt": "创建时间"
  }
}
```

#### 3.2 获取分析历史

- **URL**: `/skin-analysis/history`
- **方法**: `GET`
- **描述**: 获取用户的肌肤分析历史记录
- **请求参数**:
  - `page`: 页码（默认1）
  - `limit`: 每页数量（默认10）
- **响应**:
```json
{
  "success": true,
  "data": {
    "total": 总记录数,
    "pages": 总页数,
    "current": 当前页码,
    "records": [
      {
        "id": "分析记录ID",
        "thumbnailUrl": "分析图片缩略图URL",
        "skinAiSummary": "AI生成的肌肤状态总结摘要",
        "createdAt": "创建时间",
        "mainResults": {
          "hydration": 75,
          "oil": 60,
          "sensitivity": 2
        }
      }
    ]
  }
}
```

#### 3.3 获取单条分析详情

- **URL**: `/skin-analysis/{analysisId}`
- **方法**: `GET`
- **描述**: 获取某条肌肤分析的详细信息
- **请求参数**:
  - `analysisId`: 分析记录ID
- **响应**: 与3.1响应格式相同

### 4. 产品分析

#### 4.1 提交产品信息分析

- **URL**: `/product-analysis/analyze`
- **方法**: `POST`
- **描述**: 提交产品名称和成分信息进行AI分析
- **请求体**: 
```json
{
  "name": "产品名称",
  "ingredients": "产品成分列表文本",
  "skinType": "用户肌肤类型", 
  "skinStatus": "用户肌肤状态"
}
```
- **响应**:
```json
{
  "success": true,
  "data": {
    "productId": "产品ID",
    "name": "产品名称",
    "ingredients": "产品成分",
    "aiSummary": "AI分析生成的产品功效和潜在危害的总结",
    "analysis": {
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
          "description": "含有酒精，可能对敏感肌不友好"
        }
      ]
    },
    "createdAt": "创建时间"
  }
}
```

#### 4.2 获取用户产品列表

- **URL**: `/products/user`
- **方法**: `GET`
- **描述**: 获取用户添加的产品列表
- **请求参数**:
  - `page`: 页码（默认1）
  - `limit`: 每页数量（默认10）
- **响应**:
```json
{
  "success": true,
  "data": {
    "total": 总记录数,
    "pages": 总页数,
    "current": 当前页码,
    "records": [
      {
        "id": "产品ID",
        "name": "产品名称",
        "ingredients": "产品成分摘要（前30个字符）",
        "aiSummary": "AI分析摘要（前50个字符）",
        "safetyScore": 85,
        "createdAt": "创建时间"
      }
    ]
  }
}
```

#### 4.3 获取产品详情

- **URL**: `/products/{productId}`
- **方法**: `GET`
- **描述**: 获取产品详细信息
- **请求参数**:
  - `productId`: 产品ID
- **响应**:
```json
{
  "success": true,
  "data": {
    "id": "产品ID",
    "name": "产品名称",
    "ingredients": "产品完整成分列表",
    "aiSummary": "AI分析生成的产品功效和潜在危害的总结",
    "analysis": {
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
          "description": "含有酒精，可能对敏感肌不友好"
        }
      ]
    },
    "suitableFor": ["干性肌肤", "缺水肌肤"],
    "notSuitableFor": ["油性肌肤"],
    "createdAt": "创建时间",
    "updatedAt": "更新时间"
  }
}
```

### 5. 成分冲突检测

#### 5.1 检测产品冲突

- **URL**: `/conflict-detection/products`
- **方法**: `POST`
- **描述**: 检测多个产品之间可能存在的成分冲突
- **请求体**:
```json
{
  "productIds": ["产品ID列表"],
  "skinType": "用户肌肤类型",
  "skinStatus": "用户肌肤状态"
}
```
- **响应**:
```json
{
  "success": true,
  "data": {
    "conflicts": [
      {
        "productPair": [
          {
            "id": "产品1ID",
            "name": "产品1名称",
            "problematicIngredients": ["成分1", "成分2"]
          },
          {
            "id": "产品2ID",
            "name": "产品2名称",
            "problematicIngredients": ["成分3", "成分4"]
          }
        ],
        "level": "severe",
        "description": "这两种产品不应同时使用，可能导致肌肤刺激",
        "aiRecommendations": "AI生成的建议和解决方案"
      }
    ],
    "compatibleProducts": [
      ["兼容产品ID组合"]
    ],
    "usageSuggestion": "AI生成的使用顺序和方法建议",
    "createdAt": "创建时间"
  }
}
```

#### 5.2 提交成分检测冲突

- **URL**: `/conflict-detection/ingredients`
- **方法**: `POST`
- **描述**: 提交多组成分列表检测可能的冲突
- **请求体**:
```json
{
  "ingredientLists": [
    "成分列表1（文本格式，多个成分用逗号分隔）",
    "成分列表2（文本格式，多个成分用逗号分隔）"
  ],
  "skinType": "用户肌肤类型",
  "skinStatus": "用户肌肤状态"
}
```
- **响应**:
```json
{
  "success": true,
  "data": {
    "conflicts": [
      {
        "ingredientPair": [
          {
            "list": 0,
            "ingredients": ["成分1", "成分2"]
          },
          {
            "list": 1,
            "ingredients": ["成分3", "成分4"]
          }
        ],
        "level": "moderate",
        "description": "这些成分组合可能会降低彼此的功效",
        "aiRecommendations": "AI生成的建议和解决方案"
      }
    ],
    "compatibleGroups": [
      "这些成分可以安全地一起使用：成分5, 成分6, 成分7"
    ],
    "usageSuggestion": "AI生成的使用顺序和方法建议",
    "createdAt": "创建时间"
  }
}
```

## 数据模型

### 用户模型 (User)

```json
{
  "_id": "MongoDB ObjectId (作为用户ID)",
  "username": "用户名",
  "email": "邮箱地址",
  "password": "加密密码（bcrypt）",
  "phoneNumber": "手机号码",
  "avatarUrl": "头像URL",
  "skinType": "肌肤类型",
  "skinStatus": "肌肤状态",
  "skinAiSummary": "AI生成的肌肤状态总结",
  "concerns": ["肌肤问题列表"],
  "favorites": ["收藏的产品ID列表"],
  "products": [
    {
      "productId": "产品ID（引用Products集合）",
      "addedAt": "添加时间"
    }
  ],
  "created_at": "创建时间（ISODate）",
  "updated_at": "更新时间（ISODate）",
  "last_login_at": "最后登录时间（ISODate）"
}
```

### 肌肤分析记录模型 (SkinAnalysis)

```json
{
  "_id": "MongoDB ObjectId (作为分析记录ID)",
  "userId": "用户ID（引用Users集合）",
  "imageUrl": "原始图片URL",
  "thumbnailUrl": "缩略图URL",
  "skinStatus": "用户提供的肌肤状态描述",
  "results": {
    "hydration": { "value": 75, "status": "状态描述" },
    "oil": { "value": 60, "status": "状态描述" },
    "sensitivity": { "value": 2, "maxValue": 5, "status": "状态描述" },
    "pores": { "value": 30, "status": "状态描述" },
    "wrinkles": { "value": 15, "status": "状态描述" },
    "pigmentation": { "value": 25, "status": "状态描述" }
  },
  "skinAiSummary": "AI生成的肌肤状态总结和护理建议",
  "recommendations": [
    {
      "title": "推荐标题",
      "description": "推荐描述",
      "iconType": "图标类型",
      "priority": "优先级",
      "timing": "使用时机",
      "recommendedProducts": ["推荐产品ID列表"]
    }
  ],
  "aiPrompt": "发送给AI的提示文本（用于记录）",
  "aiResponse": "原始AI响应（用于记录和改进）",
  "created_at": "创建时间（ISODate）"
}
```

### 产品模型 (Product)

```json
{
  "_id": "MongoDB ObjectId (作为产品ID)",
  "userId": "添加该产品的用户ID（引用Users集合）",
  "name": "产品名称",
  "ingredients": "产品成分（原始文本）",
  "ingredientsList": ["解析后的成分列表"],
  "aiSummary": "AI生成的产品功效和潜在危害的总结",
  "analysis": {
    "safetyScore": 85,
    "effectivenessScore": 90,
    "suitabilityScore": 75,
    "highlights": [
      {
        "type": "good/warning",
        "description": "描述文本"
      }
    ]
  },
  "suitableFor": ["适合的肌肤类型"],
  "notSuitableFor": ["不推荐的肌肤类型"],
  "aiPrompt": "发送给AI的提示文本（用于记录）",
  "aiResponse": "原始AI响应（用于记录和改进）",
  "created_at": "创建时间（ISODate）",
  "updated_at": "更新时间（ISODate）"
}
```

### 冲突检测记录模型 (ConflictDetection)

```json
{
  "_id": "MongoDB ObjectId (作为冲突检测记录ID)",
  "userId": "用户ID（引用Users集合）",
  "type": "products/ingredients", 
  "inputs": {
    "products": ["产品ID列表"],
    "ingredientLists": ["成分列表（多组）"],
    "skinType": "用户肌肤类型",
    "skinStatus": "用户肌肤状态"
  },
  "conflicts": [
    {
      "items": ["冲突项目标识，可能是产品ID或成分列表索引"],
      "problematicItems": ["具体冲突的成分"],
      "level": "冲突等级（severe/moderate/mild）",
      "description": "冲突描述",
      "aiRecommendations": "AI建议"
    }
  ],
  "compatibleGroups": ["兼容项目组合"],
  "usageSuggestion": "使用建议",
  "aiPrompt": "发送给AI的提示文本（用于记录）",
  "aiResponse": "原始AI响应（用于记录和改进）",
  "created_at": "创建时间（ISODate）"
}
```

## 安全与性能考虑

1. 所有API请求使用HTTPS加密传输
2. 所有密码使用bcrypt加密存储 
3. 用户认证采用JWT令牌，有效期为24小时
4. 针对图片上传接口，限制文件大小不超过10MB
5. 所有API均实现了限流保护，默认每IP每分钟不超过60次请求
6. AI服务调用使用OpenAI API，失败时有重试机制
7. 针对热门产品和成分信息进行缓存，减少重复分析
8. 用户上传的图片和分析结果存储在安全的云存储中 