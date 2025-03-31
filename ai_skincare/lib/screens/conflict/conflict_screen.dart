import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product_model.dart';
import '../../models/ingredient_model.dart';
import '../../services/ai_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class ConflictScreen extends StatefulWidget {
  const ConflictScreen({super.key});

  @override
  _ConflictScreenState createState() => _ConflictScreenState();
}

class _ConflictScreenState extends State<ConflictScreen> {
  final List<ProductModel> _selectedProducts = [];
  bool _isAnalyzing = false;
  String? _conflictResult;
  String _errorMessage = '';

  // 模拟产品数据
  final List<ProductModel> _productList = [
    ProductModel(
      id: '1',
      name: 'COSRX 低pH洁面啫喱',
      brandName: 'COSRX',
      imageUrl:
          'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=100',
      description: '温和无泡洁面乳，氨基酸系',
      category: '洁面',
      ingredients: [
        IngredientModel(id: '1-1', name: '水', safetyLevel: 100),
        IngredientModel(id: '1-2', name: '甘油', safetyLevel: 90),
        IngredientModel(id: '1-3', name: '苯氧乙醇', safetyLevel: 60),
      ],
    ),
    ProductModel(
      id: '2',
      name: 'The Ordinary 维生素C精华',
      brandName: 'The Ordinary',
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=100',
      description: '高浓度抗氧化精华，美白提亮',
      category: '精华',
      ingredients: [
        IngredientModel(id: '2-1', name: '丙二醇', safetyLevel: 80),
        IngredientModel(id: '2-2', name: '维生素C', safetyLevel: 85),
        IngredientModel(id: '2-3', name: '透明质酸', safetyLevel: 95),
      ],
    ),
    ProductModel(
      id: '3',
      name: '理肤泉特安舒缓保湿霜',
      brandName: '理肤泉',
      imageUrl:
          'https://images.unsplash.com/photo-1601612628452-9e99ced43524?w=100',
      description: '舒缓敏感肌肤，深度保湿',
      category: '面霜',
      ingredients: [
        IngredientModel(id: '3-1', name: '水', safetyLevel: 100),
        IngredientModel(id: '3-2', name: '甘油', safetyLevel: 90),
        IngredientModel(id: '3-3', name: '矿物油', safetyLevel: 70),
        IngredientModel(id: '3-4', name: '烟酰胺', safetyLevel: 85),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成分冲突检测'),
        elevation: 0,
        actions: [
          if (_selectedProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _selectedProducts.clear();
                  _conflictResult = null;
                  _errorMessage = '';
                });
              },
              tooltip: '清空选择',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTopInfoCard(),
          _buildSelectedProductsList(),
          Expanded(
            child: _isAnalyzing
                ? _buildAnalyzingState()
                : _conflictResult != null
                    ? _buildConflictResult()
                    : _buildProductsList(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildTopInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '成分冲突检测',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '选择2个或更多产品，检测它们之间的成分是否存在相互作用或冲突。AI会分析成分之间的兼容性并提供使用建议。',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedProductsList() {
    if (_selectedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '已选择 ${_selectedProducts.length} 个产品',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _selectedProducts.length,
              itemBuilder: (context, index) {
                final product = _selectedProducts[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                image: DecorationImage(
                                  image: NetworkImage(product.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _selectedProducts.removeAt(index);
                              if (_selectedProducts.length < 2) {
                                _conflictResult = null;
                              }
                            });
                          },
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '选择要检测的产品',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (_selectedProducts.length >= 2)
                ElevatedButton(
                  onPressed: _analyzeConflicts,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('开始检测'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _productList.length,
            itemBuilder: (context, index) {
              final product = _productList[index];
              final isSelected = _selectedProducts.contains(product);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedProducts.remove(product);
                      } else {
                        _selectedProducts.add(product);
                      }

                      if (_selectedProducts.length < 2) {
                        _conflictResult = null;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(product.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.brandName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '成分: ${product.ingredients.map((i) => i.name).take(3).join(', ')}${product.ingredients.length > 3 ? '...' : ''}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedProducts.add(product);
                              } else {
                                _selectedProducts.remove(product);
                              }

                              if (_selectedProducts.length < 2) {
                                _conflictResult = null;
                              }
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            '正在分析产品成分冲突',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '分析 ${_selectedProducts.length} 个产品中的 ${_selectedProducts.fold<int>(0, (sum, product) => sum + product.ingredients.length)} 种成分',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          const Text(
            'AI正在进行成分分析，请稍候...',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictResult() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _analyzeConflicts,
              child: const Text('重新检测'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '分析结果',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(_conflictResult ?? ''),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedProducts.clear();
                _conflictResult = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重新选择产品'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeConflicts() async {
    if (_selectedProducts.length < 2) {
      setState(() {
        _errorMessage = '请至少选择2个产品进行检测';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
      _conflictResult = null;
    });

    try {
      // 获取用户肌肤状态
      final skinCondition = await _getSkinCondition();

      // 调用AI服务进行冲突检测
      final result = await AiService.detectConflicts(
        _selectedProducts,
        skinCondition,
      );

      setState(() {
        _conflictResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '分析过程中出错: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _getSkinCondition() async {
    // 示例数据，实际应用中应从用户配置中获取
    return {
      'hydration': 60,
      'oil': 50,
      'sensitivity': 30,
      'concerns': ['痘痘', '干燥'],
    };
  }
}
