import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../services/api_service.dart';

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
        borderRadius: BorderRadius.circular(16),
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
            ...items.map((item) => Padding(
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
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// 产品分析结果组件
class ProductAnalysisResult extends StatelessWidget {
  final ProductModel analyzedProduct;
  final String aiAnalysisResult;
  final Uint8List? webImageBytes;

  const ProductAnalysisResult({
    Key? key,
    required this.analyzedProduct,
    required this.aiAnalysisResult,
    this.webImageBytes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 提取产品功效和可能的危害
    final summary = _extractSummary(aiAnalysisResult);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
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
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 产品标题
                  Text(
                    analyzedProduct.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kDarkPurple,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 品牌名称
                  Text(
                    analyzedProduct.brandName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // AI总结区域
                  const Text(
                    "AI智能总结",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kDarkPurple,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 产品功效卡片
                  if (summary.benefits.isNotEmpty)
                    AISummaryCard(
                      title: "产品功效",
                      items: summary.benefits,
                      cardColor: kBenefitColor,
                      textColor: kBenefitTextColor,
                      icon: Icons.spa_outlined,
                    ),
                  const SizedBox(height: 12),

                  // 潜在风险卡片
                  if (summary.risks.isNotEmpty)
                    AISummaryCard(
                      title: "需要注意",
                      items: summary.risks,
                      cardColor: kWarningColor,
                      textColor: kWarningTextColor,
                      icon: Icons.warning_amber_outlined,
                    ),
                  const SizedBox(height: 24),

                  // 行动按钮区域
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.save_alt, size: 18),
                          label: const Text("保存到猫窝"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kAccentPurple,
                            side: const BorderSide(color: kAccentPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: 实现保存产品功能
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 顶部猫咪装饰
          Positioned(
            top: -30,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: kLightPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets, // 小猫图标
                color: kDarkPurple,
                size: 30,
              ),
            ),
          ),

          // 关闭按钮
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: kAccentPurple, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // 提取产品功效和风险信息
  _AnalysisSummary _extractSummary(String analysisText) {
    List<String> benefits = [];
    List<String> risks = [];

    try {
      // 功效关键词
      final benefitKeywords = [
        '保湿',
        '舒缓',
        '抗氧化',
        '美白',
        '抗皱',
        '紧致',
        '控油',
        '清洁',
        '舒缓',
        '抗炎',
        '抗痘',
        '滋润',
        '镇静',
        '提亮',
        '补水',
        '抗衰老'
      ];

      // 风险关键词
      final riskKeywords = [
        '刺激',
        '过敏',
        '敏感',
        '致痘',
        '依赖',
        '风险',
        '警告',
        '注意',
        '避免',
        '不建议',
        '可能导致',
        '危害',
        '副作用',
        '禁用'
      ];

      // 可能的风险部分标题
      final riskSections = ['潜在风险', '使用风险', '需要注意', '使用警告', '可能存在的危害', '注意事项'];

      // 可能的功效部分标题
      final benefitSections = ['产品功效', '主要功效', '核心作用', '适用功效', '产品优势', '核心功效'];

      // 分割文本
      final paragraphs = analysisText.split('\n\n');
      bool inRiskSection = false;
      bool inBenefitSection = false;

      for (var para in paragraphs) {
        final paraLower = para.toLowerCase();

        // 检测是否进入功效或风险部分
        for (var section in benefitSections) {
          if (paraLower.contains(section.toLowerCase())) {
            inBenefitSection = true;
            inRiskSection = false;
            break;
          }
        }

        for (var section in riskSections) {
          if (paraLower.contains(section.toLowerCase())) {
            inRiskSection = true;
            inBenefitSection = false;
            break;
          }
        }

        // 按照列表项处理（以-或*或数字.开头）
        if (para.contains('\n')) {
          final lines = para.split('\n');
          for (var line in lines) {
            line = line.trim();
            if (line.isEmpty) continue;

            if (line.startsWith('-') ||
                line.startsWith('*') ||
                RegExp(r'^\d+\.').hasMatch(line)) {
              var content =
                  line.replaceFirst(RegExp(r'^[-*]|\d+\.\s*'), '').trim();

              // 检查内容中的关键词决定分类
              bool isBenefit = false;
              bool isRisk = false;

              // 优先使用所在部分来判断
              if (inBenefitSection)
                isBenefit = true;
              else if (inRiskSection)
                isRisk = true;
              else {
                // 使用关键词来判断
                for (var keyword in benefitKeywords) {
                  if (content.contains(keyword)) {
                    isBenefit = true;
                    break;
                  }
                }

                for (var keyword in riskKeywords) {
                  if (content.contains(keyword)) {
                    isRisk = true;
                    break;
                  }
                }
              }

              // 根据分类添加到对应列表
              if (isBenefit && !isRisk)
                benefits.add(content);
              else if (isRisk) risks.add(content);
            }
          }
        } else {
          // 处理单行段落
          var line = para.trim();
          if (line.isEmpty) continue;

          bool isBenefit = false;
          bool isRisk = false;

          if (inBenefitSection)
            isBenefit = true;
          else if (inRiskSection)
            isRisk = true;
          else {
            for (var keyword in benefitKeywords) {
              if (line.contains(keyword)) {
                isBenefit = true;
                break;
              }
            }

            for (var keyword in riskKeywords) {
              if (line.contains(keyword)) {
                isRisk = true;
                break;
              }
            }
          }

          if (isBenefit &&
              !isRisk &&
              !line.contains('分析结果') &&
              !line.contains('总结') &&
              !line.contains('小结')) {
            benefits.add(line);
          } else if (isRisk &&
              !line.contains('分析结果') &&
              !line.contains('总结') &&
              !line.contains('小结')) {
            risks.add(line);
          }
        }
      }

      // 如果没有找到足够信息，添加一些通用的描述
      if (benefits.isEmpty) {
        benefits.add("该产品的功效未能完全识别，建议查看详细成分表");
      }

      if (risks.isEmpty) {
        risks.add("未发现明显风险，但个人肤质差异可能导致不同反应");
      }

      // 限制条目数量，避免过多
      if (benefits.length > 5) benefits = benefits.sublist(0, 5);
      if (risks.length > 5) risks = risks.sublist(0, 5);
    } catch (e) {
      print('提取分析摘要时出错: $e');
      benefits.add("无法解析产品功效，请查看详细分析");
      risks.add("无法解析潜在风险，请查看详细分析");
    }

    return _AnalysisSummary(benefits: benefits, risks: risks);
  }
}

// 分析摘要数据类
class _AnalysisSummary {
  List<String> benefits;
  List<String> risks;

  _AnalysisSummary({required this.benefits, required this.risks});
}

// 显示产品分析结果的对话框
void showProductAnalysisResult(
  BuildContext context, {
  required ProductModel product,
  required String analysisResult,
  Uint8List? imageBytes,
}) {
  print("显示产品分析弹窗: ${product.name}");
  showDialog(
    context: context,
    barrierDismissible: true, // 允许点击空白处关闭弹窗
    builder: (BuildContext context) {
      return ProductAnalysisResult(
        analyzedProduct: product,
        aiAnalysisResult: analysisResult,
        webImageBytes: imageBytes,
      );
    },
  );
}

// 格式化分析文本的工具函数
Widget _buildFormattedAnalysisResult(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      height: 1.5,
      color: Colors.black87,
    ),
  );
}
