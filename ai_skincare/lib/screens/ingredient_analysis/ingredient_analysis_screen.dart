import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../themes/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class IngredientAnalysisScreen extends StatefulWidget {
  const IngredientAnalysisScreen({Key? key}) : super(key: key);

  @override
  _IngredientAnalysisScreenState createState() =>
      _IngredientAnalysisScreenState();
}

class _IngredientAnalysisScreenState extends State<IngredientAnalysisScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 模拟成分数据
  final List<Map<String, dynamic>> _ingredients = [
    {
      'name': '烟酰胺',
      'alias': 'Niacinamide',
      'description': '烟酰胺是一种维生素B3的形式，能够帮助改善肤色不均，减少皱纹和细纹，提高皮肤弹性。',
      'safetyLevel': 0.95,
      'commonUsage': ['美白精华', '面霜', '精华液'],
      'benefits': ['美白', '收缩毛孔', '抗炎', '调节油脂'],
      'risk': ['高浓度可能刺激', '极少数人可能过敏'],
      'category': '维生素类',
      'imagePath': 'assets/images/ingredients/niacinamide.jpg',
    },
    {
      'name': '透明质酸',
      'alias': 'Hyaluronic Acid',
      'description': '透明质酸是一种能够保持皮肤水分的强大保湿成分，每分子能够结合多达1000倍于自身重量的水分子。',
      'safetyLevel': 0.98,
      'commonUsage': ['保湿精华', '面霜', '爽肤水'],
      'benefits': ['保湿', '提亮肤色', '减少细纹'],
      'risk': ['几乎无风险'],
      'category': '保湿剂',
      'imagePath': 'assets/images/ingredients/hyaluronic_acid.jpg',
    },
    {
      'name': '视黄醇',
      'alias': 'Retinol',
      'description': '视黄醇是一种维生素A的形式，能够促进皮肤细胞更新，减少皱纹和细纹，改善肤色不均。',
      'safetyLevel': 0.75,
      'commonUsage': ['抗衰老精华', '晚霜'],
      'benefits': ['抗衰老', '促进细胞更新', '改善色斑'],
      'risk': ['可能导致皮肤干燥、发红、刺痛', '增加光敏感性'],
      'category': '维生素类',
      'imagePath': 'assets/images/ingredients/retinol.jpg',
    },
    {
      'name': '水杨酸',
      'alias': 'Salicylic Acid',
      'description': '水杨酸是一种β羟基酸(BHA)，能够深入毛孔清洁，溶解过多油脂，帮助去除死皮细胞。',
      'safetyLevel': 0.80,
      'commonUsage': ['祛痘产品', '爽肤水', '洁面'],
      'benefits': ['去角质', '抗痘', '控油'],
      'risk': ['可能导致皮肤干燥', '某些人可能过敏'],
      'category': '酸类',
      'imagePath': 'assets/images/ingredients/salicylic_acid.jpg',
    },
  ];

  String _searchText = '';
  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '维生素类', '保湿剂', '酸类', '抗氧化剂', '植物提取物'];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('原料分析百科'),
        backgroundColor: AppTheme.sakuraPink500,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // 查看历史记录
              Get.snackbar(
                '历史记录',
                '查看成分分析历史',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.white,
                colorText: AppTheme.sakuraPink500,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),

          // 分类过滤器
          _buildCategoryFilter(),

          // 成分列表
          Expanded(child: _buildIngredientList()),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  // 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索成分名称或功效...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.grey.shade400,
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchText = '';
                      });
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
      ),
    );
  }

  // 构建分类过滤器
  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.sakuraPink500 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppTheme.sakuraPink500
                            : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建成分列表
  Widget _buildIngredientList() {
    // 筛选成分
    final filteredIngredients =
        _ingredients.where((ingredient) {
          // 分类筛选
          if (_selectedCategory != '全部' &&
              ingredient['category'] != _selectedCategory) {
            return false;
          }

          // 搜索筛选
          if (_searchText.isNotEmpty) {
            final name = ingredient['name'] as String;
            final alias = ingredient['alias'] as String;
            final description = ingredient['description'] as String;
            final benefits = (ingredient['benefits'] as List).join(' ');

            return name.toLowerCase().contains(_searchText.toLowerCase()) ||
                alias.toLowerCase().contains(_searchText.toLowerCase()) ||
                description.toLowerCase().contains(_searchText.toLowerCase()) ||
                benefits.toLowerCase().contains(_searchText.toLowerCase());
          }

          return true;
        }).toList();

    if (filteredIngredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到相关成分',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '尝试更换搜索词或分类',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filteredIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = filteredIngredients[index];
        final safetyLevel = (ingredient['safetyLevel'] as double);
        final safetyColor =
            safetyLevel > 0.9
                ? Colors.green
                : safetyLevel > 0.7
                ? Colors.orange
                : Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 成分头部
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  children: [
                    Text(
                      ingredient['name'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.sakuraPink100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ingredient['alias'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.sakuraPink600,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    ingredient['description'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                ),
                trailing: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: safetyColor, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '${(safetyLevel * 100).toInt()}%',
                      style: TextStyle(
                        color: safetyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // 分隔线
              const Divider(height: 1),

              // 常见用途
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '常见用途',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (ingredient['commonUsage'] as List).map((usage) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                usage as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),

              // 功效与风险
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '主要功效',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                (ingredient['benefits'] as List).map((benefit) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          benefit as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '潜在风险',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                (ingredient['risk'] as List).map((risk) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            risk as String,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 查看详情按钮
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 查看详情
                          Get.snackbar(
                            '详情',
                            '查看${ingredient['name']}的详细信息',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.sakuraPink500,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.sakuraPink500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('查看详细说明'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
