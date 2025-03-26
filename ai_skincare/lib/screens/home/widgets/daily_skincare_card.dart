import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

class DailySkinCareCard extends StatelessWidget {
  const DailySkinCareCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 护肤步骤数据
    final List<Map<String, dynamic>> morningSteps = [
      {'name': '氨基酸洁面乳', 'step': '洁面'},
      {'name': '烟酰胺精华液', 'step': '精华'},
      {'name': '保湿霜', 'step': '面霜'},
      {'name': '防晒霜SPF50+', 'step': '防晒'},
    ];

    final List<Map<String, dynamic>> eveningSteps = [
      {'name': '卸妆油', 'step': '卸妆'},
      {'name': '氨基酸洁面乳', 'step': '洁面'},
      {'name': '水杨酸精华液', 'step': '精华'},
      {'name': '透明质酸面膜', 'step': '面膜'},
      {'name': '修复晚霜', 'step': '面霜'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // 卡片标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.sakuraPink100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: AppTheme.sakuraPink500,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '今日护肤计划',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.sakuraPink100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.edit_outlined,
                      color: AppTheme.sakuraPink500,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '编辑',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.sakuraPink500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 早晚护肤时间轴
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 早晨护肤
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineHeader(
                      '早晨',
                      Icons.wb_sunny_outlined,
                      Colors.orange,
                    ),
                    _buildTimelineSection(morningSteps),
                  ],
                ),
              ),

              // 中间分隔线
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 1,
                height: 160,
                color: Colors.grey.shade200,
              ),

              // 晚间护肤
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineHeader(
                      '晚间',
                      Icons.nightlight_outlined,
                      Colors.indigo,
                    ),
                    _buildTimelineSection(eveningSteps),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 时间轴标题
  Widget _buildTimelineHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  // 时间轴部分
  Widget _buildTimelineSection(List<Map<String, dynamic>> steps) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: List.generate(
          steps.length,
          (index) => _buildTimelineItem(
            steps[index]['name'] as String,
            steps[index]['step'] as String,
            isLast: index == steps.length - 1,
          ),
        ),
      ),
    );
  }

  // 时间轴单项
  Widget _buildTimelineItem(String name, String step, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧时间轴线和圆点
        SizedBox(
          width: 20,
          height: 36,
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.sakuraPink500,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1, color: AppTheme.sakuraPink300),
                ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // 右侧内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
