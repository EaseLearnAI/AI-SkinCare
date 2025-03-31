import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

class ConflictAnalysisDisplay extends StatefulWidget {
  final String analysisResult;
  final List<Map<String, dynamic>> products;

  const ConflictAnalysisDisplay({
    Key? key,
    required this.analysisResult,
    required this.products,
  }) : super(key: key);

  @override
  State<ConflictAnalysisDisplay> createState() =>
      _ConflictAnalysisDisplayState();
}

class _ConflictAnalysisDisplayState extends State<ConflictAnalysisDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🐱✨ '),
            const Text('喵喵冲突检测报告'),
          ],
        ),
        backgroundColor: const Color(0xFFFFB7C5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB7C5), Color(0xFFFFF0F5)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Column(
            children: [
              _buildProductsBar(),
              Expanded(
                child: _buildAnalysisContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB7C5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB7C5).withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📊 ',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '分析报告',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisContent() {
    // 解析分析结果
    final parsedSections = _parseAnalysisResult(widget.analysisResult);

    // 调整顺序 - 先总结，再使用建议，最后分析结果
    final orderedSections = _reorderSections(parsedSections);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 20),

          // 按新顺序显示各个部分
          ...orderedSections.entries.map((entry) {
            // 根据不同的标题设置不同的颜色和图标
            IconData icon;
            Color color;
            String emoji;

            switch (entry.key.toLowerCase()) {
              case '分析结果':
                icon = Icons.analytics_outlined;
                color = const Color(0xFF9C27B0);
                emoji = '📊';
                break;
              case '总结':
                icon = Icons.summarize;
                color = const Color(0xFF4A4A4A);
                emoji = '✨';
                break;
              case '使用建议':
                icon = Icons.lightbulb_outline;
                color = const Color(0xFF2196F3);
                emoji = '💡';
                break;
              default:
                icon = Icons.info_outline;
                color = const Color(0xFFFF9800);
                emoji = '🔍';
            }

            return Column(
              children: [
                entry.key.toLowerCase() == '分析结果'
                    ? _buildAnalysisResultCard(
                        title: entry.key,
                        content: entry.value,
                        icon: icon,
                        color: color,
                        emoji: emoji,
                      )
                    : _buildSectionCard(
                        title: entry.key,
                        content: entry.value,
                        icon: icon,
                        color: color,
                        emoji: emoji,
                      ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB7C5).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('😺 '),
                  Text(
                    '喵星人已为您检测完成',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Map<String, List<Map<String, String>>> _reorderSections(
      Map<String, List<Map<String, String>>> sections) {
    // 定义期望的顺序
    final orderPriority = {
      '总结': 1,
      '使用建议': 2,
      '分析结果': 3,
      '成分冲突分析': 4, // 这部分会并入分析结果
    };

    // 将成分冲突分析部分合并到分析结果中
    if (sections.containsKey('成分冲突分析')) {
      if (!sections.containsKey('分析结果')) {
        sections['分析结果'] = [];
      }
      final conflictAnalysis = sections['成分冲突分析'];
      if (conflictAnalysis != null) {
        sections['分析结果']?.addAll(conflictAnalysis);
      }
      sections.remove('成分冲突分析');
    }

    // 创建排序后的Map
    final orderedMap = Map<String, List<Map<String, String>>>.fromEntries(
      sections.entries.toList()
        ..sort((a, b) {
          final aPriority = orderPriority[a.key] ?? 999;
          final bPriority = orderPriority[b.key] ?? 999;
          return aPriority.compareTo(bPriority);
        }),
    );

    return orderedMap;
  }

  Map<String, List<Map<String, String>>> _parseAnalysisResult(String result) {
    final Map<String, List<Map<String, String>>> sections = {};

    // 提取主要部分
    final mainSectionRegex = RegExp(r'###\s+(.*?)\s*\n([\s\S]*?)(?=###|$)');
    final mainMatches = mainSectionRegex.allMatches(result);

    for (var match in mainMatches) {
      final title = match.group(1)?.trim() ?? '';
      final content = match.group(2)?.trim() ?? '';

      // 处理子部分（四级标题）
      final subSectionRegex =
          RegExp(r'####\s+(.*?)\s*\n([\s\S]*?)(?=####|###|$)');
      final subMatches = subSectionRegex.allMatches(content);

      List<Map<String, String>> subSections = [];

      if (subMatches.isNotEmpty) {
        for (var subMatch in subMatches) {
          final subTitle = subMatch.group(1)?.trim() ?? '';
          final subContent = subMatch.group(2)?.trim() ?? '';

          subSections.add({
            'title': subTitle,
            'content': subContent,
          });
        }
      } else {
        // 如果没有子部分，将整个内容作为一个条目
        subSections.add({
          'title': '',
          'content': content,
        });
      }

      sections[title] = subSections;
    }

    // 如果无法解析出任何部分，尝试更简单的解析方式
    if (sections.isEmpty) {
      // 简单的按行解析，寻找以###开头的行作为标题
      final lines = result.split('\n');
      String currentTitle = '分析结果';
      List<String> currentContent = [];

      for (var line in lines) {
        if (line.startsWith('###')) {
          // 保存之前的内容
          if (currentContent.isNotEmpty) {
            sections[currentTitle] = [
              {'title': '', 'content': currentContent.join('\n')}
            ];
            currentContent = [];
          }

          // 更新当前标题
          currentTitle = line.replaceAll(RegExp(r'^###\s+'), '').trim();
        } else {
          currentContent.add(line);
        }
      }

      // 保存最后一部分内容
      if (currentContent.isNotEmpty) {
        sections[currentTitle] = [
          {'title': '', 'content': currentContent.join('\n')}
        ];
      }
    }

    return sections;
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFFF0F5)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🔍 '),
                Text(
                  '喵喵探员 - 成分冲突检测',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '检测到以下${widget.products.length}个产品的成分冲突喵～',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            ...widget.products.map((product) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🧴 '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? '未知产品',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          if (product['brand'] != null)
                            Text(
                              product['brand'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF888888),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Map<String, String>> content,
    required IconData icon,
    required Color color,
    required String emoji,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, color.withOpacity(0.1)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...content.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['title']?.isNotEmpty == true) ...[
                    Text(
                      item['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ..._buildFormattedContent(item['content'] ?? '', color),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResultCard({
    required String title,
    required List<Map<String, String>> content,
    required IconData icon,
    required Color color,
    required String emoji,
  }) {
    // 提取四个特定的子标题内容
    final List<Map<String, String>> specialContents = [];
    final List<Map<String, String>> regularContents = [];

    final specialTitles = [
      '有效成分之间的相互抵消或降低效果',
      '可能引起刺激或过敏反应的成分组合',
      '不建议同时使用的成分',
      '基于用户肌肤状态的具体风险',
    ];

    for (var item in content) {
      final title = item['title']?.trim() ?? '';

      bool isSpecial = false;
      for (var specialTitle in specialTitles) {
        if (title.toLowerCase().contains(specialTitle.toLowerCase()) ||
            specialTitle.toLowerCase().contains(title.toLowerCase())) {
          isSpecial = true;
          specialContents.add(item);
          break;
        }
      }

      if (!isSpecial && title.isNotEmpty) {
        regularContents.add(item);
      }
    }

    // 收集无标题内容
    final noTitleContents =
        content.where((item) => item['title']?.isEmpty == true).toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, color.withOpacity(0.1)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 先显示无标题内容
            if (noTitleContents.isNotEmpty) ...[
              ...noTitleContents.map((item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        _buildFormattedContent(item['content'] ?? '', color),
                  )),
              const SizedBox(height: 12),
            ],

            // 特定分析内容
            if (specialContents.isNotEmpty) ...[
              ...specialContents.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['title']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...(_buildFormattedContent(item['content'] ?? '', color)),
                    ],
                  ),
                );
              }).toList(),
            ],

            // 显示其他常规内容
            if (regularContents.isNotEmpty) ...[
              ...regularContents.map((item) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildFormattedContent(item['content'] ?? '', color),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormattedContent(String content, Color accentColor) {
    final List<Widget> widgets = [];
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // 处理分隔线
      if (line.startsWith('---')) {
        widgets.add(
          Divider(
            color: accentColor.withOpacity(0.3),
            thickness: 1,
            height: 24,
          ),
        );
        continue;
      }

      // 处理列表项
      if (line.startsWith('-') || line.startsWith('*')) {
        final itemText = line.substring(1).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🐾 ",
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: _buildRichText(itemText, accentColor),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 处理数字列表项
      final numberListMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(line);
      if (numberListMatch != null) {
        final number = numberListMatch.group(1);
        final itemText = numberListMatch.group(2) ?? '';
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    number ?? '',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRichText(itemText, accentColor),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 普通段落文本
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildRichText(line, accentColor),
        ),
      );
    }

    return widgets;
  }

  Widget _buildRichText(String text, Color accentColor) {
    // 匹配粗体文本: **文本** 或 __文本__
    final boldPattern = RegExp(r'\*\*(.*?)\*\*|__(.*?)__');
    final boldMatches = boldPattern.allMatches(text);

    // 如果没有粗体文本，直接返回普通文本
    if (boldMatches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: Color(0xFF666666),
        ),
      );
    }

    // 处理包含粗体的富文本
    List<TextSpan> textSpans = [];
    int lastEnd = 0;

    for (var match in boldMatches) {
      // 添加粗体文本前的普通文本
      if (match.start > lastEnd) {
        textSpans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(
            color: Color(0xFF666666),
          ),
        ));
      }

      // 添加粗体文本
      final boldText = match.group(1) ?? match.group(2) ?? '';
      textSpans.add(TextSpan(
        text: boldText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
      ));

      lastEnd = match.end;
    }

    // 添加最后一个粗体文本后的普通文本
    if (lastEnd < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(
          color: Color(0xFF666666),
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
