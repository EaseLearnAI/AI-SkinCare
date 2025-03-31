import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import '../../themes/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/api_service.dart';
import '../../models/skin_analysis_model.dart';
import 'package:intl/intl.dart';

// Face++ API 相关常量
const String FACE_API_URL =
    'https://api-cn.faceplusplus.com/facepp/v1/skinanalyze';
const String FACE_API_KEY = 'bzBP-J0iqepLNuTCLDg6jb0dd2z2nwX3';
const String FACE_API_SECRET =
    'nBpdQtFsLK9MPg4OTjL1T_3JzQITRig7'; // 使用文档中的Secret

class SkinDetectionScreen extends StatefulWidget {
  const SkinDetectionScreen({super.key});

  @override
  _SkinDetectionScreenState createState() => _SkinDetectionScreenState();
}

class _SkinDetectionScreenState extends State<SkinDetectionScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _webImageBytes;
  bool _isAnalyzing = false;
  bool _showQuiz = false;
  Timer? _analysisTimer;
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  // 分析结果相关
  Map<String, dynamic>? _analysisResult;
  bool _showAnalysisResult = false;
  String? _errorMessage;

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
    {'title': '护理时间表', 'description': '查看今日护理安排', 'icon': Icons.access_time},
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
      body: _isAnalyzing
          ? _buildAnalyzingState()
          : _showAnalysisResult
              ? _buildAnalysisResultState()
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 220,
      child: _selectedImage != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImageWidget(_selectedImage!),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedImage = null;
                        _webImageBytes = null;
                        _isAnalyzing = false;
                        _analysisResult = null;
                        _errorMessage = null;
                        _showAnalysisResult = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.face,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '让我来看看你的肌肤状态吧~',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _captureImage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('拍照检测'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _pickImage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('从相册选择'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // 添加一个兼容Web平台的图片显示组件
  Widget _buildImageWidget(File imageFile) {
    // 在Web平台上，使用内存中的图像数据
    if (kIsWeb) {
      if (_webImageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            _webImageBytes!,
            width: double.infinity,
            height: 300, // 添加固定高度避免无限大小错误
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          height: 300, // 添加固定高度
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    } else {
      // 在移动平台上使用File
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          imageFile,
          width: double.infinity,
          height: 300, // 添加固定高度避免无限大小错误
          fit: BoxFit.cover,
        ),
      );
    }
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
            onPressed: _isQuizValid()
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
                        color: isSelected
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
                          color: isActive
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

  // 相册选择图片
  void _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (pickedImage == null) return;

      if (kIsWeb) {
        try {
          _webImageBytes = await pickedImage.readAsBytes();
          print('Web平台: 已读取图片数据，大小 ${_webImageBytes!.length} 字节');

          setState(() {
            _selectedImage = File(pickedImage.path);
            _showAnalysisResult = false; // 重置分析结果显示状态
            _errorMessage = null;
          });

          // 自动开始分析
          print('Web平台: 自动开始分析');
          _startAnalysis();
        } catch (e) {
          print('Web平台读取图片失败: $e');
          Get.snackbar(
            '警告',
            '图片读取遇到问题，请尝试选择其他图片',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() {
          _selectedImage = File(pickedImage.path);
          _showAnalysisResult = false;
          _errorMessage = null;
        });
        print('移动平台: 已选择图片，路径 ${pickedImage.path}');

        // 自动开始分析
        print('移动平台: 自动开始分析');
        _startAnalysis();
      }
    } catch (e) {
      print('选择图片失败: $e');
      Get.snackbar(
        '错误',
        '无法选择图片: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 拍照获取图片
  void _captureImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (pickedImage == null) return;

      if (kIsWeb) {
        try {
          _webImageBytes = await pickedImage.readAsBytes();
          print('Web平台: 已拍摄图片，数据大小 ${_webImageBytes!.length} 字节');

          setState(() {
            _selectedImage = File(pickedImage.path);
            _showAnalysisResult = false; // 重置分析结果显示状态
            _errorMessage = null;
          });

          // 自动开始分析
          print('Web平台: 自动开始分析');
          _startAnalysis();
        } catch (e) {
          print('Web平台读取拍照图片失败: $e');
          Get.snackbar(
            '警告',
            '图片处理遇到问题，请重试',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() {
          _selectedImage = File(pickedImage.path);
          _showAnalysisResult = false;
          _errorMessage = null;
        });
        print('移动平台: 已拍摄图片，路径 ${pickedImage.path}');

        // 自动开始分析
        print('移动平台: 自动开始分析');
        _startAnalysis();
      }
    } catch (e) {
      print('拍照失败: $e');
      Get.snackbar(
        '错误',
        '无法拍照: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 开始分析
  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
      _errorMessage = null;
      _showAnalysisResult = false;
    });

    try {
      if (_selectedImage == null && _webImageBytes == null) {
        throw '请先选择或拍摄一张照片';
      }

      print('开始分析肌肤状态');

      // Web平台上，因为CORS限制，我们无法直接调用Face++ API
      // 使用模拟数据来展示功能
      if (kIsWeb) {
        print('Web平台: 使用模拟数据展示功能');

        // 模拟API调用延迟
        await Future.delayed(const Duration(seconds: 2));

        // 创建模拟响应数据
        final skinAnalysisData = _generateSimulatedResults();

        // 处理模拟数据
        final result = _processFacePlusPlusResult(skinAnalysisData);

        // 打印详细分析结果供终端查看
        _printAnalysisResultToConsole(result);

        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
          _showAnalysisResult = true;
        });

        // 尝试保存到后端（虽然Web平台会跳过实际保存）
        await _saveAnalysisResult(result);
        return;
      }

      // 移动平台 - 实际调用Face++ API
      try {
        print('准备调用Face++ API (multipart/form-data)');

        // 准备二进制图片数据
        Uint8List imageBytes = await _selectedImage!.readAsBytes();
        print('移动平台: 已准备好图片数据，大小 ${imageBytes.length} 字节');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(FACE_API_URL),
        );

        // 添加API Key和Secret
        request.fields['api_key'] = FACE_API_KEY;
        request.fields['api_secret'] = FACE_API_SECRET;

        // 添加图片文件 - 使用正确的字段名'image_file'
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_file',
            imageBytes,
            filename: 'face_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        print('已创建multipart请求，准备发送...');

        // 发送请求
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('请求超时');
          },
        );

        // 获取响应内容
        final response = await http.Response.fromStream(streamedResponse);
        print('Face++ API响应状态码: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Face++ API响应数据: $data');

          if (data['error_message'] != null) {
            throw '分析失败: ${data['error_message']}';
          }

          // 处理Face++返回的数据
          final result = _processFacePlusPlusResult(data);

          // 打印详细分析结果供终端查看
          _printAnalysisResultToConsole(result);

          setState(() {
            _analysisResult = result;
            _isAnalyzing = false;
            _showAnalysisResult = true;
          });

          // 保存分析结果到后端
          await _saveAnalysisResult(result);
          return;
        } else {
          print(
              'Face++ API请求失败，状态码: ${response.statusCode}，响应内容: ${response.body}');

          // 使用模拟数据作为后备方案
          print('使用模拟数据作为后备方案');
          final skinAnalysisData = _generateSimulatedResults();
          final result = _processFacePlusPlusResult(skinAnalysisData);

          _printAnalysisResultToConsole(result);

          setState(() {
            _analysisResult = result;
            _isAnalyzing = false;
            _showAnalysisResult = true;
          });

          // 保存分析结果到后端，带有API失败标记
          result['apiCallFailed'] = true;
          result['apiErrorCode'] = response.statusCode;
          await _saveAnalysisResult(result);

          // 显示提示信息
          Get.snackbar(
            '提示',
            'API调用失败，显示模拟数据',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );

          return;
        }
      } catch (e) {
        print('Face++ API调用失败，错误: $e');

        // 使用模拟数据作为后备方案
        print('使用模拟数据作为后备方案');
        final skinAnalysisData = _generateSimulatedResults();
        final result = _processFacePlusPlusResult(skinAnalysisData);

        _printAnalysisResultToConsole(result);

        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
          _showAnalysisResult = true;
        });

        // 保存分析结果到后端，带有API异常标记
        result['apiCallFailed'] = true;
        result['apiErrorMessage'] = e.toString();
        await _saveAnalysisResult(result);

        // 显示提示信息
        Get.snackbar(
          '提示',
          'API调用出错，显示模拟数据: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );

        return;
      }
    } catch (e) {
      print('分析出错: $e');
      setState(() {
        _errorMessage = e.toString();
        _isAnalyzing = false;
        _showAnalysisResult = false;
      });

      Get.snackbar(
        '分析失败',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  // 生成模拟数据供Web平台使用
  Map<String, dynamic> _generateSimulatedResults() {
    return {
      'time_used': 462,
      'request_id': 'web_simulated_${DateTime.now().millisecondsSinceEpoch}',
      'moisture': 75.0,
      'oiliness': 60.0,
      'health': 60,
      'acne': {'value': '1', 'confidence': 0.92},
      'dark_circle': {'value': '1', 'confidence': 0.85},
      'blackhead': {'value': '1', 'confidence': 0.88},
      'skin_type': 2, // 2表示中性皮肤
      'pores_forehead': {'value': '1', 'confidence': 0.90},
      'pores_left_cheek': {'value': '1', 'confidence': 0.90},
      'pores_right_cheek': {'value': '1', 'confidence': 0.90},
      'wrinkle': 35.0,
      'skin_spot': {'value': '1', 'confidence': 0.82}
    };
  }

  // 处理Face++返回的数据，转换为应用需要的格式
  Map<String, dynamic> _processFacePlusPlusResult(
      Map<String, dynamic> rawData) {
    // 解析肤质类型
    String skinType = '未知';
    if (rawData.containsKey('skin_type')) {
      int skinTypeValue = rawData['skin_type'] is int
          ? rawData['skin_type']
          : int.tryParse(rawData['skin_type'].toString()) ?? 0;

      switch (skinTypeValue) {
        case 0:
          skinType = '油性皮肤';
          break;
        case 1:
          skinType = '干性皮肤';
          break;
        case 2:
          skinType = '中性皮肤';
          break;
        case 3:
          skinType = '混合性皮肤';
          break;
      }
    }

    // 计算水分值
    double moisture = 50.0; // 默认值
    if (rawData.containsKey('moisture')) {
      moisture = rawData['moisture'] is double
          ? rawData['moisture']
          : double.tryParse(rawData['moisture'].toString()) ?? 50.0;
    }

    // 计算油分值
    double oiliness = 50.0; // 默认值
    if (rawData.containsKey('oiliness')) {
      oiliness = rawData['oiliness'] is double
          ? rawData['oiliness']
          : double.tryParse(rawData['oiliness'].toString()) ?? 50.0;
    }

    // 提取肌肤问题
    List<Map<String, dynamic>> issues = [];

    // 检查痘痘
    if (rawData.containsKey('acne') &&
        rawData['acne'] is Map &&
        rawData['acne']['value'] == '1') {
      issues
          .add({'name': '痘痘', 'value': 70.0, 'severity': '轻微', 'key': 'acne'});
    }

    // 检查黑眼圈
    if (rawData.containsKey('dark_circle') &&
        rawData['dark_circle'] is Map &&
        rawData['dark_circle']['value'] == '1') {
      issues.add({
        'name': '黑眼圈',
        'value': 65.0,
        'severity': '轻微',
        'key': 'dark_circle'
      });
    }

    // 检查毛孔
    bool hasPoreIssue = false;
    if (rawData.containsKey('pores_forehead') &&
        rawData['pores_forehead'] is Map &&
        rawData['pores_forehead']['value'] == '1') {
      hasPoreIssue = true;
    }
    if (rawData.containsKey('pores_left_cheek') &&
        rawData['pores_left_cheek'] is Map &&
        rawData['pores_left_cheek']['value'] == '1') {
      hasPoreIssue = true;
    }
    if (rawData.containsKey('pores_right_cheek') &&
        rawData['pores_right_cheek'] is Map &&
        rawData['pores_right_cheek']['value'] == '1') {
      hasPoreIssue = true;
    }
    if (hasPoreIssue) {
      issues.add(
          {'name': '毛孔粗大', 'value': 60.0, 'severity': '轻微', 'key': 'pores'});
    }

    // 检查黑头
    if (rawData.containsKey('blackhead') &&
        rawData['blackhead'] is Map &&
        rawData['blackhead']['value'] == '1') {
      issues.add(
          {'name': '黑头', 'value': 55.0, 'severity': '轻微', 'key': 'blackhead'});
    }

    // 检查皱纹
    if (rawData.containsKey('wrinkle')) {
      double wrinkleValue = rawData['wrinkle'] is double
          ? rawData['wrinkle']
          : double.tryParse(rawData['wrinkle'].toString()) ?? 0.0;

      if (wrinkleValue > 30) {
        issues.add({
          'name': '皱纹',
          'value': wrinkleValue,
          'severity': wrinkleValue > 60 ? '严重' : '轻微',
          'key': 'wrinkle'
        });
      }
    }

    // 检查斑点
    if (rawData.containsKey('skin_spot') &&
        rawData['skin_spot'] is Map &&
        rawData['skin_spot']['value'] == '1') {
      issues
          .add({'name': '斑点', 'value': 50.0, 'severity': '轻微', 'key': 'spot'});
    }

    // 如果水分低于标准，添加为一个问题
    if (moisture < 40) {
      issues.add({
        'name': '水分不足',
        'value': moisture,
        'severity': moisture < 30 ? '严重' : '轻微',
        'key': 'moisture'
      });
    }

    // 如果油分过高，添加为一个问题
    if (oiliness > 70) {
      issues.add({
        'name': '油分过多',
        'value': oiliness,
        'severity': oiliness > 80 ? '严重' : '轻微',
        'key': 'oiliness'
      });
    }

    // 计算健康得分
    int healthScore =
        _calculateHealthScoreFromIssues(issues, moisture, oiliness);

    // 生成护肤建议
    List<String> recommendations =
        _generateRecommendationsFromIssues(issues, skinType);

    // 构建最终结果
    return {
      'skin_type': skinType,
      'health_score': healthScore,
      'issues': issues,
      'recommendations': recommendations,
      'detailed_metrics': {
        'moisture': moisture,
        'oiliness': oiliness,
      }
    };
  }

  // 根据问题计算健康得分
  int _calculateHealthScoreFromIssues(
      List<Map<String, dynamic>> issues, double moisture, double oiliness) {
    // 基础分数为80分
    int score = 80;

    // 根据问题数量和严重程度减分
    for (var issue in issues) {
      if (issue['severity'] == '严重') {
        score -= 10;
      } else {
        score -= 5;
      }
    }

    // 根据水分和油分调整分数
    if (moisture > 60) score += 5;
    if (moisture < 30) score -= 5;

    if (oiliness > 80) score -= 5;
    if (oiliness < 20) score -= 5;
    if (oiliness >= 40 && oiliness <= 60) score += 5;

    // 确保分数在0-100之间
    return score.clamp(0, 100);
  }

  // 根据问题生成护肤建议
  List<String> _generateRecommendationsFromIssues(
      List<Map<String, dynamic>> issues, String skinType) {
    List<String> recommendations = [];

    // 根据肤质类型添加基础建议
    if (skinType.contains('油性')) {
      recommendations.add('使用控油洁面产品，每天清洁两次');
      recommendations.add('选择清爽质地的保湿产品，避免过度油腻');
    } else if (skinType.contains('干性')) {
      recommendations.add('使用温和的保湿洁面产品，避免使用含酒精的爽肤水');
      recommendations.add('选择油性或乳霜质地的保湿产品，早晚使用');
    } else if (skinType.contains('混合性')) {
      recommendations.add('T区使用控油产品，两颊使用保湿产品');
      recommendations.add('选择质地适中的保湿产品，针对不同区域调整用量');
    } else {
      recommendations.add('使用温和的洁面产品，保持肌肤清洁');
      recommendations.add('选择合适的保湿产品，维持肌肤水油平衡');
    }

    // 根据具体问题添加针对性建议
    for (var issue in issues) {
      switch (issue['key']) {
        case 'acne':
          recommendations.add('使用含有水杨酸的产品帮助清理毛孔，减少痘痘发生');
          break;
        case 'dark_circle':
          recommendations.add('选择含有维生素K、咖啡因的眼霜，帮助改善黑眼圈');
          break;
        case 'pores':
          recommendations.add('使用含有烟酰胺的产品帮助紧致毛孔，定期去角质');
          break;
        case 'blackhead':
          recommendations.add('每周使用深层清洁面膜，帮助清除黑头');
          break;
        case 'wrinkle':
          recommendations.add('添加含有视黄醇或肽类的抗衰老产品到夜间护肤步骤');
          break;
        case 'spot':
          recommendations.add('使用含有烟酰胺、维生素C的产品帮助淡化色斑');
          break;
        case 'moisture':
          recommendations.add('增加使用含有透明质酸的精华液，提升肌肤水分保持力');
          break;
        case 'oiliness':
          recommendations.add('使用含有水杨酸或果酸的产品控制油脂分泌');
          break;
      }
    }

    // 添加通用建议
    recommendations.add('每天早晚使用防晒霜，即使在阴天也要使用');
    recommendations.add('保持充足的睡眠和水分摄入，有助于改善肌肤状态');

    return recommendations;
  }

  // 将分析结果发送到后端保存
  Future<void> _saveAnalysisResult(Map<String, dynamic> result) async {
    // 首先确保当前页面显示分析结果，无论保存成功与否
    setState(() {
      _showAnalysisResult = true;
    });

    // Web平台使用不同的API调用方式
    if (kIsWeb) {
      print('Web平台: 使用Web专用API调用保存分析结果');
      try {
        // 获取用户Token
        String? token = await ApiService.getToken();
        if (token == null) {
          print('未获取到用户Token，无法保存分析结果');
          result['savedToBackend'] = false;
          result['saveStatus'] = 'NO_TOKEN';
          _printAnalysisResultToConsole(result);
          return;
        }

        // 使用专用的Web平台保存方法
        final response = await ApiService.saveSkinAnalysisResultWeb(result);

        print('Web平台保存分析结果响应: $response');

        // 检查响应中是否有错误
        if (response.containsKey('error')) {
          print('Web平台保存分析结果失败: ${response['error']}');
          result['savedToBackend'] = false;
          result['saveStatus'] = 'WEB_API_ERROR';
          result['backendError'] = response['error'];
          _printAnalysisResultToConsole(result);

          // 显示错误消息
          Get.snackbar(
            '保存失败',
            '无法保存分析结果: ${response['error']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
          return;
        }

        // 更新分析结果，添加后端保存成功标志
        result['savedToBackend'] = true;
        result['saveStatus'] = 'SUCCESS_WEB';
        result['backendResponse'] = response;

        // 重新打印带有后端保存状态的分析结果
        _printAnalysisResultToConsole(result);

        // 显示成功消息
        Get.snackbar(
          '保存成功',
          '肌肤分析结果已成功保存到您的账户',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        print('Web平台保存分析结果时出错: $e');
        result['savedToBackend'] = false;
        result['saveStatus'] = 'WEB_EXCEPTION';
        result['backendError'] = e.toString();
        _printAnalysisResultToConsole(result);

        // 显示错误消息
        Get.snackbar(
          '保存出错',
          '保存分析结果时发生错误: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
      return;
    }

    // 非Web平台使用原有的保存逻辑
    try {
      if (_selectedImage == null) {
        result['savedToBackend'] = false;
        result['saveStatus'] = 'NO_IMAGE';
        _printAnalysisResultToConsole(result);
        return;
      }

      print('准备保存分析结果到后端服务器...');

      // 确保URL路径正确 - 移除重复的'/api'
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/skin_analysis/save'),
      );

      // 添加用户Token
      String? token = await ApiService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 准备图片数据
      Uint8List imageBytes = await _selectedImage!.readAsBytes();

      // 添加图片文件
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'skin_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // 添加分析结果数据
      request.fields['analysis_result'] = json.encode(result);
      request.fields['analysis_time'] = DateTime.now().toIso8601String();

      print('向后端发送肌肤分析结果，图片大小: ${imageBytes.length} 字节');
      print('分析结果数据: ${json.encode(result)}');

      // 发送请求
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('请求超时');
        },
      );

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('分析结果已成功保存到后端，响应: ${response.body}');

        // 更新分析结果，添加后端保存成功标志
        result['savedToBackend'] = true;
        result['saveStatus'] = 'SUCCESS';
        result['backendResponse'] = response.body;

        // 重新打印带有后端保存状态的分析结果
        _printAnalysisResultToConsole(result);

        // 显示成功消息
        Get.snackbar(
          '保存成功',
          '肌肤分析结果已成功保存到您的账户',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        // 保存失败但依然显示分析结果
        print('保存到后端失败，状态码: ${response.statusCode}，响应: ${response.body}');

        result['savedToBackend'] = false;
        result['saveStatus'] = 'ERROR_${response.statusCode}';
        result['backendResponse'] = response.body;

        // 重新打印带有后端保存失败状态的分析结果
        _printAnalysisResultToConsole(result);

        // 显示失败消息
        Get.snackbar(
          '保存失败',
          '无法保存分析结果，请稍后再试。错误码: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // 发生错误但依然显示分析结果
      print('保存分析结果时出错: $e');

      result['savedToBackend'] = false;
      result['saveStatus'] = 'EXCEPTION';
      result['backendError'] = e.toString();

      // 重新打印带有错误信息的分析结果
      _printAnalysisResultToConsole(result);

      // 显示错误消息
      Get.snackbar(
        '保存出错',
        '保存分析结果时发生错误: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  // 构建分析结果状态
  Widget _buildAnalysisResultState() {
    if (_isAnalyzing) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_analysisResult == null) {
      return _buildInitialState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalysisHeaderCard(),
            const SizedBox(height: 20),
            _buildHealthScoreIndicator(),
            const SizedBox(height: 20),
            _buildAnalysisOverviewCard(),
            const SizedBox(height: 20),
            _buildSkinIssuesSection(),
            const SizedBox(height: 20),
            _buildRecommendationsSection(),
          ],
        ),
      ),
    );
  }

  // 构建健康分数指示器
  Widget _buildHealthScoreIndicator() {
    final int healthScore = _analysisResult!['health_score'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: healthScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    healthScore > 70
                        ? Colors.green
                        : (healthScore > 50 ? Colors.orange : Colors.red),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        healthScore.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '分',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '肌肤健康评分',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getHealthScoreDescription(healthScore),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取健康分数描述
  String _getHealthScoreDescription(int score) {
    if (score >= 80) {
      return '您的肌肤状态优秀！继续保持良好的护肤习惯。';
    } else if (score >= 60) {
      return '您的肌肤状态良好，存在一些小问题，建议关注。';
    } else if (score >= 40) {
      return '您的肌肤存在一些问题，需要进行针对性护理。';
    } else {
      return '您的肌肤状态需要改善，建议咨询专业皮肤科医生。';
    }
  }

  // 构建分析概览卡片
  Widget _buildAnalysisOverviewCard() {
    final String skinType = _analysisResult!['skin_type'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '肌肤概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('皮肤类型', skinType),
          const Divider(height: 24),

          // 添加详细指标
          if (_analysisResult!.containsKey('detailed_metrics')) ...[
            if (_analysisResult!['detailed_metrics']
                is Map<String, dynamic>) ...[
              _buildMetricsRows(
                  _analysisResult!['detailed_metrics'] as Map<String, dynamic>)
            ]
          ],
        ],
      ),
    );
  }

  // 构建指标行
  Widget _buildMetricsRows(Map<String, dynamic> metrics) {
    return Column(
      children: [
        if (metrics.containsKey('moisture'))
          _buildInfoRow(
              '水分', '${(metrics['moisture'] as num).toStringAsFixed(1)}%'),
        if (metrics.containsKey('oiliness'))
          _buildInfoRow(
              '油分', '${(metrics['oiliness'] as num).toStringAsFixed(1)}%'),
        if (metrics.containsKey('health'))
          _buildInfoRow(
              '健康度', '${(metrics['health'] as num).toStringAsFixed(1)}%'),
      ],
    );
  }

  // 构建加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '正在分析肌肤状态...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 构建错误状态
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '加载分析结果失败',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _errorMessage = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('重新尝试'),
          ),
        ],
      ),
    );
  }

  // 构建分析结果头部卡片
  Widget _buildAnalysisHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 用户图片预览
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _selectedImage != null
                ? SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildImageWidget(_selectedImage!),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '肌肤状态分析',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '肤质类型: ${_analysisResult?['skin_type'] ?? "未知"}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '分析时间: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建肌肤问题部分
  Widget _buildSkinIssuesSection() {
    final List<Map<String, dynamic>> issues =
        _analysisResult!['issues'] as List<Map<String, dynamic>>;

    if (issues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '肌肤问题',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: issues.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final issue = issues[index];
              return _buildIssueItem(
                issue['name'] as String,
                issue['value'] as double,
                issue['severity'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建单个肌肤问题项目
  Widget _buildIssueItem(String name, double value, String severity) {
    Color severityColor = severity == '严重' ? Colors.red : Colors.orange;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: severityColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            severity,
            style: TextStyle(
              fontSize: 12,
              color: severityColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // 构建护肤建议部分
  Widget _buildRecommendationsSection() {
    final List<String> recommendations =
        _analysisResult!['recommendations'] as List<String>;

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'AI护肤建议',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendations[index],
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 构建操作按钮区域
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          if (_selectedImage != null && !_isAnalyzing && !_showAnalysisResult)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.analytics),
                label: const Text(
                  '开始分析',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          if (_showAnalysisResult)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _webImageBytes = null;
                    _isAnalyzing = false;
                    _analysisResult = null;
                    _errorMessage = null;
                    _showAnalysisResult = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  '重新检测',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 将分析结果打印到终端，方便调试
  void _printAnalysisResultToConsole(Map<String, dynamic> result) {
    // 格式化日期，使日志更易读
    String timestamp = DateTime.now().toString();

    print('===== 肌肤分析结果 ($timestamp) =====');
    print('分析时间: ${result['analysis_time'] ?? DateTime.now().toString()}');

    if (result.containsKey('health_score')) {
      print('健康分数: ${result['health_score']}');
    }

    if (result.containsKey('skin_type')) {
      print('肌肤类型: ${result['skin_type']}');
    }

    if (result.containsKey('issues')) {
      print('检测到的问题:');
      final issues = result['issues'] as List<dynamic>;
      for (var issue in issues) {
        print('  - $issue');
      }
    }

    // 打印后端保存状态
    bool savedToBackend = result['savedToBackend'] ?? false;
    String saveStatus = result['saveStatus'] ?? 'UNKNOWN';

    print('后端保存状态: ${savedToBackend ? '成功' : '失败'} ($saveStatus)');

    if (result.containsKey('backendResponse')) {
      print('后端响应: ${result['backendResponse']}');
    }

    if (result.containsKey('backendError')) {
      print('后端错误: ${result['backendError']}');
    }

    print('是否保存到MongoDB: ${savedToBackend ? '是' : '否'}');

    if (kIsWeb) {
      print('平台: Web');
      print('Web保存结果: $saveStatus');
    } else {
      print('平台: 移动端');
    }

    print('====================================');
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
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    // 绘制进度环
    final progressPaint = Paint()
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
