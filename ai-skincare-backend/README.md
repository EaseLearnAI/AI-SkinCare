# AI 皮肤护理 API 后端

这是 AI 皮肤护理应用的后端 API，使用 Flask 框架和 MongoDB 数据库构建。

## 功能特点

- 用户认证（注册、登录、个人资料管理）
- 皮肤分析（上传图片进行肤质分析）
- 产品管理（创建、查看、更新用户的护肤产品）
- 产品分析（扫描产品图片、分析成分）
- 成分查询和分析
- 产品和成分的冲突检测
- 护肤流程顺序建议

## 技术栈

- **后端框架**: Flask
- **数据库**: MongoDB
- **认证**: JWT (JSON Web Tokens)
- **图像处理**: 模拟实现（可扩展为实际的机器学习模型）
- **API规范**: RESTful API

## 安装和设置

### 前提条件

- Python 3.7+
- MongoDB 4.0+
- pip（Python 包管理器）

### 步骤

1. 克隆仓库

```bash
git clone <repository-url>
cd ai-skincare-backend
```

2. 创建并激活虚拟环境

```bash
# 创建虚拟环境
python -m venv venv

# 激活虚拟环境 (Windows)
venv\Scripts\activate

# 激活虚拟环境 (macOS/Linux)
source venv/bin/activate
```

3. 安装依赖

```bash
pip install -r requirements.txt
```

4. 配置环境变量

```bash
# 复制环境变量示例文件
cp .env.example .env

# 编辑 .env 文件，设置自己的配置
```

5. 初始化数据库

```bash
# 初始化数据库集合和索引
python init_db.py

# 可选：添加测试数据
python init_db.py --with-sample-data
```

6. 创建上传目录

```bash
mkdir -p uploads/products uploads/skin_analysis uploads/temp
```

## 运行应用

### 开发环境

```bash
# 使用脚本运行（推荐）
# Windows
run.ps1

# macOS/Linux
./run.sh

# 或者手动运行
export FLASK_APP=app.py
export FLASK_ENV=development
flask run
```

应用将在 http://localhost:5000 上运行

### 生产环境

在生产环境中，建议使用 Gunicorn 或 uWSGI 作为 WSGI 服务器运行应用，并使用 Nginx 作为反向代理。

```bash
# 使用 Gunicorn 示例
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## API 文档

运行应用后，可以访问以下端点查看 API 文档：

```
http://localhost:5000/api/docs
```

### 主要 API 端点

| 路径 | 方法 | 描述 |
|------|------|------|
| `/api/auth/register` | POST | 用户注册 |
| `/api/auth/login` | POST | 用户登录 |
| `/api/auth/me` | GET | 获取当前用户信息 |
| `/api/auth/profile` | GET/PUT | 获取/更新用户资料 |
| `/api/user/products` | GET/POST | 获取/创建用户产品 |
| `/api/user/products/<id>` | GET/PUT/DELETE | 获取/更新/删除特定产品 |
| `/api/product-analysis/scan` | POST | 扫描产品图片进行分析 |
| `/api/product-analysis/search` | GET | 搜索产品 |
| `/api/skin-analysis/detect` | POST | 上传皮肤图片进行分析 |
| `/api/skin-analysis/history` | GET | 获取皮肤分析历史 |
| `/api/ingredients/search` | GET | 搜索成分 |
| `/api/ingredients/<id>` | GET | 获取成分详情 |
| `/api/conflict/ingredients` | POST | 检查成分冲突 |
| `/api/conflict/products` | POST | 检查产品冲突 |
| `/api/conflict/routines` | POST | 分析护肤流程 |

## 目录结构

```
ai-skincare-backend/
├── app.py                  # 应用入口
├── init_db.py              # 数据库初始化脚本
├── requirements.txt        # 项目依赖
├── run.ps1                 # Windows运行脚本
├── run.sh                  # Unix运行脚本
├── .env.example            # 环境变量示例
├── routes/                 # API路由
│   ├── auth.py             # 认证相关路由
│   ├── user_products.py    # 用户产品路由
│   ├── product_analysis.py # 产品分析路由
│   ├── skin_analysis.py    # 皮肤分析路由
│   ├── ingredients.py      # 成分相关路由
│   └── conflicts.py        # 冲突检测路由
├── models/                 # 数据模型
│   ├── user.py             # 用户模型
│   └── product.py          # 产品模型
└── uploads/                # 文件上传目录
    ├── products/           # 产品图片
    ├── skin_analysis/      # 皮肤分析图片
    └── temp/               # 临时文件
```

## 接口示例

### 用户注册

```
POST /api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}
```

### 用户登录

```
POST /api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

### 分析皮肤

```
POST /api/skin-analysis/detect
Content-Type: multipart/form-data

image: [image file]
```

## 贡献与开发

1. Fork 此仓库
2. 创建你的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启一个 Pull Request

## 许可证

此项目采用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 联系方式

如有问题或建议，请通过 [issues](link-to-issues) 联系我们。 