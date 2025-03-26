# AI 肌肤检测应用程序 API 文档

## 概述

本文档详细描述了AI肌肤检测应用程序的后端API接口。该应用程序提供肌肤分析、产品分析、成分冲突检测等功能，所有API均基于RESTful架构设计，返回JSON格式数据。

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
    "concerns": ["干燥", "敏感"],
    "favorites": ["产品ID列表"],
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
  - `quizData`: 问卷数据JSON字符串（可选）
- **响应**:
```json
{
  "success": true,
  "data": {
    "analysisId": "分析记录ID",
    "status": "completed",
    "results": {
      "hydration": {
        "value": 75,
        "status": "皮肤水分充足，继续保持喵～",
        "trend": "+5%",
        "trendUp": true
      },
      "oil": {
        "value": 60,
        "status": "T区油分略偏高，建议使用控油产品喵～"
      },
      "sensitivity": {
        "value": 2,
        "maxValue": 5,
        "status": "轻度敏感，建议使用温和产品喵～"
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
    "recommendations": [
      {
        "id": "推荐ID",
        "title": "加强保湿防护",
        "description": "建议使用含玻尿酸的保湿精华，提升肌肤水润度",
        "iconType": "shield",
        "priority": "高",
        "timing": "建议立即使用",
        "recommendedProducts": ["产品ID列表"]
      },
      {
        "id": "推荐ID",
        "title": "防晒提醒",
        "description": "今日紫外线较强，记得涂防晒喵～",
        "iconType": "sun",
        "priority": "中",
        "timing": "外出前使用"
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

#### 4.1 扫描产品

- **URL**: `/product-analysis/scan`
- **方法**: `POST`
- **描述**: 上传产品图片进行识别和分析
- **请求体**: 
  - `Content-Type: multipart/form-data`
  - `image`: 产品图片文件
- **响应**:
```json
{
  "success": true,
  "data": {
    "analysisId": "分析记录ID",
    "status": "completed",
    "product": {
      "id": "产品ID",
      "name": "产品名称",
      "brand": "品牌名称",
      "category": "产品类别",
      "imageUrl": "产品图片URL",
      "description": "产品描述"
    },
    "ingredients": [
      {
        "id": "成分ID",
        "name": "成分名称",
        "function": "成分功效",
        "safetyLevel": 1,
        "irritationRisk": "低",
        "acneRisk": "低",
        "description": "成分描述"
      }
    ],
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

#### 4.2 搜索产品

- **URL**: `/products/search`
- **方法**: `GET`
- **描述**: 搜索产品数据库
- **请求参数**:
  - `query`: 搜索关键词
  - `category`: 产品类别（可选）
  - `brand`: 品牌（可选）
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
        "brand": "品牌名称",
        "category": "产品类别",
        "imageUrl": "产品图片URL",
        "rating": 4.5,
        "reviewCount": 120
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
    "brand": "品牌名称",
    "category": "产品类别",
    "subCategory": "产品子类别",
    "imageUrl": "产品图片URL",
    "description": "产品描述",
    "price": 299.00,
    "currency": "CNY",
    "size": "50ml",
    "rating": 4.5,
    "reviewCount": 120,
    "ingredients": [
      {
        "id": "成分ID",
        "name": "成分名称",
        "function": "成分功效",
        "safetyLevel": 1,
        "irritationRisk": "低",
        "acneRisk": "低"
      }
    ],
    "analysis": {
      "safetyScore": 85,
      "effectivenessScore": 90,
      "suitabilityScore": 75,
      "goodFor": ["干性肌肤", "缺水肌肤"],
      "notRecommendedFor": ["油性肌肤"]
    },
    "reviews": [
      {
        "id": "评论ID",
        "userId": "用户ID",
        "username": "用户名",
        "rating": 5,
        "content": "评论内容",
        "createdAt": "评论时间"
      }
    ]
  }
}
```

### 5. 成分分析

#### 5.1 成分详情

- **URL**: `/ingredients/{ingredientId}`
- **方法**: `GET`
- **描述**: 获取成分详细信息
- **请求参数**:
  - `ingredientId`: 成分ID
- **响应**:
```json
{
  "success": true,
  "data": {
    "id": "成分ID",
    "name": "成分名称",
    "alias": ["别名1", "别名2"],
    "engName": "英文名称",
    "casNumber": "CAS号",
    "category": "成分类别",
    "function": "主要功效",
    "description": "详细描述",
    "safetyLevel": 1,
    "safetyDescription": "安全等级描述",
    "irritationRisk": "低",
    "acneRisk": "低",
    "allergicRisk": "低",
    "pregnancySafe": true,
    "researchPapers": ["研究论文引用"],
    "suitableSkinTypes": ["适合的肌肤类型"],
    "notSuitableSkinTypes": ["不适合的肌肤类型"],
    "commonProducts": [
      {
        "id": "产品ID",
        "name": "产品名称",
        "brand": "品牌名称",
        "imageUrl": "产品图片URL"
      }
    ]
  }
}
```

#### 5.2 成分搜索

- **URL**: `/ingredients/search`
- **方法**: `GET`
- **描述**: 搜索成分数据库
- **请求参数**:
  - `query`: 搜索关键词
  - `category`: 成分类别（可选）
  - `function`: 成分功效（可选）
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
        "id": "成分ID",
        "name": "成分名称",
        "engName": "英文名称",
        "function": "主要功效",
        "safetyLevel": 1,
        "irritationRisk": "低"
      }
    ]
  }
}
```

