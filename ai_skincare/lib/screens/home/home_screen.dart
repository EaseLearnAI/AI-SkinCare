import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../config/routes.dart';
import 'widgets/daily_skincare_card.dart';
import 'widgets/weather_suggestion_card.dart';
import 'widgets/article_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 模拟文章数据
  final List<Map<String, dynamic>> _articles = [
    {
      'id': 1,
      'title': '敏感肌如何选择温和洁面产品',
      'image': 'assets/images/article1.jpg',
      'time': '2023-10-15',
      'views': 1256,
    },
    {
      'id': 2,
      'title': '秋冬季节如何有效保湿',
      'image': 'assets/images/article2.jpg',
      'time': '2023-10-12',
      'views': 980,
    },
    {
      'id': 3,
      'title': '抗氧化成分有哪些？如何抵抗自由基',
      'image': 'assets/images/article3.jpg',
      'time': '2023-10-10',
      'views': 768,
    },
    {
      'id': 4,
      'title': '痘痘肌肤怎么护理才不会留疤',
      'image': 'assets/images/article4.jpg',
      'time': '2023-10-08',
      'views': 892,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部应用栏
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  // 应用标志
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.sakuraPink100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.spa_outlined,
                        color: AppTheme.sakuraPink600,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI护肤顾问',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                // 消息图标
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () {
                    // 打开通知页面
                  },
                ),
              ],
            ),

            // 内容区域
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 天气与护肤建议 - 已移至顶部
                    const WeatherSuggestionCard(),

                    const SizedBox(height: 24),

                    // 快捷入口区域
                    _buildQuickAccessSection(),

                    const SizedBox(height: 24),

                    // 每日护肤计划
                    const DailySkinCareCard(),

                    const SizedBox(height: 24),

                    // 护肤文章标题
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '护肤知识',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // 查看更多文章
                          },
                          child: Row(
                            children: const [
                              Text(
                                '更多',
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
                  ],
                ),
              ),
            ),

            // 文章列表
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final article = _articles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ArticleCard(
                      title: article['title'] as String,
                      imageUrl: article['image'] as String,
                      time: article['time'] as String,
                      views: article['views'] as int,
                      onTap: () {
                        // 打开文章详情
                      },
                    ),
                  );
                }, childCount: _articles.length),
              ),
            ),

            // 底部间距
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // 快捷入口区域
  Widget _buildQuickAccessSection() {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAccessItem(
            '产品分析',
            Icons.science_outlined,
            AppTheme.sakuraPink500,
            onTap: () => Get.toNamed(AppRoutes.productAnalysis),
          ),
          _buildQuickAccessItem(
            '肌肤检测',
            Icons.face_outlined,
            Colors.orange,
            onTap: () => Get.toNamed(AppRoutes.skinDetection),
          ),
          _buildQuickAccessItem(
            '肌肤日记',
            Icons.book_outlined,
            Colors.blue,
            onTap: () {
              // 打开肌肤日记
            },
          ),
          _buildQuickAccessItem(
            '护肤问答',
            Icons.question_answer_outlined,
            Colors.teal,
            onTap: () {
              // 打开护肤问答
            },
          ),
        ],
      ),
    );
  }

  // 快捷入口项
  Widget _buildQuickAccessItem(
    String label,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
