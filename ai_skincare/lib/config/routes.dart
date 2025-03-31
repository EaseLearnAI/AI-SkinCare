import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/home/home_screen.dart';
import '../screens/product_analysis/product_analysis_screen.dart';
import '../screens/skin_detection/skin_detection_screen.dart';
import '../screens/user_center/user_center_screen.dart';
import '../screens/conflict/conflict_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String productAnalysis = '/product-analysis';
  static const String skinDetection = '/skin-detection';
  static const String userCenter = '/user-center';
  static const String conflict = '/conflict';
  static const String login = '/login';
  static const String register = '/register';
  static const String initialRoute = login;

  static List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: productAnalysis,
      page: () => const ProductAnalysisScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: skinDetection,
      page: () => const SkinDetectionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: userCenter,
      page: () => const UserCenterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: conflict,
      page: () => const ConflictScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
