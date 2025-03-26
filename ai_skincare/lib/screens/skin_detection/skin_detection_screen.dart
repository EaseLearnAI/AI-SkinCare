import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import '../../themes/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class SkinDetectionScreen extends StatefulWidget {
  const SkinDetectionScreen({Key? key}) : super(key: key);

  @override
  _SkinDetectionScreenState createState() => _SkinDetectionScreenState();
}

class _SkinDetectionScreenState extends State<SkinDetectionScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _showQuiz = false;
  Timer? _analysisTimer;
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  // 肌肤测试问卷问题
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': '你的皮肤类型是什么？',
      'options': ['干性', '油性', '混合型', '中性', '敏感性'],
      'selected': null,
    },
    {
      'question': '你目前有哪些肌肤问题？',
      'options': ['毛孔粗大', '暗沉', '痘痘', '细纹', '无明显问题'],
      'multiSelect': true,
      'selected': <String>[],
    },
    {
      'question': '你的肌肤平时是否容易过敏？',
      'options': ['经常', '偶尔', '很少', '从不'],
      'selected': null,
    },
  ];

  // 分析结果数据
  final Map<String, dynamic> _analysisResults = {
    'hydration': {
      'value': 75,
      'status': '皮肤水分充足，继续保持喵～',
      'trend': '+5%',
      'trendUp': true,
    },
    'oil': {'value': 60, 'status': 'T区油分略偏高，建议使用控油产品喵～'},
    'sensitivity': {'value': 2, 'maxValue': 5, 'status': '轻度敏感，建议使用温和产品喵～'},
  };

  // AI建议数据
  final List<Map<String, dynamic>> _recommendations = [
    {
      'title': '加强保湿防护',
      'description': '建议使用含玻尿酸的保湿精华，提升肌肤水润度',
      'icon': Icons.shield_outlined,
      'priority': '优先级高',
      'timing': '建议立即使用',
    },
    {'title': '防晒提醒', 'description': '今日紫外线较强，记得涂防晒喵～', 'icon': Icons.wb_sunny},
    {'title': '护理时间表', 'description': '查看今日护理时间安排', 'icon': Icons.access_time},
  ];

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scanAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _analysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FB), // AppTheme.sakuraPink100
      appBar: AppBar(
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, size: 18),
            SizedBox(width: 8),
            Text('肌肤检测'),
          ],
        ),
        backgroundColor: AppTheme.sakuraPink500,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
        ],
      ),
      body:
          _isAnalyzing
              ? _buildAnalyzingState()
              : _showQuiz
              ? _buildSkinQuiz()
              : _buildInitialState(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  // 初始状态 - 选择图片或拍照
  Widget _buildInitialState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 主要内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 相机区域
                _buildCameraArea(),

                const SizedBox(height: 24),

                // 分析结果区域
                _buildAnalysisResultsArea(),

                const SizedBox(height: 24),

                // AI建议区域
                _buildAIRecommendationsArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 相机区域
  Widget _buildCameraArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 相机预览区域
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[400]!, Colors.purple[400]!],
              ),
            ),
            child: Stack(
              children: [
                // 相机预览内容
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                // 扫描动画层
                AnimatedBuilder(
                  animation: _scanAnimationController,
                  builder: (context, child) {
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: _scanAnimation.value * 200,
                      height: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.sakuraPink500,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 猫咪图标和文字层
                if (_selectedImage == null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFloatingImage(),
                        const SizedBox(height: 8),
                        const Text(
                          '让我来看看你的肌肤状态喵～',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                // 扫描边框
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),

                // 底部阴影渐变
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 相机按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _captureImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sakuraPink500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照检测'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.image),
                  label: const Text('从相册选择'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 浮动图片效果（猫咪图标）
  Widget _buildFloatingImage() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -10 * sin(value * 3.14 * 2)),
          child: child,
        );
      },
      child: Image.network(
        'https://i.imgur.com/QkIa5tS.png',
        width: 100,
        height: 100,
      ),
    );
  }

  // 分析中状态
  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 脉动光环效果
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.sakuraPink200.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.sakuraPink500,
                  ),
                  strokeWidth: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'AI正在分析您的肌肤...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '我们正在检测多项肌肤指标,请稍候...',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),
          Column(
            children: [
              _buildAnalysisStep('检测肤质类型', true),
              _buildAnalysisStep('检测肌肤水分', true),
              _buildAnalysisStep('检测毛孔状况', true),
              _buildAnalysisStep('检测肌肤敏感度', false),
              _buildAnalysisStep('生成个性化建议', false),
            ],
          ),
        ],
      ),
    );
  }

  // 分析步骤
  Widget _buildAnalysisStep(String step, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: completed ? AppTheme.sakuraPink500 : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                completed ? Icons.check : Icons.hourglass_empty,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            step,
            style: TextStyle(
              fontSize: 14,
              fontWeight: completed ? FontWeight.w500 : FontWeight.normal,
              color: completed ? AppTheme.sakuraPink500 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 肌肤测试问卷
  Widget _buildSkinQuiz() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.sakuraPink100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.sakuraPink500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '肌肤测试问卷',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '请回答以下问题，帮助我们更准确地了解您的肌肤状况。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 问卷问题
          ...List.generate(_quizQuestions.length, (index) {
            final question = _quizQuestions[index];
            return _buildQuizQuestion(index, question);
          }),

          const SizedBox(height: 24),

          // 提交按钮
          ElevatedButton(
            onPressed:
                _isQuizValid()
                    ? () {
                      setState(() {
                        _isAnalyzing = true;
                        _showQuiz = false;
                      });

                      // 模拟分析过程
                      _analysisTimer = Timer(const Duration(seconds: 3), () {
                        // 处理问卷分析结果
                        Get.toNamed('/skin_result');
                      });
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sakuraPink500,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('提交问卷', style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 16),

          // 返回按钮
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showQuiz = false;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('返回上一步', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // 构建问卷问题
  Widget _buildQuizQuestion(int index, Map<String, dynamic> question) {
    final isMultiSelect = question['multiSelect'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Q${index + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.sakuraPink500,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question['question'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate((question['options'] as List).length, (
            optionIndex,
          ) {
            final option = question['options'][optionIndex];
            bool isSelected = false;

            if (isMultiSelect) {
              isSelected = (question['selected'] as List<String>).contains(
                option,
              );
            } else {
              isSelected = question['selected'] == option;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isMultiSelect) {
                    final selectedList = question['selected'] as List<String>;
                    if (isSelected) {
                      selectedList.remove(option);
                    } else {
                      selectedList.add(option);
                    }
                  } else {
                    _quizQuestions[index]['selected'] = option;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.sakuraPink100 : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.sakuraPink500 : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.sakuraPink500,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      option,
                      style: TextStyle(
                        color:
                            isSelected
                                ? AppTheme.sakuraPink500
                                : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // 检查问卷是否有效
  bool _isQuizValid() {
    bool isValid = true;

    for (final question in _quizQuestions) {
      final isMultiSelect = question['multiSelect'] ?? false;

      if (isMultiSelect) {
        final selectedList = question['selected'] as List<String>;
        if (selectedList.isEmpty) {
          isValid = false;
          break;
        }
      } else {
        if (question['selected'] == null) {
          isValid = false;
          break;
        }
      }
    }

    return isValid;
  }

  // 分析结果区域
  Widget _buildAnalysisResultsArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: const [
              Text('🔍', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                '今日肌肤状态',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 水分状态卡片
          _buildHydrationCard(),

          const SizedBox(height: 16),

          // 油分状态卡片
          _buildOilCard(),

          const SizedBox(height: 16),

          // 敏感程度卡片
          _buildSensitivityCard(),
        ],
      ),
    );
  }

  // 水分状态卡片
  Widget _buildHydrationCard() {
    final hydrationData = _analysisResults['hydration'] as Map<String, dynamic>;
    final double hydrationValue = hydrationData['value'].toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进度环
          SizedBox(
            width: 60,
            height: 60,
            child: CustomPaint(
              painter: ProgressRingPainter(
                progress: hydrationValue / 100,
                baseColor: Colors.blue[100]!,
                progressColor: Colors.blue[500]!,
                strokeWidth: 4,
              ),
              child: Center(
                child: Text(
                  '${hydrationValue.toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[500],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 18, color: Colors.blue[500]),
                    const SizedBox(width: 8),
                    const Text(
                      '水分状态',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hydrationData['status'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      hydrationData['trendUp']
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 14,
                      color: Colors.blue[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '较昨日${hydrationData['trend']}',
                      style: TextStyle(fontSize: 12, color: Colors.blue[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 油分状态卡片
  Widget _buildOilCard() {
    final oilData = _analysisResults['oil'] as Map<String, dynamic>;
    final double oilValue = oilData['value'].toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.oil_barrel, size: 18, color: Colors.yellow[700]),
                  const SizedBox(width: 8),
                  const Text(
                    '油分状态',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                '${oilValue.toInt()}%',
                style: TextStyle(fontSize: 12, color: Colors.yellow[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: oilValue / 100,
              backgroundColor: Colors.yellow[100],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[400]!),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            oilData['status'],
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // 敏感程度卡片
  Widget _buildSensitivityCard() {
    final sensitivityData =
        _analysisResults['sensitivity'] as Map<String, dynamic>;
    final int sensitivityValue = sensitivityData['value'] as int;
    final int maxValue = sensitivityData['maxValue'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.red[500],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '敏感程度',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              // 花瓣进度指示器
              Row(
                children: List.generate(maxValue, (index) {
                  final isActive = index < sensitivityValue;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Transform.rotate(
                      angle: pi / 4,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          color:
                              isActive
                                  ? AppTheme.sakuraPink500
                                  : AppTheme.sakuraPink500.withOpacity(0.3),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sensitivityData['status'],
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // AI建议区域
  Widget _buildAIRecommendationsArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: const [
              Text('🐱', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                '猫咪的护理建议',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 建议卡片列表
          ...List.generate(_recommendations.length, (index) {
            final recommendation = _recommendations[index];

            // 主要建议卡片（较大）
            if (index == 0) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.sakuraPink100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图标
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.sakuraPink300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        recommendation['icon'],
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 内容
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                recommendation['title'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              _buildPriorityTag(recommendation['priority']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: AppTheme.sakuraPink500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    recommendation['timing'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.sakuraPink500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '查看推荐产品',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.sakuraPink500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // 次要建议卡片（较小）
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.sakuraPink100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.sakuraPink300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      recommendation['icon'],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recommendation['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.sakuraPink500),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 优先级标签
  Widget _buildPriorityTag(String? priority) {
    if (priority == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.sakuraPink200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        priority,
        style: TextStyle(fontSize: 10, color: AppTheme.sakuraPink700),
      ),
    );
  }

  // 拍照
  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      // 处理相机权限等错误
      Get.snackbar(
        '错误',
        '无法访问相机，请检查应用权限设置',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  // 从相册选择
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      // 处理相册权限等错误
      Get.snackbar(
        '错误',
        '无法访问相册，请检查应用权限设置',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  // 开始分析
  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });

    // 模拟分析过程
    _analysisTimer = Timer(const Duration(seconds: 3), () {
      // 这里应该是调用API进行实际分析
      // 分析完成后，转到结果页面
      Get.toNamed('/skin_result');
    });
  }
}

// 进度环绘制器
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color progressColor;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 绘制底环
    final basePaint =
        Paint()
          ..color = baseColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    // 绘制进度环
    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // 计算起始和结束角度（进度环从顶部开始，逆时针方向）
    const startAngle = -pi / 2; // 从上方开始
    final sweepAngle = 2 * pi * progress; // 扫过的角度

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
