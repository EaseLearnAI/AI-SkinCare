import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class ConflictScreen extends StatefulWidget {
  const ConflictScreen({Key? key}) : super(key: key);

  @override
  _ConflictScreenState createState() => _ConflictScreenState();
}

class _ConflictScreenState extends State<ConflictScreen> {
  // 成分选择状态
  final List<String> _selectedIngredients = [];

  // 模拟成分数据
  final List<Map<String, dynamic>> _ingredients = [
    {
      'id': '1',
      'name': '烟酰胺',
      'alias': 'Niacinamide',
      'category': '维生素类',
      'imagePath': 'assets/images/ingredients/niacinamide.jpg',
    },
    {
      'id': '2',
      'name': '维生素C',
      'alias': 'Vitamin C',
      'category': '维生素类',
      'imagePath': 'assets/images/ingredients/vitamin_c.jpg',
    },
    {
      'id': '3',
      'name': '视黄醇',
      'alias': 'Retinol',
      'category': '维生素类',
      'imagePath': 'assets/images/ingredients/retinol.jpg',
    },
    {
      'id': '4',
      'name': '水杨酸',
      'alias': 'Salicylic Acid',
      'category': '酸类',
      'imagePath': 'assets/images/ingredients/salicylic_acid.jpg',
    },
    {
      'id': '5',
      'name': '果酸',
      'alias': 'AHA',
      'category': '酸类',
      'imagePath': 'assets/images/ingredients/aha.jpg',
    },
    {
      'id': '6',
      'name': '透明质酸',
      'alias': 'Hyaluronic Acid',
      'category': '保湿剂',
      'imagePath': 'assets/images/ingredients/hyaluronic_acid.jpg',
    },
    {
      'id': '7',
      'name': '神经酰胺',
      'alias': 'Ceramide',
      'category': '保湿剂',
      'imagePath': 'assets/images/ingredients/ceramide.jpg',
    },
    {
      'id': '8',
      'name': '矿物油',
      'alias': 'Mineral Oil',
      'category': '封闭剂',
      'imagePath': 'assets/images/ingredients/mineral_oil.jpg',
    },
  ];

  // 模拟冲突数据
  final Map<String, Map<String, dynamic>> _conflicts = {
    '烟酰胺+维生素C': {
      'level': 'moderate',
      'description': '烟酰胺和维生素C在一定条件下可能相互影响功效。',
      'solution': '建议间隔10-15分钟使用，或在不同的护肤步骤中使用。',
      'ingredients': ['烟酰胺', '维生素C'],
    },
    '视黄醇+果酸': {
      'level': 'high',
      'description': '同时使用可能导致严重刺激和皮肤屏障受损。',
      'solution': '建议在不同的日期使用，或咨询皮肤科医生获取专业建议。',
      'ingredients': ['视黄醇', '果酸'],
    },
    '视黄醇+水杨酸': {
      'level': 'high',
      'description': '同时使用可能导致过度刺激和红肿。',
      'solution': '建议在不同的日期使用，或在专业指导下使用低浓度产品。',
      'ingredients': ['视黄醇', '水杨酸'],
    },
    '矿物油+其他': {
      'level': 'info',
      'description': '矿物油会形成封闭层，可能阻碍其他有效成分的吸收。',
      'solution': '建议在其他护肤品完全吸收后再使用含矿物油的产品。',
      'ingredients': ['矿物油'],
    },
  };

