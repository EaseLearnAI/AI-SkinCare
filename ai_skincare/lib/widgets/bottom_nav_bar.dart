import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/app_theme.dart';
import '../config/routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.sakuraPink500,
        unselectedItemColor: AppTheme.textTertiary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science_outlined),
            activeIcon: Icon(Icons.science),
            label: '产品分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_outlined),
            activeIcon: Icon(Icons.face),
            label: '肌肤检测',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '个人中心',
          ),
        ],
        onTap: (index) {
          if (index == currentIndex) return;

          switch (index) {
            case 0:
              Get.offAllNamed(AppRoutes.home);
              break;
            case 1:
              Get.offAllNamed(AppRoutes.productAnalysis);
              break;
            case 2:
              Get.offAllNamed(AppRoutes.skinDetection);
              break;
            case 3:
              Get.offAllNamed(AppRoutes.userCenter);
              break;
          }
        },
      ),
    );
  }

  // 显示更多选项菜单
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.warning_amber_outlined,
              color: AppTheme.sakuraPink500,
            ),
            title: const Text('成分冲突检测'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.conflict);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
