import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/home/home_screen.dart';
import '../screens/product_analysis/product_analysis_screen.dart';
import '../screens/skin_detection/skin_detection_screen.dart';
import '../screens/user_center/user_center_screen.dart';
import '../screens/conflict/conflict_screen.dart';
import '../screens/ingredient_analysis/ingredient_analysis_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String productAnalysis = '/product_analysis';
  static const String skinDetection = '/skin_detection';
  static const String userCenter = '/user_center';
  static const String conflict = '/conflict';
  static const String ingredientAnalysis = '/ingredient_analysis';

  static const String initial = home;

  static final List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: productAnalysis,
      page: () => const ProductAnalysisScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: skinDetection,
      page: () => const SkinDetectionScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: userCenter,
      page: () => const UserCenterScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: conflict,
      page: () => const ConflictScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: ingredientAnalysis,
      page: () => const IngredientAnalysisScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
