import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/product_model.dart';
import '../../models/ingredient_model.dart';
import '../../services/api_service.dart';
import '../../services/ai_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'components/simplified_product_analysis.dart';
import 'components/product_analysis_result.dart';
import 'components/product_result_display.dart';
import 'components/conflict_analysis_display.dart';

class ProductAnalysisScreen extends StatefulWidget {
  const ProductAnalysisScreen({Key? key}) : super(key: key);

  @override
  _ProductAnalysisScreenState createState() => _ProductAnalysisScreenState();
}

class _ProductAnalysisScreenState extends State<ProductAnalysisScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _conflictMode = false;
  final int _conflictCount = 0;
  String _selectedCategory = '全部产品';

  // Web平台图片缓存
  Uint8List? _webImageBytes;

  // 移动平台图片文件
  File? _imageFile;

  // 通用XFile存储
  XFile? _pickedFile;

  bool _isAnalyzing = false;
  bool _isLoading = false;
  ProductModel? _analyzedProduct;
  Map<String, dynamic>? _aiAnalysisResult;
  String _errorMessage = '';

  // 用户产品列表
  List<ProductModel> _userProducts = [];
  bool _isLoadingProducts = true;

  // 保存状态
  bool _isSaving = false;
  bool _resultDialogShown = false; // 跟踪结果对话框是否已显示

  @override
  void initState() {
    super.initState();
    _loadUserProducts();
  }

  // 从后端加载用户产品列表
  Future<void> _loadUserProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      // 尝试从API获取用户产品列表
      final products = await ApiService.getUserProducts();
      setState(() {
        _userProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      print('Failed to load products from API: $e');

      // 检查是否是网络错误
      if (e is ApiException &&
          (e.code == 'NETWORK_ERROR' ||
              e.message.contains('网络连接失败') ||
              e.message.contains('Failed to fetch'))) {
        // 如果是网络错误，使用本地模拟数据
        _loadMockProducts();

        // 提示用户
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('网络连接失败，已切换到离线模式'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // 其他类型的错误
        setState(() {
          _isLoadingProducts = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('加载产品列表失败: ${e.toString()}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  // 加载模拟产品数据
  void _loadMockProducts() {
    setState(() {
      _userProducts = [
        ProductModel(
          id: '1',
          name: 'COSRX 低pH洁面啫喱',
          brandName: 'COSRX',
          imageUrl:
              'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=100',
          description: '温和无泡洁面乳，氨基酸系',
          category: 'cleanser',
          ingredients: [
            IngredientModel(id: '1', name: '水', safetyLevel: 100),
            IngredientModel(id: '2', name: '甘油', safetyLevel: 95),
            IngredientModel(id: '3', name: '泛醇', safetyLevel: 90),
          ],
          rating: 4.8,
          reviewCount: 1200,
          analysisResult: {
            "safety_score": 90,
            "safety_level": "安全",
            "tags": ["保湿", "舒缓"]
          },
        ),
        ProductModel(
          id: '2',
          name: 'The Ordinary 维生素C精华',
          brandName: 'The Ordinary',
          imageUrl:
              'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=100',
          description: '高浓度抗氧化精华，美白提亮',
          category: 'serum',
          ingredients: [
            IngredientModel(id: '4', name: '维生素C', safetyLevel: 85),
            IngredientModel(id: '5', name: '透明质酸', safetyLevel: 92),
          ],
          rating: 4.5,
          reviewCount: 980,
          analysisResult: {
            "safety_score": 85,
            "safety_level": "良好",
            "tags": ["抗氧化", "美白"]
          },
        ),
        ProductModel(
          id: '3',
          name: '理肤泉特安舒缓保湿霜',
          brandName: '理肤泉',
          imageUrl:
              'https://images.unsplash.com/photo-1601612628452-9e99ced43524?w=100',
          description: '舒缓敏感肌肤，深度保湿',
          category: 'moisturizer',
          ingredients: [
            IngredientModel(id: '1', name: '水', safetyLevel: 100),
            IngredientModel(id: '2', name: '甘油', safetyLevel: 95),
            IngredientModel(id: '6', name: '矿物油', safetyLevel: 75),
          ],
          rating: 4.9,
          reviewCount: 1500,
          analysisResult: {
            "safety_score": 80,
            "safety_level": "良好",
            "tags": ["保湿", "舒缓", "敏感肌适用"]
          },
        ),
      ];
      _isLoadingProducts = false;
    });
  }

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
      body: _buildAnalysisResultView(),
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
        onTap: () {
          if (title == '拍照识别') {
            print("点击了拍照识别按钮");
            _takeAndAnalyzePhoto();
          } else if (title == '相册选择') {
            print("点击了相册选择按钮");
            _selectAndAnalyzeImage();
          }
        },
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
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _conflictMode = !_conflictMode;
              // 如果关闭冲突模式，清空选择的产品
              if (!_conflictMode) {
                _selectedProducts.clear();
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _conflictMode
                    ? [AppTheme.sakuraPink400, AppTheme.sakuraPink600]
                    : [AppTheme.sakuraPink400, AppTheme.sakuraPink600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _conflictMode
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
        ),
        // 添加分析按钮，只在冲突模式开启并且选择了产品时显示
        if (_conflictMode && _selectedProducts.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _analyzeSelectedProductsConflicts,
              icon: const Icon(Icons.account_tree),
              label: const Text('分析选中产品的成分冲突'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
      ],
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
                child: index == 0
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
                                  isSelected ? Colors.white : Colors.grey[600],
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
    if (_isLoadingProducts) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sakuraPink500),
            ),
          ),
        )
      ];
    }

    if (_userProducts.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  '你的猫窝里还没有产品',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '添加你的第一个产品开始护肤之旅吧！',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectAndAnalyzeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sakuraPink500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('上传产品图片'),
                ),
              ],
            ),
          ),
        )
      ];
    }

    // 如果选择了特定类别，筛选产品
    List<ProductModel> filteredProducts = _userProducts;
    if (_selectedCategory != '全部产品') {
      filteredProducts = _userProducts.where((product) {
        return product.category.toLowerCase() ==
                _selectedCategory.toLowerCase() ||
            product.category.contains(_selectedCategory);
      }).toList();
    }

    if (filteredProducts.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '没有 $_selectedCategory 类别的产品',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = '全部产品';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.sakuraPink500),
                    foregroundColor: AppTheme.sakuraPink500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('显示全部产品'),
                ),
              ],
            ),
          ),
        )
      ];
    }

    return filteredProducts.map((product) {
      // 安全分数和级别的计算（如果分析结果中没有这些信息）
      int safetyScore = 0;
      String safetyLevel = '';

      if (product.analysisResult != null) {
        // 尝试从分析结果中提取安全分数和级别
        try {
          final analysisResultStr = product.analysisResult.toString();
          // 简单的分数提取（这里可以根据实际情况调整）
          if (analysisResultStr.contains('安全') ||
              analysisResultStr.contains('低风险')) {
            safetyScore = 90 + (DateTime.now().millisecondsSinceEpoch % 10);
            safetyLevel = '安全';
          } else if (analysisResultStr.contains('中等') ||
              analysisResultStr.contains('中风险')) {
            safetyScore = 70 + (DateTime.now().millisecondsSinceEpoch % 15);
            safetyLevel = '中等';
          } else {
            safetyScore = 50 + (DateTime.now().millisecondsSinceEpoch % 20);
            safetyLevel = '风险';
          }
        } catch (e) {
          safetyScore = 75;
          safetyLevel = '中等';
        }
      } else {
        safetyScore = 75;
        safetyLevel = '中等';
      }

      Color safetyColor;
      if (safetyLevel == '安全') {
        safetyColor = Colors.green;
      } else if (safetyLevel == '中等') {
        safetyColor = Colors.orange;
      } else {
        safetyColor = Colors.red;
      }

      // 提取标签
      List<String> tags = [];
      if (product.category.isNotEmpty) {
        tags.add(product.category);
      }

      // 从分析结果中提取可能的标签
      if (product.analysisResult != null) {
        final analysisResultStr = product.analysisResult.toString();
        if (analysisResultStr.contains('保湿')) tags.add('保湿');
        if (analysisResultStr.contains('美白')) tags.add('美白');
        if (analysisResultStr.contains('抗氧化')) tags.add('抗氧化');
        if (analysisResultStr.contains('修复')) tags.add('修复');
        if (analysisResultStr.contains('舒缓')) tags.add('舒缓');
        if (analysisResultStr.contains('抗老')) tags.add('抗老');
        if (analysisResultStr.contains('清洁')) tags.add('清洁');
      }

      // 确保标签不超过3个
      if (tags.length > 3) {
        tags = tags.sublist(0, 3);
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
        child: InkWell(
          onTap: () => _showProductDetail(product),
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
                      value:
                          _selectedProducts.any((p) => p['id'] == product.id),
                      activeColor: AppTheme.sakuraPink500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() {
                          final existingProduct = _selectedProducts
                              .firstWhereOrNull((p) => p['id'] == product.id);

                          if (value == true && existingProduct == null) {
                            _selectedProducts.add({
                              'id': product.id,
                              'name': product.name,
                              'subtitle': product.description,
                              'imageUrl': product.imageUrl,
                              'safetyScore': safetyScore,
                              'safetyLevel': safetyLevel,
                              'tags': tags,
                              'openDate':
                                  DateTime.now().toString().substring(5, 10),
                              'ingredients': product.ingredients
                                  .map((i) => i.name)
                                  .toList(),
                              'type': product.category,
                            });
                          } else if (value == false &&
                              existingProduct != null) {
                            _selectedProducts
                                .removeWhere((p) => p['id'] == product.id);
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
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            ApiService.getFullImageUrl(product.imageUrl),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 64,
                                height: 64,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                            ),
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
                            product.name,
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
                                color: safetyLevel == '安全'
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
                              onTap: () => _showProductActionMenu(product),
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
                      product.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 4,
                          children: tags.map((tag) {
                            Color tagColor;
                            Color textColor;

                            if (tag.toLowerCase() == 'cleanser' ||
                                tag.toLowerCase() == '洁面') {
                              tagColor = Colors.blue[100]!;
                              textColor = Colors.blue[700]!;
                            } else if (tag.toLowerCase() == 'serum' ||
                                tag.toLowerCase() == '精华') {
                              tagColor = Colors.yellow[100]!;
                              textColor = Colors.yellow[700]!;
                            } else if (tag.toLowerCase() == 'moisturizer' ||
                                tag.toLowerCase() == '面霜') {
                              tagColor = Colors.green[100]!;
                              textColor = Colors.green[700]!;
                            } else if (tag.toLowerCase() == '维c' ||
                                tag.toLowerCase() == '维生素c') {
                              tagColor = Colors.red[100]!;
                              textColor = Colors.red[700]!;
                            } else if (tag.toLowerCase() == 'amino acid' ||
                                tag.toLowerCase() == '氨基酸') {
                              tagColor = Colors.green[100]!;
                              textColor = Colors.green[700]!;
                            } else if (tag.toLowerCase() == 'hydrating' ||
                                tag.toLowerCase() == '保湿') {
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
                          '${DateTime.now().toString().substring(5, 10)}开封',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _conflictMode = !_conflictMode;
          if (!_conflictMode) {
            _selectedProducts.clear();
          }
        });
      },
      backgroundColor: _conflictMode ? Colors.orange : AppTheme.sakuraPink500,
      label: Text(_conflictMode ? '退出冲突检测' : '快速冲突检测'),
      icon: Icon(_conflictMode ? Icons.close : Icons.science),
    );
  }

  void _showConflictModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AI 成分冲突分析',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 分隔线
            const Divider(height: 1),

            const SizedBox(height: 16),

            // 简短说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '以下是AI分析的成分冲突结果，请根据实际情况参考使用',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 分析结果内容
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 格式化显示冲突分析结果
                    Text(
                      _aiAnalysisResult!['summary']?.toString() ?? '',
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 底部操作按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.sakuraPink500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('了解了'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 分析产品
  Future<void> _analyzeProduct(File imageFile) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    });

    try {
      final imageAnalysisResult =
          await AiService.analyzeProductImage(imageFile);

      if (imageAnalysisResult.containsKey('raw_content')) {
        setState(() {
          _errorMessage = '无法识别产品信息，请尝试更清晰的图片。';
          _isAnalyzing = false;
        });
        return;
      }

      final productName = imageAnalysisResult['product_name'] ?? '未知产品';
      final brandName = imageAnalysisResult['brand_name'] ?? '未知品牌';
      final ingredientsList =
          imageAnalysisResult['ingredients'] as List<dynamic>? ?? [];

      final ingredients = ingredientsList.map((name) {
        return IngredientModel(
          id: name.hashCode.toString(),
          name: name.toString(),
          safetyLevel: 50,
        );
      }).toList();

      final product = ProductModel(
        id: '${brandName}_${productName}_${DateTime.now().millisecondsSinceEpoch}'
            .hashCode
            .toString(),
        name: productName,
        brandName: brandName,
        imageUrl: '',
        description: '通过AI识别分析的产品',
        category: '护肤品',
        ingredients: ingredients,
      );

      final skinCondition = await _getSkinCondition();
      final ingredientNames = ingredients.map((i) => i.name).toList();
      final analysisResult =
          await AiService.analyzeIngredients(ingredientNames, skinCondition);

      // 确保分析结果是 Map<String, dynamic> 类型
      final Map<String, dynamic> formattedAnalysisResult = {
        'summary': analysisResult,
        'benefits': [],
        'potential_concerns': [],
        'safety_level': '待评估'
      };

      setState(() {
        _analyzedProduct = product;
        _aiAnalysisResult = formattedAnalysisResult;
        _isAnalyzing = false;
      });

      // 将结果保存到后端数据库
      await _saveProductToBackend(
          product,
          formattedAnalysisResult['summary'].toString(),
          imageFile.path,
          _webImageBytes);
    } catch (e) {
      setState(() {
        _errorMessage = '分析过程中出错: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  // Web平台专用的分析方法
  Future<void> _analyzeProductForWeb(String base64Image) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    });

    try {
      if (kIsWeb) {
        print("在Web平台上进行分析，使用base64图像数据");
      }

      final imageAnalysisResult =
          await AiService.analyzeProductImageForWeb(base64Image);

      if (imageAnalysisResult.containsKey('raw_content')) {
        setState(() {
          _errorMessage = '无法识别产品信息，请尝试更清晰的图片。';
          _isAnalyzing = false;
        });
        return;
      }

      final productName = imageAnalysisResult['product_name'] ?? '未知产品';
      final brandName = imageAnalysisResult['brand_name'] ?? '未知品牌';
      final ingredientsList =
          imageAnalysisResult['ingredients'] as List<dynamic>? ?? [];

      final ingredients = ingredientsList.map((name) {
        return IngredientModel(
          id: name.hashCode.toString(),
          name: name.toString(),
          safetyLevel: 50,
        );
      }).toList();

      final product = ProductModel(
        id: '${brandName}_${productName}_${DateTime.now().millisecondsSinceEpoch}'
            .hashCode
            .toString(),
        name: productName,
        brandName: brandName,
        imageUrl: '',
        description: '通过AI识别分析的产品',
        category: '护肤品',
        ingredients: ingredients,
      );

      final skinCondition = await _getSkinCondition();
      final ingredientNames = ingredients.map((i) => i.name).toList();
      final analysisResult =
          await AiService.analyzeIngredients(ingredientNames, skinCondition);

      // 确保分析结果是 Map<String, dynamic> 类型
      final Map<String, dynamic> formattedAnalysisResult = {
        'summary': analysisResult,
        'benefits': [],
        'potential_concerns': [],
        'safety_level': '待评估'
      };

      setState(() {
        _analyzedProduct = product;
        _aiAnalysisResult = formattedAnalysisResult;
        _isAnalyzing = false;
      });

      await _saveProductToBackend(product,
          formattedAnalysisResult['summary'].toString(), null, _webImageBytes);
    } catch (e) {
      print("分析过程中出错: $e");
      setState(() {
        _errorMessage = '分析过程中出错: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  // 将产品分析结果保存到后端
  Future<void> _saveProductToBackend(
      ProductModel product, String analysisResultText,
      [String? imagePath, Uint8List? imageBytes]) async {
    try {
      setState(() {
        _isSaving = true;
      });

      // 将分析文本转换为适当的格式
      final Map<String, dynamic> analysisResult = {
        'content': analysisResultText,
        'safety_score': _extractSafetyScore(analysisResultText),
        'safety_level': _extractSafetyLevel(analysisResultText),
        'tags': _extractTags(analysisResultText),
      };

      // 保存产品分析结果到后端
      final savedProduct = await ApiService.saveProductAnalysis(
        product: product,
        analysisResult: analysisResult,
        imageBytes: imageBytes,
        imageFile: imagePath,
      );

      setState(() {
        _isSaving = false;
      });

      if (savedProduct != null) {
        // 更新本地产品列表
        setState(() {
          // 移除相同ID的旧产品（如果有）
          _userProducts.removeWhere((p) => p.id == savedProduct.id);
          // 添加新保存的产品
          _userProducts.add(savedProduct);
        });

        // 显示成功提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('产品分析结果已保存'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // 创建产品详情数据对象
        Map<String, dynamic> productData = {
          'id': savedProduct.id,
          'name': savedProduct.name,
          'brandName': savedProduct.brandName,
          'imageUrl': savedProduct.imageUrl,
          'description': savedProduct.description,
          'category': savedProduct.category,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'analysisResult': savedProduct.analysisResult,
        };

        // 显示产品分析结果
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductResultDisplay(productData: productData),
              ),
            );
          });
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      print('保存产品分析结果失败: $e');
    }
  }

  // 添加产品到我的收藏
  void _addProductToCollection() async {
    if (_analyzedProduct == null || _aiAnalysisResult == null) return;

    try {
      // 将分析结果转换为字符串
      String formattedAnalysisResult = '';

      // 添加功效信息
      if (_aiAnalysisResult!['benefits'] != null) {
        formattedAnalysisResult += '产品功效：\n';
        List<dynamic> benefits = _aiAnalysisResult!['benefits'];
        for (var benefit in benefits) {
          formattedAnalysisResult += '• $benefit\n';
        }
        formattedAnalysisResult += '\n';
      }

      // 添加风险信息
      if (_aiAnalysisResult!['potential_concerns'] != null) {
        formattedAnalysisResult += '使用注意：\n';
        List<dynamic> risks = _aiAnalysisResult!['potential_concerns'];
        for (var risk in risks) {
          formattedAnalysisResult += '• $risk\n';
        }
        formattedAnalysisResult += '\n';
      }

      // 添加安全等级信息
      if (_aiAnalysisResult!['safety_level'] != null) {
        formattedAnalysisResult +=
            '安全等级：${_aiAnalysisResult!['safety_level']}\n';
      }

      // 如果没有任何内容，使用默认消息
      if (formattedAnalysisResult.isEmpty) {
        formattedAnalysisResult = '暂无详细分析结果';
      }

      // 保存产品到后端数据库
      await _saveProductToBackend(_analyzedProduct!, formattedAnalysisResult,
          _imageFile?.path, _webImageBytes);

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('产品已添加到你的收藏'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 创建产品详情数据对象以显示分析结果
      Map<String, dynamic> productData = {
        'id': _analyzedProduct!.id,
        'name': _analyzedProduct!.name,
        'brandName': _analyzedProduct!.brandName,
        'imageUrl': _analyzedProduct!.imageUrl,
        'description': _analyzedProduct!.description,
        'category': _analyzedProduct!.category,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'analysisResult': _aiAnalysisResult,
      };

      // 显示产品分析结果
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductResultDisplay(productData: productData),
            ),
          );
        });
      }
    } catch (e) {
      print('添加产品到收藏失败: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // 显示产品详情
  void _showProductDetail(ProductModel product) {
    // 创建产品详情数据对象
    Map<String, dynamic> productData = {
      'id': product.id,
      'name': product.name,
      'brandName': product.brandName,
      'imageUrl': product.imageUrl,
      'description': product.description,
      'category': product.category,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'analysisResult': product.analysisResult,
    };

    // 如果当前有新的分析结果，使用它
    if (_aiAnalysisResult != null) {
      productData['analysisResult'] = _aiAnalysisResult;
    }

    // 导航到产品结果显示页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductResultDisplay(productData: productData),
      ),
    );
  }

  // 显示产品操作菜单
  void _showProductActionMenu(ProductModel product) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('查看详情'),
                onTap: () {
                  Navigator.pop(context);
                  _showProductDetail(product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除产品'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('取消'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除产品'),
          content: Text('确定要从猫窝删除产品"${product.name}"吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 实现删除产品的API调用
                // 临时实现：直接从本地列表中移除
                setState(() {
                  _userProducts.removeWhere((p) => p.id == product.id);
                });

                Get.snackbar(
                  '',
                  '',
                  titleText: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        '删除成功',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  messageText: Text(
                    '已从猫窝中删除 ${product.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                  duration: const Duration(seconds: 3),
                );
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getSkinCondition() async {
    // 这里可以从全局状态或本地存储获取用户的肌肤状态
    // 示例数据
    return {
      'hydration': 60,
      'oil': 50,
      'sensitivity': 30,
      'concerns': ['痘痘', '干燥'],
    };
  }

  // 提取安全得分
  int _extractSafetyScore(String analysisText) {
    try {
      if (analysisText.contains('安全评级: 极高') ||
          analysisText.contains('安全评级：极高')) {
        return 95;
      } else if (analysisText.contains('安全评级: 高') ||
          analysisText.contains('安全评级：高')) {
        return 85;
      } else if (analysisText.contains('安全评级: 中') ||
          analysisText.contains('安全评级：中')) {
        return 70;
      } else if (analysisText.contains('安全评级: 低') ||
          analysisText.contains('安全评级：低')) {
        return 50;
      } else if (analysisText.contains('安全评级: 很低') ||
          analysisText.contains('安全评级：很低')) {
        return 30;
      }
    } catch (e) {
      print('提取安全得分失败: $e');
    }
    return 60; // 默认中等安全度
  }

  // 提取安全级别
  String _extractSafetyLevel(String analysisText) {
    try {
      if (analysisText.contains('安全评级: 极高') ||
          analysisText.contains('安全评级：极高')) {
        return '非常安全';
      } else if (analysisText.contains('安全评级: 高') ||
          analysisText.contains('安全评级：高')) {
        return '安全';
      } else if (analysisText.contains('安全评级: 中') ||
          analysisText.contains('安全评级：中')) {
        return '一般';
      } else if (analysisText.contains('安全评级: 低') ||
          analysisText.contains('安全评级：低')) {
        return '较低安全性';
      } else if (analysisText.contains('安全评级: 很低') ||
          analysisText.contains('安全评级：很低')) {
        return '安全性堪忧';
      }
    } catch (e) {
      print('提取安全级别失败: $e');
    }
    return '安全性一般'; // 默认
  }

  // 提取标签
  List<String> _extractTags(String analysisText) {
    try {
      final List<String> tags = [];

      // 根据常见关键词提取标签
      if (analysisText.contains('保湿') || analysisText.contains('滋润')) {
        tags.add('保湿');
      }
      if (analysisText.contains('舒缓') || analysisText.contains('镇静')) {
        tags.add('舒缓');
      }
      if (analysisText.contains('抗氧化') || analysisText.contains('抗自由基')) {
        tags.add('抗氧化');
      }
      if (analysisText.contains('美白') || analysisText.contains('淡斑')) {
        tags.add('美白');
      }
      if (analysisText.contains('抗皱') || analysisText.contains('紧致')) {
        tags.add('抗老化');
      }
      if (analysisText.contains('控油') || analysisText.contains('平衡')) {
        tags.add('控油');
      }
      if (analysisText.contains('清洁') || analysisText.contains('清爽')) {
        tags.add('清洁');
      }
      if (analysisText.contains('敏感肌') || analysisText.contains('敏感性皮肤')) {
        tags.add('敏感肌适用');
      }

      // 如果没有提取到任何标签，则添加一个默认标签
      if (tags.isEmpty) {
        tags.add('基础护理');
      }

      return tags;
    } catch (e) {
      print('提取标签失败: $e');
      return ['基础护理']; // 默认标签
    }
  }

  // 添加选择图片并分析的方法
  Future<void> _selectAndAnalyzeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedFile = image;
      });

      if (kIsWeb) {
        // Web平台处理
        final bytes = await image.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
        final base64Image = base64Encode(bytes);
        await _analyzeProductForWeb(base64Image);
      } else {
        // 移动平台处理
        setState(() {
          _imageFile = File(image.path);
        });
        await _analyzeProduct(_imageFile!);
      }
    }
  }

  // 添加拍照并分析的方法
  Future<void> _takeAndAnalyzePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _pickedFile = photo;
      });

      if (kIsWeb) {
        // Web平台处理
        final bytes = await photo.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
        final base64Image = base64Encode(bytes);
        await _analyzeProductForWeb(base64Image);
      } else {
        // 移动平台处理
        setState(() {
          _imageFile = File(photo.path);
        });
        await _analyzeProduct(_imageFile!);
      }
    }
  }

  // 分析选中产品的成分冲突
  Future<void> _analyzeSelectedProductsConflicts() async {
    if (_selectedProducts.isEmpty || _selectedProducts.length < 2) {
      Get.snackbar(
        '提示',
        '请至少选择两个产品进行冲突分析',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 显示加载指示器
    Get.dialog(
      const Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      if (kIsWeb) {
        print("在Web平台上进行冲突分析");
      }

      // 转换选中的产品为ProductModel
      List<ProductModel> products = _selectedProducts.map((product) {
        // 创建成分模型
        List<IngredientModel> ingredients = (product['ingredients'] as List)
            .map(
              (ingredient) => IngredientModel(
                id: ingredient.hashCode.toString(),
                name: ingredient.toString(),
                safetyLevel: 50,
              ),
            )
            .toList();

        return ProductModel(
          id: '${product['name']}_${DateTime.now().millisecondsSinceEpoch}'
              .hashCode
              .toString(),
          name: product['name'].toString(),
          brandName: product['subtitle'].toString().split('，')[0],
          imageUrl: product['imageUrl'].toString(),
          description: product['subtitle'].toString(),
          category: product['type'].toString(),
          ingredients: ingredients,
        );
      }).toList();

      print("待分析产品数量: ${products.length}");
      print("产品详情: ${products.map((p) => p.name).join(', ')}");

      // 获取用户肌肤状态
      final skinCondition = await _getSkinCondition();

      // 调用API检测冲突
      final conflictResult = await AiService.detectConflicts(
        products,
        skinCondition,
      );

      print("冲突检测结果: $conflictResult");

      // 关闭加载指示器
      Get.back();

      // 显示结果
      _showConflictResultModal(conflictResult);
    } catch (e) {
      print("冲突分析过程中出错: $e");

      // 关闭加载指示器
      Get.back();

      Get.snackbar(
        '错误',
        '分析冲突时出错: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 显示冲突分析结果
  void _showConflictResultModal(String conflictResult) {
    // 提取分析结果中的产品信息
    List<Map<String, dynamic>> productsInfo = [];

    // 从选中的产品中提取信息
    for (var product in _selectedProducts) {
      productsInfo.add({
        'name': product['name'].toString(),
        'brand': product['subtitle'].toString().split('，')[0],
        'ingredients': product['ingredients'] ?? []
      });
    }

    // 导航到冲突分析结果页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConflictAnalysisDisplay(
          analysisResult: conflictResult,
          products: productsInfo,
        ),
      ),
    );
  }

  // 修改分析结果视图，处理Web平台和移动平台的图片显示差异
  Widget _buildAnalysisResultView() {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('正在分析产品成分...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectAndAnalyzeImage(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.sakuraPink500,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('重新选择图片'),
            ),
          ],
        ),
      );
    }

    if (_analyzedProduct != null && _aiAnalysisResult != null) {
      // 显示产品分析结果弹窗，但不影响页面显示
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_resultDialogShown) {
          _resultDialogShown = true;

          // 创建产品详情数据对象
          Map<String, dynamic> productData = {
            'id': _analyzedProduct!.id,
            'name': _analyzedProduct!.name,
            'brandName': _analyzedProduct!.brandName,
            'imageUrl': _analyzedProduct!.imageUrl,
            'description': _analyzedProduct!.description,
            'category': _analyzedProduct!.category,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'analysisResult': _aiAnalysisResult,
          };

          // 导航到产品结果显示页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductResultDisplay(productData: productData),
            ),
          );
        }
      });
    }

    // 默认显示产品库页面
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddNewProductCard(),
          _buildConflictDetectionButton(),
          _buildCategoryFilters(),
          ..._buildProductList(),
          _buildTodayRoutine(),
        ],
      ),
    );
  }

  // 生成成分分析文本
  String _generateIngredientAnalysis(List<IngredientModel> ingredients) {
    // 实现生成成分分析文本的逻辑
    // 这里可以根据实际情况调整
    return '成分分析文本生成逻辑';
  }

  // 在适当的位置添加调用冲突分析API的方法
  Future<void> _checkConflicts() async {
    if (_analyzedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先分析产品')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // 调用API获取冲突分析结果
      final apiService = ApiService();
      final response = await apiService.analyzeConflicts(_analyzedProduct!);

      setState(() {
        _isLoading = false;
      });

      if (response != null && response.containsKey('analysisResult')) {
        // 使用新的方法显示冲突分析结果弹窗
        showConflictAnalysisDialog(context, response['analysisResult']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法获取冲突分析结果')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('冲突分析失败: $e')),
      );
    }
  }

  // 添加在分析结果页面中添加冲突分析按钮的方法
  Widget _buildAnalysisActions() {
    return Column(
      children: [
        const SizedBox(height: 16),
        if (_analyzedProduct != null)
          ElevatedButton.icon(
            icon: const Icon(Icons.warning_amber_outlined),
            label: const Text('检测成分冲突'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[100],
              foregroundColor: Colors.amber[800],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            onPressed: _isLoading ? null : _checkConflicts,
          ),
        const SizedBox(height: 8),
        // 其他操作按钮...
      ],
    );
  }

  // 显示产品分析结果的对话框
  void showProductAnalysisDialog(
    BuildContext context, {
    required ProductModel product,
    required String analysisResult,
    Uint8List? imageBytes,
  }) {
    print("显示产品分析弹窗: ${product.name}");
    showDialog(
      context: context,
      barrierDismissible: false, // 防止点击空白处关闭弹窗
      builder: (BuildContext context) {
        return ProductAnalysisResult(
          analyzedProduct: product,
          aiAnalysisResult: analysisResult,
          webImageBytes: imageBytes,
        );
      },
    );
  }

  // 显示冲突分析结果的辅助函数
  void showConflictAnalysisDialog(BuildContext context, String analysisResult) {
    print("显示冲突分析弹窗");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('成分冲突分析'),
          content: SingleChildScrollView(
            child: Text(analysisResult),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}
