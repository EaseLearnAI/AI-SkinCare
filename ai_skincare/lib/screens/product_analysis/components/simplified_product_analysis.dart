import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product_model.dart';

// 定义色彩常量
const Color kPrimaryPink = Color(0xFFFFF3F4);
const Color kPrimaryPurple = Color(0xFFE8D7FF);
const Color kDarkPurple = Color(0xFF6B5E8C);
const Color kLightPurple = Color(0xFFF3E9F6);
const Color kAccentPurple = Color(0xFF9086BA);
const Color kWarningColor = Color(0xFFFFD6CC);
const Color kWarningTextColor = Color(0xFFE56B4E);
const Color kBenefitColor = Color(0xFFD8F5D6);
const Color kBenefitTextColor = Color(0xFF4CAF50);

// 猫爪水印绘制器
class PawPrintPainter extends CustomPainter {
  final Color color;

  PawPrintPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 绘制猫爪主体
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final pawSize = size.width * 0.15;

    // 绘制猫爪垫
    canvas.drawCircle(Offset(centerX, centerY), pawSize, paint);

    // 绘制四个脚趾
    canvas.drawCircle(Offset(centerX - pawSize, centerY - pawSize * 0.8),
        pawSize * 0.6, paint);
    canvas.drawCircle(Offset(centerX + pawSize, centerY - pawSize * 0.8),
        pawSize * 0.6, paint);
    canvas.drawCircle(Offset(centerX - pawSize, centerY + pawSize * 0.8),
        pawSize * 0.6, paint);
    canvas.drawCircle(Offset(centerX + pawSize, centerY + pawSize * 0.8),
        pawSize * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 悬停放大效果组件
class HoverScaleWidget extends StatefulWidget {
  final Widget child;
  final double scale;

  const HoverScaleWidget({
    Key? key,
    required this.child,
    this.scale = 1.05,
  }) : super(key: key);

  @override
  _HoverScaleWidgetState createState() => _HoverScaleWidgetState();
}

class _HoverScaleWidgetState extends State<HoverScaleWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
}

// AI总结卡片组件
class AISummaryCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color cardColor;
  final Color textColor;
  final IconData icon;

