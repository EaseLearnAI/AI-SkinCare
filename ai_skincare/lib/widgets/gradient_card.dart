import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final List<Color> gradientColors;
  final double borderRadius;
  final double? height;
  final double? width;
  final BoxShadow? shadow;
  final void Function()? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradientColors = const [
      AppTheme.sakuraPink400,
      AppTheme.sakuraPink600,
    ],
    this.borderRadius = 16,
    this.height,
    this.width,
    this.shadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadow != null
              ? [shadow!]
              : [
                  BoxShadow(
                    color: gradientColors.last.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
