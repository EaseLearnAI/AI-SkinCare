# AI 肌肤检测 App

![App Logo](ai_skincare/assets/images/logo.png)

一款基于AI技术的肌肤分析和护肤产品推荐应用。

## 功能特点

- **肌肤分析**: 通过摄像头拍摄或上传照片，AI技术实时分析肌肤状况
- **产品分析**: 扫描或上传产品图片，智能识别成分并分析安全性
- **成分冲突检测**: 检测多种护肤品之间可能存在的成分冲突
- **个性化推荐**: 根据肌肤状况提供个性化的产品和护理建议
- **护肤日记**: 记录每日肌肤状态和护肤产品使用情况
- **天气建议**: 根据当地天气情况提供相应的护肤建议

## 技术架构

- **前端框架**: Flutter
- **状态管理**: GetX
- **网络请求**: HTTP/Dio
- **本地存储**: Shared Preferences
- **后端API**: RESTful API
- **AI模型**: 基于深度学习的肌肤分析和图像识别模型

## 项目结构

```
ai_skincare/
├── lib/
│   ├── config/           # 配置文件
│   ├── models/           # 数据模型
│   ├── screens/          # 页面UI
│   ├── services/         # 服务层
│   ├── themes/           # 主题配置
│   ├── utils/            # 工具函数
│   ├── widgets/          # 可复用组件
│   └── main.dart         # 应用入口
├── assets/               # 静态资源
│   ├── images/           # 图片资源
│   ├── icons/            # 图标资源
│   ├── animations/       # 动画资源
│   └── fonts/            # 字体资源
└── test/                 # 测试文件
```

## API 文档

详细的API文档请查看 [api_documentation.md](api_documentation.md)

## 安装运行

### 环境要求

- Flutter SDK: 3.7.2 或更高
- Dart SDK: 3.0.0 或更高
- Android Studio / VS Code
- Android SDK / Xcode

### 安装步骤

1. 克隆项目
   ```
   git clone https://github.com/your-username/ai-skincare.git
   ```

2. 安装依赖
   ```
   cd ai-skincare
   flutter pub get
   ```

3. 运行应用
   ```
   flutter run
   ```

## 设计稿和原型

项目设计稿和原型文件位于 `prototype/` 目录下，包括:
- 页面布局设计
- 交互流程图
- 色彩规范
- 组件库

## 开发团队

- 产品经理: [姓名]
- UI/UX设计: [姓名]
- 前端开发: [姓名]
- 后端开发: [姓名]
- AI工程师: [姓名]

## 开源协议

本项目采用 [MIT 协议](LICENSE)。 