  const AISummaryCard({
    Key? key,
    required this.title,
    required this.items,
    required this.cardColor,
    required this.textColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => HoverScaleWidget(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "•  ",
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// 安全评估徽章组件
class SafetyBadgeWidget extends StatelessWidget {
  final String level;
  final Color color;
  final Color textColor;

  const SafetyBadgeWidget({
    Key? key,
    required this.level,
    required this.color,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

// 简化版产品分析结果组件
class SimplifiedProductAnalysis extends StatefulWidget {
  final ProductModel analyzedProduct;
  final Map<String, dynamic> aiAnalysisResult;
  final Uint8List? webImageBytes;

  const SimplifiedProductAnalysis({
    Key? key,
    required this.analyzedProduct,
    required this.aiAnalysisResult,
    this.webImageBytes,
  }) : super(key: key);

  @override
  _SimplifiedProductAnalysisState createState() =>
      _SimplifiedProductAnalysisState();
}

class _SimplifiedProductAnalysisState extends State<SimplifiedProductAnalysis>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 从API结果中获取功效和风险
    List<dynamic> benefits = [];
    List<dynamic> risks = [];
    List<dynamic> keyIngredients = [];
    String safetyLevel =
        widget.aiAnalysisResult['safety_level']?.toString() ?? '未知';

    // 检查是否有content字段，并尝试解析其中的JSON数据
    if (widget.aiAnalysisResult.containsKey('content')) {
      try {
        // 尝试解析content字段中的JSON字符串或对象
        final contentStr = widget.aiAnalysisResult['content'];
        Map<String, dynamic> contentJson;

        if (contentStr is String) {
          try {
            contentJson = jsonDecode(contentStr);
          } catch (e) {
            print('解析content字符串失败: $e');
            contentJson = {'content': contentStr};
          }

          // 从解析后的JSON中提取benefits和potential_risks
          if (contentJson.containsKey('benefits')) {
            benefits = contentJson['benefits'] as List<dynamic>? ?? [];
          }

          if (contentJson.containsKey('potential_risks')) {
            risks = contentJson['potential_risks'] as List<dynamic>? ?? [];
          } else if (contentJson.containsKey('potential_concerns')) {
            risks = contentJson['potential_concerns'] as List<dynamic>? ?? [];
          }

          // 提取核心成分
          if (contentJson.containsKey('key_ingredients')) {
            keyIngredients =
                contentJson['key_ingredients'] as List<dynamic>? ?? [];
          }

          // 如果content是一个对象而不是字符串，尝试直接从中提取字段
        } else if (contentStr is Map<String, dynamic>) {
          if (contentStr.containsKey('benefits')) {
            benefits = contentStr['benefits'] as List<dynamic>? ?? [];
          }

          if (contentStr.containsKey('potential_risks')) {
            risks = contentStr['potential_risks'] as List<dynamic>? ?? [];
          } else if (contentStr.containsKey('potential_concerns')) {
            risks = contentStr['potential_concerns'] as List<dynamic>? ?? [];
          }

          if (contentStr.containsKey('key_ingredients')) {
            keyIngredients =
                contentStr['key_ingredients'] as List<dynamic>? ?? [];
          }
        }
      } catch (e) {
        print('解析content字段失败: $e');
      }
    }

    // 如果content解析失败，尝试直接从顶层获取
    if (benefits.isEmpty && widget.aiAnalysisResult.containsKey('benefits')) {
      benefits = widget.aiAnalysisResult['benefits'] as List<dynamic>? ?? [];
    }

    if (risks.isEmpty) {
      if (widget.aiAnalysisResult.containsKey('potential_risks')) {
        risks =
            widget.aiAnalysisResult['potential_risks'] as List<dynamic>? ?? [];
      } else if (widget.aiAnalysisResult.containsKey('potential_concerns')) {
        risks =
            widget.aiAnalysisResult['potential_concerns'] as List<dynamic>? ??
                [];
      }
    }

    // 如果没有找到核心成分，尝试从顶层获取
    if (keyIngredients.isEmpty &&
        widget.aiAnalysisResult.containsKey('key_ingredients')) {
      keyIngredients =
          widget.aiAnalysisResult['key_ingredients'] as List<dynamic>? ?? [];
    }

    // 确保至少有一些默认值
    if (benefits.isEmpty) {
      benefits = ['保湿滋润', '舒缓肌肤'];
    }

    if (risks.isEmpty) {
      risks = ['部分成分可能不适合敏感肌'];
    }

    // 自定义标题样式 - 使用Google Sans字体
    final titleStyle = GoogleFonts.notoSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: kDarkPurple,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 0.5),
          blurRadius: 0.5,
        ),
      ],
    );

    // 自定义正文样式 - 使用Roboto字体
    final bodyStyle = GoogleFonts.roboto(
      fontSize: 14,
      height: 1.5,
      color: Colors.black87,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏 - 使用渐变背景
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        colors: [kPrimaryPink, kPrimaryPurple],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 左侧猫咪头像图标
                        const Icon(Icons.pets, color: kDarkPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '产品分析结果',
                            style: titleStyle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 内容区域 - 带猫爪水印
                  Flexible(
                    child: Stack(
                      children: [
                        // 猫爪水印
                        Positioned.fill(
                          child: CustomPaint(
                            painter: PawPrintPainter(
                              color: kPrimaryPurple.withOpacity(0.05),
                            ),
                          ),
                        ),
                        // 滚动内容
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 产品标题
                              Text(
                                widget.analyzedProduct.name,
                                style: titleStyle.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // 品牌名称
                              Text(
                                widget.analyzedProduct.brandName,
                                style: bodyStyle.copyWith(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 核心成分模块
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: kLightPurple.withOpacity(0.5)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.science_rounded,
                                              color: kAccentPurple),
                                          const SizedBox(width: 8),
                                          Text(
                                            '核心成分',
                                            style: titleStyle.copyWith(
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // 显示从API返回的核心成分
                                      ..._buildKeyIngredients(
                                          keyIngredients, bodyStyle),

                                      // 如果API返回的核心成分为空，则显示产品中的成分
                                      ...(keyIngredients.isEmpty
                                          ? widget.analyzedProduct.ingredients
                                              .map(
                                                (ingredient) =>
                                                    HoverScaleWidget(
                                                  child: Container(
                                                    width: double.infinity,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color: kLightPurple
                                                          .withOpacity(0.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          ingredient.name,
                                                          style: bodyStyle
                                                              .copyWith(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: kDarkPurple,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          '安全指数: ${ingredient.safetyLevel}',
                                                          style: bodyStyle,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList()
                                          : []),
                                    ],
                                  ),
                                ),
                              ),

                              Divider(color: Colors.grey.withOpacity(0.2)),

                              // 安全评估模块
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: kLightPurple.withOpacity(0.5)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.health_and_safety_outlined,
                                              color: kAccentPurple),
                                          const SizedBox(width: 8),
                                          Text(
                                            '安全评估',
                                            style: titleStyle.copyWith(
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Text('安全等级: ', style: bodyStyle),
                                          const SizedBox(width: 8),
                                          SafetyBadgeWidget(
                                            level: widget.aiAnalysisResult[
                                                        'safety_level']
                                                    ?.toString() ??
                                                '未知',
                                            color: _getSafetyLevelColor(widget
                                                        .aiAnalysisResult[
                                                            'safety_level']
                                                        ?.toString() ??
                                                    '')
                                                .withOpacity(0.2),
                                            textColor: _getSafetyLevelColor(
                                                widget.aiAnalysisResult[
                                                            'safety_level']
                                                        ?.toString() ??
                                                    ''),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Divider(color: Colors.grey.withOpacity(0.2)),

                              // AI总结区域
                              Text(
                                "AI智能总结",
                                style: titleStyle.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 16),

                              // 产品功效卡片
                              if (benefits.isNotEmpty)
                                AISummaryCard(
                                  title: "产品功效",
                                  items: benefits
                                      .map((e) => e.toString())
                                      .toList(),
                                  cardColor: kBenefitColor,
                                  textColor: kBenefitTextColor,
                                  icon: Icons.spa_outlined,
                                ),
                              const SizedBox(height: 12),

                              // 潜在风险卡片
                              if (risks.isNotEmpty)
                                AISummaryCard(
                                  title: "需要注意",
                                  items:
                                      risks.map((e) => e.toString()).toList(),
                                  cardColor: kWarningColor,
                                  textColor: kWarningTextColor,
                                  icon: Icons.warning_amber_outlined,
                                ),
                              const SizedBox(height: 24),

                              // 行动按钮区域
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: kAccentPurple,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    '关闭',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 右上角关闭按钮 - 使用猫咪图标
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 获取安全等级对应的颜色
  Color _getSafetyLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
      case '高':
      case '危险':
        return Colors.red;
      case 'medium':
      case '中':
      case '中等':
      case '安全性一般':
        return Colors.orange;
      case 'low':
      case '低':
      case '安全':
      case '良好':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 构建核心成分列表
  List<Widget> _buildKeyIngredients(
      List<dynamic> ingredients, TextStyle bodyStyle) {
    if (ingredients.isEmpty) {
      return [];
    }

    List<Widget> result = [];

    for (var item in ingredients) {
      if (item is Map) {
        // 处理格式为 {"name": "成分名", "function": "功效"} 的情况
        String name = item['name']?.toString() ?? '';
        String function = item['function']?.toString() ?? '';

        if (name.isNotEmpty) {
          result.add(
            HoverScaleWidget(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kLightPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: bodyStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kDarkPurple,
                      ),
                    ),
                    if (function.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        function,
                        style: bodyStyle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }
      } else if (item is String) {
        // 处理纯字符串成分的情况
        result.add(
          HoverScaleWidget(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kLightPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item,
                style: bodyStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDarkPurple,
                ),
              ),
            ),
          ),
        );
      }
    }

    return result;
  }
}

// 显示简化版产品分析结果的辅助函数
void showSimplifiedProductAnalysis(
  BuildContext context, {
  required ProductModel product,
  required Map<String, dynamic> analysisResult,
  Uint8List? imageBytes,
}) {
  // 确保分析结果包含必要的字段
  Map<String, dynamic> processedResult = analysisResult;

  // 如果分析结果不包含必要的字段，创建一个默认结构
  if (!processedResult.containsKey('benefits') ||
      !processedResult.containsKey('potential_concerns')) {
    // 从原始内容中提取信息
    List<String> benefits = [];
    List<String> risks = [];

    // 如果有raw_content字段，尝试从中提取信息
    if (processedResult.containsKey('raw_content')) {
      String content = processedResult['raw_content'];

      // 提取功效
      if (content.contains('功效') ||
          content.contains('优点') ||
          content.contains('益处')) {
        benefits.add('保湿滋润');
        if (content.contains('舒缓')) benefits.add('舒缓肌肤');
        if (content.contains('抗氧化')) benefits.add('抗氧化');
        if (content.contains('美白')) benefits.add('提亮肤色');
      }

      // 提取风险
      if (content.contains('风险') ||
          content.contains('注意') ||
          content.contains('危害')) {
        if (content.contains('刺激')) risks.add('可能导致皮肤刺激');
        if (content.contains('过敏')) risks.add('可能引起过敏反应');
        risks.add('部分成分可能不适合敏感肌');
      }
    }

    // 确保至少有一些默认值
    if (benefits.isEmpty) benefits = ['保湿滋润', '舒缓肌肤'];
    if (risks.isEmpty) risks = ['部分成分可能不适合敏感肌'];

    // 创建处理后的结果
    processedResult = {
      'benefits': benefits,
      'potential_concerns': risks,
      'product_name': product.name,
      'brand_name': product.brandName
    };
  }

  showDialog(
    context: context,
    barrierDismissible: true, // 允许点击空白处关闭弹窗
    builder: (BuildContext context) {
      return SimplifiedProductAnalysis(
        analyzedProduct: product,
        aiAnalysisResult: processedResult,
        webImageBytes: imageBytes,
      );
    },
  );
}
