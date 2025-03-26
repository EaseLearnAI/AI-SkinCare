import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProductAnalysisScreen extends StatefulWidget {
  const ProductAnalysisScreen({Key? key}) : super(key: key);

  @override
  _ProductAnalysisScreenState createState() => _ProductAnalysisScreenState();
}

class _ProductAnalysisScreenState extends State<ProductAnalysisScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _conflictMode = false;
  int _conflictCount = 0;
  String _selectedCategory = '全部产品';

  // 模拟产品数据
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'COSRX 低pH洁面啫喱',
      'subtitle': '温和无泡洁面乳，氨基酸系',
      'imageUrl':
          'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=100',
      'safetyScore': 95,
      'safetyLevel': '安全',
      'tags': ['洁面', '氨基酸'],
      'openDate': '06-01',
      'ingredients': ['水', '甘油', '泛醇'],
      'type': 'cleanser',
    },
    {
      'name': 'The Ordinary 维生素C精华',
      'subtitle': '高浓度抗氧化精华，美白提亮',
      'imageUrl':
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=100',
      'safetyScore': 80,
      'safetyLevel': '中等',
      'tags': ['精华', '维C'],
      'openDate': '05-15',
      'ingredients': ['维生素C', '透明质酸'],
      'type': 'serum',
    },
    {
      'name': '理肤泉特安舒缓保湿霜',
      'subtitle': '舒缓敏感肌肤，深度保湿',
      'imageUrl':
          'https://images.unsplash.com/photo-1601612628452-9e99ced43524?w=100',
      'safetyScore': 98,
      'safetyLevel': '安全',
      'tags': ['面霜', '保湿'],
      'openDate': '06-10',
      'ingredients': ['水', '甘油', '矿物油'],
      'type': 'moisturizer',
    },
  ];

  // 冲突规则
  final Map<String, Map<String, dynamic>> _conflictRules = {
    '维生素C': {
      'conflicts': ['烟酰胺'],
      'reason': '这两种成分会互相影响效果',
      'solution': '建议早晚分开使用',
    },
    'AHA': {
      'conflicts': ['维生素C', 'BHA'],
      'reason': '可能导致过度刺激',
      'solution': '建议隔天使用',
    },
  };

  // 选中的产品
  final List<Map<String, dynamic>> _selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: AppTheme.sakuraPink500,
        foregroundColor: Colors.white,
        title: const Text('猫窝产品库'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '在猫窝搜索已添加的产品喵～',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddNewProductCard(),
          _buildConflictDetectionButton(),
          _buildCategoryFilters(),
          ..._buildProductList(),
          _buildTodayRoutine(),
        ],
      ),
      floatingActionButton: _buildQuickConflictCheckButton(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildAddNewProductCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.add_circle, color: AppTheme.sakuraPink500),
              SizedBox(width: 8),
              Text(
                '添加新产品到猫窝',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProductAddButton(
                  icon: Icons.camera_alt,
                  title: '拍照识别',
                  subtitle: '猫眼扫描成分',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProductAddButton(
                  icon: Icons.image,
                  title: '相册选择',
                  subtitle: '从相册中选择',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductAddButton({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: AppTheme.sakuraPink100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.sakuraPink400, AppTheme.sakuraPink600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConflictDetectionButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _conflictMode = !_conflictMode;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                _conflictMode
                    ? [AppTheme.sakuraPink400, AppTheme.sakuraPink600]
                    : [AppTheme.sakuraPink400, AppTheme.sakuraPink600],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  _conflictMode
                      ? AppTheme.sakuraPink500.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.science, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  '开启成分冲突检测',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 26,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: _conflictMode ? 24 : 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['全部产品', '洁面', '化妆水', '精华', '面膜', '防晒'];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.red,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.sakuraPink500 : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child:
                    index == 0
                        ? Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: 12,
                          ),
                        )
                        : Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors[index - 1],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildProductList() {
    return _products.map((product) {
      final safetyLevel = product['safetyLevel'] as String;
      final safetyScore = product['safetyScore'] as int;

      Color safetyColor;
      if (safetyLevel == '安全') {
        safetyColor = Colors.green;
      } else if (safetyLevel == '中等') {
        safetyColor = Colors.orange;
      } else {
        safetyColor = Colors.red;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox (only visible in conflict mode)
            if (_conflictMode)
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 4),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _selectedProducts.contains(product),
                    activeColor: AppTheme.sakuraPink500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedProducts.add(product);
                        } else {
                          _selectedProducts.remove(product);
                        }
                      });
                    },
                  ),
                ),
              ),

            // Product image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['imageUrl'] as String,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                // Add scan effect animation here
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          product['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  safetyLevel == '安全'
                                      ? const Color(0xFFC8E6C9)
                                      : safetyLevel == '中等'
                                      ? Colors.yellow[100]
                                      : Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$safetyScore',
                                  style: TextStyle(
                                    color: safetyColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  safetyLevel,
                                  style: TextStyle(
                                    color: safetyColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.more_vert,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['subtitle'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 4,
                        children:
                            (product['tags'] as List<String>).map((tag) {
                              Color tagColor;
                              Color textColor;

                              if (tag == '洁面') {
                                tagColor = Colors.blue[100]!;
                                textColor = Colors.blue[700]!;
                              } else if (tag == '精华') {
                                tagColor = Colors.yellow[100]!;
                                textColor = Colors.yellow[700]!;
                              } else if (tag == '面霜') {
                                tagColor = Colors.green[100]!;
                                textColor = Colors.green[700]!;
                              } else if (tag == '维C') {
                                tagColor = Colors.red[100]!;
                                textColor = Colors.red[700]!;
                              } else if (tag == '氨基酸') {
                                tagColor = Colors.green[100]!;
                                textColor = Colors.green[700]!;
                              } else if (tag == '保湿') {
                                tagColor = Colors.blue[100]!;
                                textColor = Colors.blue[700]!;
                              } else {
                                tagColor = Colors.grey[100]!;
                                textColor = Colors.grey[700]!;
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tagColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      Text(
                        '${product['openDate']}开封',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildTodayRoutine() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_today, color: AppTheme.sakuraPink500),
              SizedBox(width: 8),
              Text(
                '今日使用方案',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Morning routine
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.wb_sunny, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '早间护理',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Column(
                  children: [
                    _buildRoutineStep(1, 'COSRX 低pH洁面啫喱'),
                    const SizedBox(height: 8),
                    _buildRoutineStep(2, '理肤泉特安舒缓保湿霜'),
                    const SizedBox(height: 8),
                    _buildRoutineStep(3, '安耐晒金瓶防晒霜'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Evening routine
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.nightlight, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '晚间护理',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Column(
                  children: [
                    _buildRoutineStep(1, 'COSRX 低pH洁面啫喱'),
                    const SizedBox(height: 8),
                    _buildRoutineStep(2, 'The Ordinary 维生素C精华'),
                    const SizedBox(height: 8),
                    _buildRoutineStep(3, '理肤泉特安舒缓保湿霜'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineStep(int step, String productName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.sakuraPink100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.sakuraPink300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(productName, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickConflictCheckButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            _showConflictModal();
          },
          child: const Icon(Icons.warning_amber_rounded),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
            child: Text(
              _conflictCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showConflictModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '检测到潜在冲突',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildConflictItem(
                  'The Ordinary 维生素C精华 + Some By Mi AHA精华',
                  '可能导致过度刺激',
                  '建议隔天使用',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildConflictItem(String products, String reason, String solution) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.warning_amber_rounded, color: Colors.red),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  products,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(fontSize: 12, color: Colors.red[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.yellow[700],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        solution,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
