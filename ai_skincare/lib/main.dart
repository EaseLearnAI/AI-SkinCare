import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/routes.dart';
import 'themes/app_theme.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 确定初始路由
  String initialRoute = AppRoutes.login;

  // 检查用户是否已登录，如果已登录则直接进入首页
  if (await StorageService.isLoggedIn()) {
    initialRoute = AppRoutes.home;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI护肤助手',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}