### 6. 成分冲突检测

#### 6.1 检测成分冲突

- **URL**: `/conflict-detection/check`
- **方法**: `POST`
- **描述**: 检测多个成分之间可能存在的冲突
- **请求体**:
```json
{
  "ingredientIds": ["成分ID列表"]
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
            "id": "成分1ID",
            "name": "成分1名称"
          },
          {
            "id": "成分2ID",
            "name": "成分2名称"
          }
        ],
        "level": "severe",
        "description": "这两种成分不应同时使用，可能导致肌肤刺激",
        "recommendations": [
          "建议在不同的护肤步骤中使用",
          "至少间隔30分钟使用"
        ]
      }
    ],
    "compatibleGroups": [
      ["兼容成分组合"]
    ],
    "usageSuggestion": "建议使用顺序和方法"
  }
}
```

#### 6.2 检测产品冲突

- **URL**: `/conflict-detection/products`
- **方法**: `POST`
- **描述**: 检测多个产品之间可能存在的成分冲突
- **请求体**:
```json
{
  "productIds": ["产品ID列表"]
}
```
- **响应**: 与6.1类似，但包含产品信息

### 7. 护肤日记

#### 7.1 创建护肤日记

- **URL**: `/skincare-diary`
- **方法**: `POST`
- **描述**: 创建一条护肤日记记录
- **请求体**:
```json
{
  "date": "日期",
  "skinCondition": "肌肤状况",
  "products": [
    {
      "productId": "产品ID",
      "usageTime": "使用时间",
      "step": "护肤步骤",
      "notes": "使用备注"
    }
  ],
  "notes": "整体备注",
  "images": ["图片URL数组"],
  "mood": "心情",
  "weather": "天气"
}
```
- **响应**:
```json
{
  "success": true,
  "data": {
    "id": "日记ID",
    "date": "日期",
    "skinCondition": "肌肤状况",
    "products": [
      {
        "product": {
          "id": "产品ID",
          "name": "产品名称",
          "brand": "品牌名称",
          "imageUrl": "产品图片URL"
        },
        "usageTime": "使用时间",
        "step": "护肤步骤",
        "notes": "使用备注"
      }
    ],
    "notes": "整体备注",
    "images": ["图片URL数组"],
    "mood": "心情",
    "weather": "天气",
    "createdAt": "创建时间"
  }
}
```

#### 7.2 获取护肤日记列表

