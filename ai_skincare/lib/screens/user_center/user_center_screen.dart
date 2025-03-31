import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class UserCenterScreen extends StatefulWidget {
  const UserCenterScreen({super.key});

  @override
  _UserCenterScreenState createState() => _UserCenterScreenState();
}

class _UserCenterScreenState extends State<UserCenterScreen> {
  // 模拟用户数据
  final Map<String, dynamic> _userData = {
    'avatar': 'assets/images/avatar.png',
    'nickname': '小樱',
    'level': '护肤达人',
    'points': 520,
    'tests': 12,
    'daysUsed': 28,
    'skinType': '混合性肌肤',
    'skinProblems': ['暗沉', '毛孔粗大'],
  };

  // 模拟历史记录
  final List<Map<String, dynamic>> _historyData = [
    {
      'type': 'skinTest',
      'date': '2023-10-15',
      'title': '皮肤状态检测',
      'description': '水分: 60%, 油分: 75%, 弹性: 50%',
      'icon': Icons.face_retouching_natural,
    },
    {
      'type': 'productAnalysis',
      'date': '2023-10-14',
      'title': '产品分析',
      'description': '分析了"烟酰胺精华液"成分安全性',
      'icon': Icons.science_outlined,
    },
    {
      'type': 'skinTest',
      'date': '2023-10-10',
      'title': '皮肤状态检测',
      'description': '水分: 55%, 油分: 78%, 弹性: 48%',
      'icon': Icons.face_retouching_natural,
    },
    {
      'type': 'productAnalysis',
      'date': '2023-10-08',
      'title': '产品分析',
      'description': '分析了"氨基酸洁面乳"成分安全性',
      'icon': Icons.science_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // 打开设置页面
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserInfoSection(),
            const SizedBox(height: 16),
            _buildStatisticsSection(),
            const SizedBox(height: 16),
            _buildOptionsSection(),
            const SizedBox(height: 16),
            _buildHistorySection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  // 用户信息区域
  Widget _buildUserInfoSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.sakuraPink500, AppTheme.sakuraPink300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              image: const DecorationImage(
                image: AssetImage('assets/images/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData['nickname'] as String,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _userData['level'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rate_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_userData['points']} 积分',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 编辑按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('编辑', style: TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 数据统计区域
  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                '${_userData['tests']}',
                '检测次数',
                Icons.analytics_outlined,
                AppTheme.sakuraPink100,
                AppTheme.sakuraPink500,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                '${_userData['daysUsed']}',
                '使用天数',
                Icons.calendar_today_outlined,
                Colors.blue.shade50,
                Colors.blue.shade500,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.face_outlined,
                color: AppTheme.sakuraPink500,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                '肤质类型:',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 4),
              Text(
                _userData['skinType'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                '肤质问题:',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_userData['skinProblems'] as List<dynamic>).map((
                    problem,
                  ) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        problem as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 统计项
  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 功能选项区域
  Widget _buildOptionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionItem('我的收藏', Icons.favorite_border, Colors.red.shade500),
          _buildOptionItem('我的测试记录', Icons.history, Colors.purple.shade500),
          _buildOptionItem(
            '成分冲突检测',
            Icons.warning_amber_outlined,
            Colors.orange.shade500,
            onTap: () => Get.toNamed('/conflict'),
          ),
          _buildOptionItem(
            '原料分析百科',
            Icons.spa_outlined,
            Colors.green.shade500,
            onTap: () => Get.toNamed('/ingredient_analysis'),
          ),
          _buildOptionItem('我的护肤日记', Icons.book_outlined, Colors.teal.shade500),
          _buildOptionItem(
            '肌肤分析报告',
            Icons.description_outlined,
            Colors.blue.shade500,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // 选项项
  Widget _buildOptionItem(
    String title,
    IconData icon,
    Color iconColor, {
    bool showDivider = true,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap ??
              () {
                // 处理点击事件
                Get.snackbar(
                  '功能开发中',
                  '此功能即将上线，敬请期待',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey.shade800,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                );
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textTertiary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  // 历史记录区域
  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '最近活动',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // 查看更多
                },
                child: Row(
                  children: const [
                    Text(
                      '查看更多',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.sakuraPink500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppTheme.sakuraPink500,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_historyData.length > 3 ? 3 : _historyData.length, (
            index,
          ) {
            final history = _historyData[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // 图标
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: history['type'] == 'skinTest'
                          ? AppTheme.sakuraPink100
                          : Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      history['icon'] as IconData,
                      color: history['type'] == 'skinTest'
                          ? AppTheme.sakuraPink500
                          : Colors.blue.shade500,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          history['description'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 日期
                  Text(
                    history['date'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
