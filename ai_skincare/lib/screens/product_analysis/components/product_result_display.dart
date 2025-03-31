import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../themes/app_theme.dart';

class ProductResultDisplay extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductResultDisplay({
    Key? key,
    required this.productData,
  }) : super(key: key);

  @override
  State<ProductResultDisplay> createState() => _ProductResultDisplayState();
}

class _ProductResultDisplayState extends State<ProductResultDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> analysisResult =
        widget.productData['analysisResult'] ?? {};

    Map<String, dynamic> content = {};
    if (analysisResult['content'] != null) {
      if (analysisResult['content'] is String) {
        try {
          content = json.decode(analysisResult['content']);
        } catch (e) {
          print('解析分析结果内容失败: $e');
          content = {'error': '无法解析分析结果内容'};
        }
      } else if (analysisResult['content'] is Map) {
        content = Map<String, dynamic>.from(analysisResult['content']);
      }
    }

    final String productName = widget.productData['name'] ?? '未知产品';
    final String brandName = widget.productData['brandName'] ?? '未知品牌';
    final String safetyLevel = analysisResult['safety_level'] ?? '未评估';
    final int safetyScore = analysisResult['safety_score'] ?? 0;
    final List<dynamic> tags = analysisResult['tags'] ?? [];

    final String overallEvaluation =
        content['overall_evaluation'] ?? '暂无总体评价喵～';
    final List<dynamic> benefits = content['benefits'] ?? [];
    final List<dynamic> potentialRisks = content['potential_risks'] ?? [];
    final List<dynamic> keyIngredients = content['key_ingredients'] ?? [];
    final List<dynamic> usageSuggestions = content['usage_suggestions'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🐱 '),
            Text('$productName の分析报告'),
          ],
        ),
        backgroundColor: const Color(0xFFFFB7C5), // 淡粉色
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB7C5), Color(0xFFFFF0F5)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductCard(
                  productName: productName,
                  brandName: brandName,
                  safetyLevel: safetyLevel,
                  safetyScore: safetyScore,
                  tags: tags,
                ),
                const SizedBox(height: 16),
                _buildEvaluationCard(
                  title: '🐱 喵喵总评',
                  content: overallEvaluation,
                  icon: '🌸',
                ),
                const SizedBox(height: 16),
                if (benefits.isNotEmpty)
                  _buildListCard(
                    title: '🐾 喵爪功效榜',
                    items: benefits.map((e) => e.toString()).toList(),
                    icon: '✨',
                    color: const Color(0xFF8BC34A),
                  ),
                const SizedBox(height: 16),
                if (potentialRisks.isNotEmpty)
                  _buildListCard(
                    title: '⚠️ 喵呜风险提示',
                    items: potentialRisks.map((e) => e.toString()).toList(),
                    icon: '🚫',
                    color: const Color(0xFFFF5722),
                  ),
                const SizedBox(height: 16),
                if (keyIngredients.isNotEmpty)
                  _buildKeyIngredientsCard(
                    keyIngredients: keyIngredients,
                  ),
                const SizedBox(height: 16),
                if (usageSuggestions.isNotEmpty)
                  _buildListCard(
                    title: '💡 贴心喵士',
                    items: usageSuggestions.map((e) => e.toString()).toList(),
                    icon: '🎀',
                    color: const Color(0xFF2196F3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String productName,
    required String brandName,
    required String safetyLevel,
    required int safetyScore,
    required List<dynamic> tags,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFFF0F5)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        brandName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSafetyBadge(safetyScore, safetyLevel),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => _buildTag(tag.toString())).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyBadge(int score, String level) {
    Color getScoreColor() {
      if (score >= 80) return const Color(0xFF4CAF50);
      if (score >= 60) return const Color(0xFFFFA726);
      return const Color(0xFFEF5350);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: getScoreColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: getScoreColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: TextStyle(
              color: getScoreColor(),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            level,
            style: TextStyle(
              color: getScoreColor(),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB7C5).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB7C5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🐾 ',
            style: TextStyle(
              color: Colors.pink[300],
              fontSize: 12,
            ),
          ),
          Text(
            tag,
            style: TextStyle(
              color: Colors.pink[300],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard({
    required String title,
    required String content,
    required String icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFFF0F5)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required List<String> items,
    required String icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFFF0F5)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$icon  ",
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyIngredientsCard({
    required List<dynamic> keyIngredients,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFFF0F5)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🧪'),
                SizedBox(width: 8),
                Text(
                  '成分喵喵酱',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...keyIngredients.map((ingredient) {
              if (ingredient is Map) {
                final name = ingredient['name'] ?? '未知成分';
                final function = ingredient['function'] ?? '未知功效';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE1BEE7),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🌟 '),
                          Text(
                            name.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        function.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListTile(
                  leading: const Text('🌟'),
                  title: Text(
                    ingredient.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
