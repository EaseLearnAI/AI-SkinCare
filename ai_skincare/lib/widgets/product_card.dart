import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../themes/app_theme.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String brand;
  final List<String> tags;
  final double? safetyRating;
  final String? uploadTime;
  final int? usageCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.brand,
    this.tags = const [],
    this.safetyRating,
    this.uploadTime,
    this.usageCount,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 产品图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.sakuraPink100,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.sakuraPink500,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.sakuraPink100,
                    child: const Icon(
                      Icons.error_outline,
                      color: AppTheme.sakuraPink500,
                    ),
                  ),
                ),
              ),
            ),

            // 产品信息
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 产品名称
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 品牌名
                  Text(
                    brand,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 标签
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) => _buildTag(tag)).toList(),
                    ),

                  // 上传时间和使用频率
                  if (uploadTime != null || usageCount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (uploadTime != null)
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: AppTheme.textTertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      uploadTime!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textTertiary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (usageCount != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.replay,
                                  size: 12,
                                  color: AppTheme.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '使用$usageCount次',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                  // 安全等级
                  if (safetyRating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          _buildSafetyIndicator(safetyRating!),
                          const SizedBox(width: 8),
                          Text(
                            '安全指数 ${(safetyRating! * 100).toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
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
    );
  }

  // 构建标签
  Widget _buildTag(String tag) {
    Color backgroundColor;
    Color textColor;

    // 根据标签内容配置颜色
    if (tag.contains('温和') || tag.contains('安全')) {
      backgroundColor = AppTheme.mintGreen100;
      textColor = Colors.green.shade700;
    } else if (tag.contains('热门') || tag.contains('推荐')) {
      backgroundColor = AppTheme.goldYellow200;
      textColor = Colors.orange.shade800;
    } else {
      backgroundColor = AppTheme.sakuraPink200;
      textColor = AppTheme.sakuraPink600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(tag, style: TextStyle(fontSize: 10, color: textColor)),
    );
  }

  // 构建安全指数指示器
  Widget _buildSafetyIndicator(double rating) {
    Color color;
    IconData icon;

    if (rating >= 0.8) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (rating >= 0.6) {
      color = Colors.orange;
      icon = Icons.info_outline;
    } else {
      color = Colors.red;
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, size: 12, color: color)),
    );
  }
}
