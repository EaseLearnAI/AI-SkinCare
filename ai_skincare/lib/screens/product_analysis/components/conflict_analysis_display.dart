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
  int _currentTab = 0;

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
                child: _buildTabContent(),
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
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildTabButton('✨ 萌喵总结', 0),
          _buildTabButton('🧪 成分分析', 1),
          _buildTabButton('⚠️ 风险提示', 2),
          _buildTabButton('💡 使用建议', 3),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTab = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB7C5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFFFB7C5).withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF666666),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildSummaryView();
      case 1:
        return _buildIngredientsView();
      case 2:
        return _buildRisksView();
      case 3:
        return _buildSuggestionsView();
      default:
        return _buildSummaryView();
    }
  }

  Widget _buildSummaryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildCuteTextCard(
            '🌸 喵喵冲突总结',
            _extractSummary(widget.analysisResult),
            const Color(0xFF4A4A4A),
          ),
        ],
      ),
    );
  }

  String _extractSummary(String result) {
    // 提取总结部分
    final RegExp summaryRegex = RegExp(r'### 总结([\s\S]*?)(?=$)');
    final summaryMatch = summaryRegex.firstMatch(result);
    final summaryContent = summaryMatch != null
        ? summaryMatch.group(1)?.trim() ?? '暂无总结数据喵～'
        : '暂无总结数据喵～';

    return summaryContent;
  }

  Widget _buildIngredientsView() {
    // 使用正则表达式提取相互影响部分
    final RegExp interactionsRegex =
        RegExp(r'### 1\. 有效成分之间的相互影响([\s\S]*?)(?=###|$)');
    final interactionsMatch =
        interactionsRegex.firstMatch(widget.analysisResult);
    final interactionsContent = interactionsMatch != null
        ? interactionsMatch.group(1)?.trim() ?? '暂无相互影响数据喵～'
        : '暂无相互影响数据喵～';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCuteCard(
            '🧪 成分喵喵互动',
            interactionsContent,
            color: const Color(0xFF8BC34A),
          ),
        ],
      ),
    );
  }

  Widget _buildRisksView() {
    // 提取刺激和不建议同时使用部分
    final RegExp irritationRegex =
        RegExp(r'### 2\. 可能引起刺激或过敏反应的成分组合([\s\S]*?)(?=###|$)');
    final avoidRegex = RegExp(r'### 3\. 不建议同时使用的成分([\s\S]*?)(?=###|$)');
    final skinRiskRegex = RegExp(r'### 4\. 基于用户肌肤状态的具体风险([\s\S]*?)(?=---|$)');

    final irritationMatch = irritationRegex.firstMatch(widget.analysisResult);
    final avoidMatch = avoidRegex.firstMatch(widget.analysisResult);
    final skinRiskMatch = skinRiskRegex.firstMatch(widget.analysisResult);

    final irritationContent =
        irritationMatch != null ? irritationMatch.group(1)?.trim() ?? '' : '';
    final avoidContent =
        avoidMatch != null ? avoidMatch.group(1)?.trim() ?? '' : '';
    final skinRiskContent =
        skinRiskMatch != null ? skinRiskMatch.group(1)?.trim() ?? '' : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCuteCard(
            '⚠️ 炸毛警告',
            irritationContent,
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(height: 16),
          _buildCuteCard(
            '🚫 喵呜禁区',
            avoidContent,
            color: const Color(0xFFE91E63),
          ),
          const SizedBox(height: 16),
          _buildCuteCard(
            '😿 肌肤隐患',
            skinRiskContent,
            color: const Color(0xFFFF5722),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsView() {
    // 提取使用建议部分
    final RegExp suggestionsRegex = RegExp(r'### 使用建议([\s\S]*?)(?=---|$)');
    final suggestionsMatch = suggestionsRegex.firstMatch(widget.analysisResult);
    final suggestionsContent = suggestionsMatch != null
        ? suggestionsMatch.group(1)?.trim() ?? '暂无使用建议数据喵～'
        : '暂无使用建议数据喵～';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCuteCard(
            '💡 贴心喵士',
            suggestionsContent,
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
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

  Widget _buildCuteTextCard(String title, String content, Color textColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
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
            Row(
              children: [
                Text(title.split(' ')[0]),
                const SizedBox(width: 8),
                Text(
                  title.substring(title.indexOf(' ') + 1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuteCard(String title, String content, {required Color color}) {
    // 将Markdown格式的内容处理一下
    // 去掉标题，只保留列表项
    final cleanedContent = content.replaceAll(RegExp(r'#+\s.*'), '').trim();

    // 处理粗体文本
    List<String> lines = cleanedContent.split('\n');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
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
            Row(
              children: [
                Text(title.split(' ')[0]),
                const SizedBox(width: 8),
                Text(
                  title.substring(title.indexOf(' ') + 1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...lines.map((line) {
              line = line.trim();
              if (line.isEmpty) return const SizedBox(height: 8);

              // 处理列表项
              if (line.startsWith('-')) {
                final itemText = line.substring(1).trim();
                // 查找粗体文本：**文本**
                final boldPattern = RegExp(r'\*\*(.*?)\*\*');

                if (boldPattern.hasMatch(itemText)) {
                  // 提取粗体文本和普通文本
                  final boldMatches = boldPattern.allMatches(itemText);
                  List<TextSpan> textSpans = [];
                  int lastEnd = 0;

                  for (var match in boldMatches) {
                    // 添加粗体文本前的普通文本
                    if (match.start > lastEnd) {
                      textSpans.add(TextSpan(
                        text: itemText.substring(lastEnd, match.start),
                        style: const TextStyle(
                          color: Color(0xFF666666),
                        ),
                      ));
                    }

                    // 添加粗体文本
                    textSpans.add(TextSpan(
                      text: match.group(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ));

                    lastEnd = match.end;
                  }

                  // 添加最后一个粗体文本后的普通文本
                  if (lastEnd < itemText.length) {
                    textSpans.add(TextSpan(
                      text: itemText.substring(lastEnd),
                      style: const TextStyle(
                        color: Color(0xFF666666),
                      ),
                    ));
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🐾 ",
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: textSpans,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // 常规列表项
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🐾 ",
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            itemText,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                // 普通段落
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF666666),
                    ),
                  ),
                );
              }
            }).toList(),
          ],
        ),
      ),
    );
  }
}