  // 分析结果状态
  bool _isAnalyzed = false;
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _analysisResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('成分冲突检测'),
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
                '查看冲突检测历史',
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
      body:
          _isAnalyzing
              ? _buildAnalyzingState()
              : _isAnalyzed
              ? _buildAnalysisResults()
              : _buildIngredientSelection(),
      // 底部导航栏
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  // 构建成分选择界面
  Widget _buildIngredientSelection() {
    return Column(
      children: [
        // 顶部提示信息
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.sakuraPink100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.science_outlined,
                      color: AppTheme.sakuraPink500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '成分冲突检测工具',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '选择您想要检测的护肤成分，系统将自动分析它们之间是否存在潜在冲突，并提供使用建议。',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFFFB300),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '请注意：此工具提供的分析仅供参考，具体使用情况还应考虑您的肤质和产品配方。',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF996600),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 已选择成分提示
        if (_selectedIngredients.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF0F0F0),
            child: Row(
              children: [
                Text(
                  '已选择 ${_selectedIngredients.length} 个成分',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIngredients.clear();
                    });
                  },
                  child: const Text('清空选择'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.sakuraPink500,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 成分列表
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = _ingredients[index];
              final isSelected = _selectedIngredients.contains(
                ingredient['name'],
              );

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedIngredients.remove(ingredient['name']);
                    } else {
                      _selectedIngredients.add(ingredient['name']);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppTheme.sakuraPink500
                              : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ingredient['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ingredient['alias'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ingredient['category'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 选中标记
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppTheme.sakuraPink500,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 底部分析按钮
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -2),
                blurRadius: 5,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedIngredients.length >= 2
                        ? () {
                          _startAnalysis();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.sakuraPink500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _selectedIngredients.length < 2
                      ? '请至少选择2个成分'
                      : '开始分析 (${_selectedIngredients.length}个成分)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建分析中状态
  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.sakuraPink200.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.sakuraPink500,
                  ),
                  backgroundColor: AppTheme.sakuraPink100,
                  strokeWidth: 6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'AI正在分析成分冲突',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '正在检测 ${_selectedIngredients.length} 个成分之间的潜在冲突...',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Text(
              '分析过程可能需要几秒钟时间',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }

  // 构建分析结果
  Widget _buildAnalysisResults() {
    return Column(
      children: [
        // 结果摘要
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.sakuraPink100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.science_outlined,
                      color: AppTheme.sakuraPink500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '分析结果',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 已分析的成分标签
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _selectedIngredients.map((ingredient) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.sakuraPink50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.sakuraPink200),
                        ),
                        child: Text(
                          ingredient,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.sakuraPink700,
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 16),

              // 冲突摘要
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _analysisResults.isEmpty
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _analysisResults.isEmpty
                            ? Colors.green.shade300
                            : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _analysisResults.isEmpty
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_outlined,
                      color:
                          _analysisResults.isEmpty
                              ? Colors.green
                              : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _analysisResults.isEmpty
                            ? '未检测到成分冲突，这些成分可以安全搭配使用。'
                            : '检测到 ${_analysisResults.length} 处成分冲突，请查看详细说明。',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              _analysisResults.isEmpty
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 详细结果列表
        Expanded(
          child:
              _analysisResults.isEmpty
                  ? _buildEmptyResult()
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _analysisResults.length,
                    itemBuilder: (context, index) {
                      final result = _analysisResults[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 冲突头部
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _getConflictHeaderColor(result['level']),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getConflictIcon(result['level']),
                                    color: _getConflictIconColor(
                                      result['level'],
                                    ),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (result['ingredients'] as List).join(
                                            ' + ',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getConflictLevelText(
                                            result['level'],
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _getConflictIconColor(
                                              result['level'],
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 冲突详情
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '冲突说明',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    result['description'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    '使用建议',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    result['solution'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),

        // 底部按钮
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -2),
                blurRadius: 5,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isAnalyzed = false;
                        _isAnalyzing = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.sakuraPink500,
                      side: BorderSide(color: AppTheme.sakuraPink500),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('重新选择'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 保存分析结果
                      Get.snackbar(
                        '保存成功',
                        '分析结果已保存至历史记录',
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('保存结果'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建空结果视图
  Widget _buildEmptyResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '这些成分可以安全搭配使用',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '我们没有检测到所选成分之间存在已知的冲突或不兼容问题，你可以放心搭配使用。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  '使用建议',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '即使成分相互兼容，也建议在日常护肤中遵循由薄到厚、质地轻到重的顺序使用产品，这样有助于最大化各成分的功效。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 开始分析
  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });

    // 模拟分析过程
    Future.delayed(const Duration(seconds: 3), () {
      // 查找可能的冲突
      _analysisResults = [];

      _conflicts.forEach((key, conflict) {
        final conflictIngredients = List<String>.from(conflict['ingredients']);
        bool hasConflict = true;

        for (final ingredient in conflictIngredients) {
          if (!_selectedIngredients.contains(ingredient)) {
            hasConflict = false;
            break;
          }
        }

        // 特殊处理矿物油冲突
        if (key == '矿物油+其他' &&
            _selectedIngredients.contains('矿物油') &&
            _selectedIngredients.length > 1) {
          hasConflict = true;
        }

        if (hasConflict) {
          _analysisResults.add({
            'level': conflict['level'],
            'description': conflict['description'],
            'solution': conflict['solution'],
            'ingredients': conflictIngredients,
          });
        }
      });

      setState(() {
        _isAnalyzing = false;
        _isAnalyzed = true;
      });
    });
  }

  // 获取冲突等级对应的图标
  IconData _getConflictIcon(String level) {
    switch (level) {
      case 'high':
        return Icons.error_outline;
      case 'moderate':
        return Icons.warning_amber_outlined;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.info_outline;
    }
  }

  // 获取冲突等级对应的图标颜色
  Color _getConflictIconColor(String level) {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  // 获取冲突等级对应的文本
  String _getConflictLevelText(String level) {
    switch (level) {
      case 'high':
        return '严重冲突';
      case 'moderate':
        return '中度冲突';
      case 'info':
        return '使用提示';
      default:
        return '使用提示';
    }
  }

  // 获取冲突等级对应的头部背景色
  Color _getConflictHeaderColor(String level) {
    switch (level) {
      case 'high':
        return const Color(0xFFFFEBEE);
      case 'moderate':
        return const Color(0xFFFFF3E0);
      case 'info':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE3F2FD);
    }
  }
}
