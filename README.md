# AI-SkinCare 应用

AI-SkinCare 是一个使用人工智能为用户提供肌肤分析和护肤品推荐的应用程序。该应用包含前端（Flutter）和后端（Python Flask）两部分。

## 项目结构

```
AI-SkinCare/
├── ai_skincare/          # Flutter 前端应用
└── ai-skincare-backend/  # Python Flask 后端服务
```

## 功能特性

- 用户认证（登录/注册）
- 肌肤分析（通过上传照片）
- 产品分析（通过扫描产品或上传产品图片）
- 用户产品库管理
- 产品成分冲突检测
- 个性化护肤建议

## 前端设置（Flutter）

### 先决条件

- Flutter SDK (2.0 或更高版本)
- Dart SDK
- Android Studio 或 Visual Studio Code
- Android SDK 或 iOS SDK (取决于您的目标平台)

### 安装步骤

1. 确保您已安装 Flutter SDK 并配置好环境。可以通过运行 `flutter doctor` 来验证。
2. 克隆此仓库：
   ```
   git clone https://github.com/yourusername/AI-SkinCare.git
   cd AI-SkinCare/ai_skincare
   ```
3. 获取依赖：
   ```
   flutter pub get
   ```
4. 运行应用：
   ```
   flutter run
   ```

## 后端设置（Python Flask）

### 先决条件

- Python 3.8+
- MongoDB
- pip

### 安装步骤

1. 切换到后端目录：
   ```
   cd ai-skincare-backend
   ```

2. 运行安装脚本：
   ```
   bash install.sh
   ```
   这将自动设置虚拟环境、安装依赖，并创建必要的目录。

3. 配置环境变量：
   编辑 `.env` 文件，根据您的环境设置以下变量：
   ```
   MONGO_URI=mongodb://localhost:27017/
   MONGO_DB=ai_skincare
   JWT_SECRET_KEY=your_secret_key
   ```

4. 启动服务器：
   ```
   bash run.sh
   ```
   服务器将在 http://localhost:5000 上运行。

## API 文档

后端 API 文档位于 `ai-skincare-backend/API_DOCUMENTATION.md`，其中详细描述了所有可用的 API 端点、请求参数和响应格式。

## 常见问题

### 前端无法连接到后端？

确保后端服务器正在运行，并检查 `ai_skincare/lib/services/api_service.dart` 中的 `baseUrl` 是否正确。默认为 `http://localhost:5000/api`。

### MongoDB 连接问题？

确保 MongoDB 服务正在运行。您可以通过以下命令检查：
- Windows: 检查 MongoDB 服务是否在服务管理器中运行
- Mac/Linux: 运行 `ps aux | grep mongod`

### 登录页面未显示？

检查 `AppRoutes.login` 是否正确配置，以及 `StorageService.isLoggedIn()` 方法是否正常工作。

## 贡献指南

1. Fork 这个仓库
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建一个 Pull Request

## 许可证

这个项目采用 MIT 许可证 - 详情请参阅 [LICENSE](LICENSE) 文件。

## 联系方式

如有问题，请通过 [issues](https://github.com/yourusername/AI-SkinCare/issues) 页面与我们联系。 