- **URL**: `/skincare-diary`
- **方法**: `GET`
- **描述**: 获取用户的护肤日记列表
- **请求参数**:
  - `month`: 月份（格式：YYYY-MM，可选）
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
        "id": "日记ID",
        "date": "日期",
        "skinCondition": "肌肤状况",
        "productCount": 产品数量,
        "hasImages": true/false,
        "mood": "心情",
        "createdAt": "创建时间"
      }
    ]
  }
}
```

### 8. 文章和资讯

#### 8.1 获取文章列表

- **URL**: `/articles`
- **方法**: `GET`
- **描述**: 获取护肤知识文章列表
- **请求参数**:
  - `category`: 文章类别（可选）
  - `tag`: 文章标签（可选）
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
        "id": "文章ID",
        "title": "文章标题",
        "summary": "文章摘要",
        "author": "作者",
        "category": "文章类别",
        "tags": ["标签1", "标签2"],
        "coverImageUrl": "封面图片URL",
        "publishedAt": "发布时间",
        "readCount": 阅读量
      }
    ]
  }
}
```

#### 8.2 获取文章详情

- **URL**: `/articles/{articleId}`
- **方法**: `GET`
- **描述**: 获取文章详细内容
- **请求参数**:
  - `articleId`: 文章ID
- **响应**:
```json
{
  "success": true,
  "data": {
    "id": "文章ID",
    "title": "文章标题",
    "content": "文章内容（HTML格式）",
    "author": {
      "id": "作者ID",
      "name": "作者名称",
      "avatarUrl": "作者头像URL",
      "title": "作者头衔"
    },
    "category": "文章类别",
    "tags": ["标签1", "标签2"],
    "coverImageUrl": "封面图片URL",
    "images": ["文章图片URL数组"],
    "publishedAt": "发布时间",
    "readCount": 阅读量,
    "relatedArticles": [
      {
        "id": "相关文章ID",
        "title": "相关文章标题",
        "coverImageUrl": "封面图片URL"
      }
    ],
    "relatedProducts": [
      {
        "id": "相关产品ID",
        "name": "相关产品名称",
        "imageUrl": "产品图片URL"
      }
    ]
  }
}
```

### 9. 天气与护肤建议

#### 9.1 获取当前位置天气和护肤建议

- **URL**: `/weather-advice`
- **方法**: `GET`
- **描述**: 根据用户位置获取天气信息和相应的护肤建议
- **请求参数**:
  - `latitude`: 纬度（可选，默认使用上次位置）
  - `longitude`: 经度（可选，默认使用上次位置）
- **响应**:
```json
{
  "success": true,
  "data": {
    "location": {
      "city": "城市名称",
      "district": "区域名称"
    },
    "weather": {
      "condition": "晴",
      "temperature": 26,
      "humidity": 60,
      "windSpeed": 3.4,
      "uvIndex": 7,
      "pm25": 35,
      "airQuality": "良好"
    },
    "advice": {
      "summary": "今日紫外线较强，注意防晒",
      "detail": "详细建议内容",
      "emphasisPoints": [
        {
          "title": "防晒",
          "description": "建议使用SPF50+防晒霜"
        },
        {
          "title": "补水",
          "description": "随身携带喷雾补水"
        }
      ],
      "recommendedProducts": [
        {
          "id": "产品ID",
          "name": "产品名称",
          "brand": "品牌名称",
          "imageUrl": "产品图片URL",
          "category": "产品类别"
        }
      ]
    }
  }
}
```

## 数据模型

### 用户模型 (User)

```json
{
  "id": "用户ID",
  "username": "用户名",
  "email": "邮箱地址",
  "phoneNumber": "手机号码",
  "avatarUrl": "头像URL",
  "password": "加密密码（不返回给客户端）",
  "skinType": "肌肤类型",
  "concerns": ["肌肤问题列表"],
  "favorites": ["收藏的产品ID列表"],
  "createdAt": "创建时间",
  "updatedAt": "更新时间",
  "lastLoginAt": "最后登录时间"
}
```

### 肌肤分析记录模型 (SkinAnalysis)

```json
{
  "id": "分析记录ID",
  "userId": "用户ID",
  "imageUrl": "原始图片URL",
  "thumbnailUrl": "缩略图URL",
  "quizData": {
    "skinType": "问卷回答的肌肤类型",
    "concerns": ["问卷回答的肌肤问题"],
    "sensitivity": "问卷回答的敏感程度"
  },
  "results": {
    "hydration": { "value": 75, "status": "状态描述", "trend": "+5%", "trendUp": true },
    "oil": { "value": 60, "status": "状态描述" },
    "sensitivity": { "value": 2, "maxValue": 5, "status": "状态描述" },
    "pores": { "value": 30, "status": "状态描述" },
    "wrinkles": { "value": 15, "status": "状态描述" },
    "pigmentation": { "value": 25, "status": "状态描述" }
  },
  "recommendations": [
    {
      "id": "推荐ID",
      "title": "推荐标题",
      "description": "推荐描述",
      "iconType": "图标类型",
      "priority": "优先级",
      "timing": "使用时机",
      "recommendedProducts": ["推荐产品ID列表"]
    }
  ],
  "createdAt": "创建时间"
}
```

