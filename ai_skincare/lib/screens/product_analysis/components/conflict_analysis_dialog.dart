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
    canvas.drawCircle(Offset(centerX - pawSize, centerY - pawSize * 0.8), pawSize * 0.6, paint);
    canvas.drawCircle(Offset(centerX + pawSize, centerY - pawSize * 0.8), pawSize * 0.6, paint);
    canvas.drawCircle(Offset(centerX - pawSize, centerY + pawSize * 0.8), pawSize * 0.6, paint);
    canvas.drawCircle(Offset(centerX + pawSize, centerY + pawSize * 0.8), pawSize * 0.6, paint);
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

// 显示冲突分析结果的对话框组件
class ConflictAnalysisDialog extends StatefulWidget {
  final String analysisResult;

  const ConflictAnalysisDialog({
    Key? key,
    required this.analysisResult,
  }) : super(key: key);

  @override
  _ConflictAnalysisDialogState createState() => _ConflictAnalysisDialogState();
}

class _ConflictAnalysisDialogState extends State<ConflictAnalysisDialog> with SingleTickerProviderStateMixin {
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            contentBox(context),
            
            // 右上角关闭按钮 - 使用猫咪图标
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
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
    
    return Container(
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
                    '冲突分析结果',
                    style: titleStyle,
                  ),
                ),
              ],
            ),
          ),
          
          // 内容区域
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
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: kLightPurple.withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: HoverScaleWidget(
                        child: _buildFormattedAnalysisResult(widget.analysisResult, bodyStyle),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 底部按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: kAccentPurple,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '关闭',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 格式化分析文本的工具函数
  Widget _buildFormattedAnalysisResult(String text, TextStyle style) {
    return Text(
      text,
      style: style.copyWith(
        fontSize: 15,
        height: 1.5,
        color: Color(0xFF333333),
      ),
    );
  }
}

// 显示冲突分析结果的辅助函数
void showConflictAnalysisDialog(BuildContext context, String analysisResult) {
  showDialog(
    context: context,
    barrierDismissible: true, // 允许点击空白处关闭弹窗
    builder: (BuildContext context) {
      return ConflictAnalysisDialog(
        analysisResult: analysisResult,
      );
    },
  );
}