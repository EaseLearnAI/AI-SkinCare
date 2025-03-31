import 'dart:typed_data';
import 'dart:math' as math; // Import math package for sin function
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

// 波浪进度条组件
class WaveProgressBar extends StatefulWidget {
  final double value; // 0.0 到 1.0
  final Color color;
  final double height;

  const WaveProgressBar({
    Key? key,
    required this.value,
    this.color = kAccentPurple,
    this.height = 12.0,
  }) : super(key: key);

  @override
  _WaveProgressBarState createState() => _WaveProgressBarState();
}

class _WaveProgressBarState extends State<WaveProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / 2),
        color: widget.color.withOpacity(0.2),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FractionallySizedBox(
            widthFactor: widget.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                gradient: LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.7),
                    widget.color,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.height / 2),
                child: CustomPaint(
                  painter: WavePainter(
                    animation: _animationController,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: Container(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 波浪效果绘制器
class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  WavePainter({required this.animation, required this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.2;
    final waveWidth = size.width * 0.5;
    final baseHeight = size.height * 0.5;

    path.moveTo(0, baseHeight);

    for (var i = 0.0; i < size.width; i += 1) {
      path.lineTo(
        i,
        baseHeight +
            math.sin((i / waveWidth + animation.value * 2) * 3.14159) *
                waveHeight,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

// 标签云组件
class SkinTypeTagCloud extends StatefulWidget {
  final List<String> skinTypes;

  const SkinTypeTagCloud({Key? key, required this.skinTypes}) : super(key: key);

  @override
  _SkinTypeTagCloudState createState() => _SkinTypeTagCloudState();
}

class _SkinTypeTagCloudState extends State<SkinTypeTagCloud> {
  Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.skinTypes.map((type) {
        final isSelected = _selectedTags.contains(type);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTags.remove(type);
              } else {
                _selectedTags.add(type);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? kAccentPurple : kLightPurple,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: kAccentPurple.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : kDarkPurple,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
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

// 成分分析弹窗组件
class IngredientAnalysisDialog extends StatefulWidget {
  final String ingredientName;
  final String chemicalFormula;
  final String concentration;
  final String safetyLevel;
  final double sensitivityRisk;
  final List<String> suitableSkinTypes;
  final List<String> usageRecommendations;
  final List<String> warnings;
  final String? moleculeStructureUrl;

  const IngredientAnalysisDialog({
    Key? key,
    required this.ingredientName,
    required this.chemicalFormula,
    required this.concentration,
    required this.safetyLevel,
    required this.sensitivityRisk,
    required this.suitableSkinTypes,
    required this.usageRecommendations,
    required this.warnings,
    this.moleculeStructureUrl,
  }) : super(key: key);

  @override
  _IngredientAnalysisDialogState createState() =>
      _IngredientAnalysisDialogState();
}

class _IngredientAnalysisDialogState extends State<IngredientAnalysisDialog>
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

  // 获取安全等级对应的颜色
  Color _getSafetyLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
      case '高':
        return Colors.red;
      case 'medium':
      case '中':
        return Colors.orange;
      case 'low':
      case '低':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safetyColor = _getSafetyLevelColor(widget.safetyLevel);
    final textTheme = Theme.of(context).textTheme;

    // 自定义标题样式
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

    // 自定义正文样式
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
                maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                  // 标题栏
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
                        const Icon(Icons.pets, color: kDarkPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '成分分析',
                            style: titleStyle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 内容区域
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.science_rounded,
                                          color: kAccentPurple),
                                      const SizedBox(width: 8),
                                      Text(
                                        '核心成分',
                                        style:
                                            titleStyle.copyWith(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  HoverScaleWidget(
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: kLightPurple.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.ingredientName,
                                            style: bodyStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: kDarkPurple,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '化学式: ${widget.chemicalFormula}',
                                            style: bodyStyle,
                                          ),
                                          if (widget
                                              .concentration.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '浓度: ${widget.concentration}',
                                              style: bodyStyle,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                          Icons.health_and_safety_outlined,
                                          color: kAccentPurple),
                                      const SizedBox(width: 8),
                                      Text(
                                        '安全评估',
                                        style:
                                            titleStyle.copyWith(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text('风险等级: ', style: bodyStyle),
                                      const SizedBox(width: 8),
                                      SafetyBadgeWidget(
                                        level: widget.safetyLevel,
                                        color: safetyColor.withOpacity(0.2),
                                        textColor: safetyColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text('致敏可能性:', style: bodyStyle),
                                  const SizedBox(height: 8),
                                  WaveProgressBar(
                                      value: widget.sensitivityRisk),
                                  const SizedBox(height: 16),
                                  Text('适用肤质:', style: bodyStyle),
                                  const SizedBox(height: 8),
                                  SkinTypeTagCloud(
                                      skinTypes: widget.suitableSkinTypes),
                                ],
                              ),
                            ),
                          ),

                          Divider(color: Colors.grey.withOpacity(0.2)),

                          // 使用建议模块
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                          Icons.tips_and_updates_outlined,
                                          color: kAccentPurple),
                                      const SizedBox(width: 8),
                                      Text(
                                        '使用建议',
                                        style:
                                            titleStyle.copyWith(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text('推荐使用方法:', style: bodyStyle),
                                  const SizedBox(height: 8),
                                  ...widget.usageRecommendations
                                      .map((recommendation) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: HoverScaleWidget(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '• ',
                                                    style: bodyStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      recommendation,
                                                      style: bodyStyle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                  if (widget.warnings.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Text('注意事项:', style: bodyStyle),
                                    const SizedBox(height: 8),
                                    ...widget.warnings.map((warning) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: HoverScaleWidget(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: kWarningTextColor,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    warning,
                                                    style: bodyStyle.copyWith(
                                                        color:
                                                            kWarningTextColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // 分子结构图（可选）
                          if (widget.moleculeStructureUrl != null) ...[
                            Divider(color: Colors.grey.withOpacity(0.2)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.science_outlined,
                                            color: kAccentPurple),
                                        const SizedBox(width: 8),
                                        Text(
                                          '分子结构',
                                          style:
                                              titleStyle.copyWith(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: kLightPurple.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            widget.moleculeStructureUrl!,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  color: kAccentPurple,
                                                  size: 50,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 关闭按钮
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
}

// 显示成分分析弹窗的辅助函数
void showIngredientAnalysisDialog(
  BuildContext context, {
  required String ingredientName,
  required String chemicalFormula,
  String concentration = '',
  String safetyLevel = '低',
  double sensitivityRisk = 0.2,
  List<String> suitableSkinTypes = const ['中性肤质', '干性肤质', '油性肤质', '混合性肤质'],
  List<String> usageRecommendations = const ['每日使用', '早晚均可使用'],
  List<String> warnings = const [],
  String? moleculeStructureUrl,
}) {
  showDialog(
    context: context,
    barrierDismissible: true, // 允许点击空白处关闭弹窗
    builder: (BuildContext context) {
      return IngredientAnalysisDialog(
        ingredientName: ingredientName,
        chemicalFormula: chemicalFormula,
        concentration: concentration,
        safetyLevel: safetyLevel,
        sensitivityRisk: sensitivityRisk,
        suitableSkinTypes: suitableSkinTypes,
        usageRecommendations: usageRecommendations,
        warnings: warnings,
        moleculeStructureUrl: moleculeStructureUrl,
      );
    },
  );
}