### 产品模型 (Product)

```json
{
  "id": "产品ID",
  "name": "产品名称",
  "brand": "品牌名称",
  "category": "产品类别",
  "subCategory": "产品子类别",
  "imageUrl": "产品图片URL",
  "description": "产品描述",
  "price": 299.00,
  "currency": "CNY",
  "size": "50ml",
  "ingredients": ["成分ID列表"],
  "rating": 4.5,
  "reviewCount": 120,
  "analysis": {
    "safetyScore": 85,
    "effectivenessScore": 90,
    "suitabilityScore": 75,
    "goodFor": ["适合的肌肤类型"],
    "notRecommendedFor": ["不推荐的肌肤类型"]
  },
  "createdAt": "创建时间",
  "updatedAt": "更新时间"
}
```

### 成分模型 (Ingredient)

```json
{
  "id": "成分ID",
  "name": "成分名称",
  "alias": ["别名列表"],
  "engName": "英文名称",
  "casNumber": "CAS号",
  "category": "成分类别",
  "function": "主要功效",
  "description": "详细描述",
  "safetyLevel": 1,
  "safetyDescription": "安全等级描述",
  "irritationRisk": "刺激风险",
  "acneRisk": "痘痘风险",
  "allergicRisk": "过敏风险",
  "pregnancySafe": true,
  "researchPapers": ["研究论文引用"],
  "suitableSkinTypes": ["适合的肌肤类型"],
  "notSuitableSkinTypes": ["不适合的肌肤类型"],
  "createdAt": "创建时间",
  "updatedAt": "更新时间"
}
```

### 成分冲突模型 (IngredientConflict)

```json
{
  "id": "冲突ID",
  "ingredientPair": ["成分ID对"],
  "level": "冲突等级",
  "description": "冲突描述",
  "recommendations": ["建议列表"],
  "source": "数据来源",
  "createdAt": "创建时间",
  "updatedAt": "更新时间"
}
```

### 护肤日记模型 (SkincareDiary)

```json
{
  "id": "日记ID",
  "userId": "用户ID",
  "date": "日期",
  "skinCondition": "肌肤状况",
  "products": [
    {
      "productId": "产品ID",
      "usageTime": "使用时间",
      "step": "护肤步骤",
      "notes": "使用备注"
    }
  ],
  "notes": "整体备注",
  "images": ["图片URL数组"],
  "mood": "心情",
  "weather": "天气",
  "createdAt": "创建时间",
  "updatedAt": "更新时间"
}
```

### 文章模型 (Article)

```json
{
  "id": "文章ID",
  "title": "文章标题",
  "summary": "文章摘要",
  "content": "文章内容（HTML格式）",
  "authorId": "作者ID",
  "category": "文章类别",
  "tags": ["标签列表"],
  "coverImageUrl": "封面图片URL",
  "images": ["文章图片URL数组"],
  "publishedAt": "发布时间",
  "readCount": 阅读量,
  "relatedArticles": ["相关文章ID列表"],
  "relatedProducts": ["相关产品ID列表"],
  "createdAt": "创建时间",
  "updatedAt": "更新时间"
}
```

## 安全与性能考虑

1. 所有API请求使用HTTPS加密传输
2. 所有密码使用bcrypt加密存储
3. 用户认证采用JWT令牌，有效期为24小时
4. 针对图片上传接口，限制文件大小不超过10MB
5. 所有API均实现了限流保护，默认每IP每分钟不超过60次请求
6. 敏感数据（如用户肌肤分析记录）采用额外加密存储
7. 图片分析结果缓存24小时，减少重复分析
8. 针对热门产品和成分信息进行CDN缓存，提升响应速度 