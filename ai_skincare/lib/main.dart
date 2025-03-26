import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/routes.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI护肤顾问',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('en', 'US'),
      defaultTransition: Transition.cupertino,
    );
  }
}
