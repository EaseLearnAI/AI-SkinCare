import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class AiService {
  static const String _baseUrl = "https://ark.cn-beijing.volces.com/api/v3";
  static const String _imageAnalysisModelId =
      "ep-20250326232808-brg8k"; // 图像识别和抽取
  static const String _textAnalysisModelId =
      "ep-20250326233409-44krq"; // 成分和冲突检测推理

  static const String _apiKey = "1c05dbf9-3cb9-4281-ba94-f49a863b820f";

  // 初始化API密钥，如果后续需要从配置文件中读取
  static Future<void> init() async {
    // 已经在静态变量中设置了默认值
  }

  // 通用的请求头
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

  // 图像识别和成分抽取
  static Future<Map<String, dynamic>> analyzeProductImage(
    File imageFile,
  ) async {
    try {
      // 获取图片数据
      late Uint8List bytes;
      String base64Image = '';

      try {
        // 读取文件字节
        if (kIsWeb) {
          // Web平台特殊处理
          // 注意：在Web上传入的File实际上是dart:html的File对象
          // 需要通过FileReader读取
          // 使用当前的引用无法直接处理，应将base64字符串直接从上层传入
          throw Exception('Web平台请直接使用base64Image参数');
        } else {
          bytes = await imageFile.readAsBytes();
          base64Image = base64Encode(bytes);
        }
      } catch (e) {
        debugPrint('文件读取错误: $e');
        throw Exception('文件读取错误，可能是Web平台兼容性问题');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': _imageAnalysisModelId,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的护肤品分析师，能够从图片中识别出护肤品，并提取其名称、品牌和可见的成分列表。',
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      '请识别这个护肤品，提取出产品名称、品牌名称，以及从图片中可以看到的全部成分列表。请以JSON格式返回，包含product_name、brand_name和ingredients字段（ingredients应该是成分名称的数组）。',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];

        // 尝试从返回内容中提取JSON
        try {
          final jsonStart = content.indexOf('{');
          final jsonEnd = content.lastIndexOf('}');
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            final jsonStr = content.substring(jsonStart, jsonEnd + 1);
            return json.decode(jsonStr);
          }
        } catch (e) {
          debugPrint('解析JSON失败: $e');
        }

        // 返回原始内容
        return {'raw_content': content};
      } else {
        throw Exception('图像分析请求失败: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('图像分析异常: $e');
      rethrow;
    }
  }

  // 添加一个专门用于Web平台的图像分析方法
  static Future<Map<String, dynamic>> analyzeProductImageForWeb(
    String base64Image,
  ) async {
    try {
      debugPrint('Web平台开始分析图片...');

      // 检查base64Image是否为空或格式是否正确
      if (base64Image.isEmpty) {
        debugPrint('错误: base64Image为空');
        throw Exception('无法处理空图片数据');
      }

      // 如果base64Image已经包含前缀"data:image..."，则直接使用，否则添加前缀
      String imageUrl;
      if (base64Image.startsWith('data:image')) {
        imageUrl = base64Image;
      } else {
        imageUrl = 'data:image/jpeg;base64,$base64Image';
      }

      debugPrint('准备发送API请求...');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': _imageAnalysisModelId,
          'messages': [
            {
              'role': 'system',
              'content':
                  '你是一个专业的护肤品成分分析师，能够从图片中识别出护肤品，并提取其名称、品牌和成分列表。你需要分析这些成分的功效和潜在危害，为用户提供专业的护肤建议。',
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      '请识别这个护肤品，提取出产品名称、品牌名称，以及从图片中可以看到的全部成分列表。同时可以按照猫咪可爱的风格输出文案，并以JSON格式返回，包含以下字段：\n1. product_name: 产品名称\n2. brand_name: 品牌名称\n3. ingredients: 成分名称的数组\n4. summary: 产品的主要功效和适用肌肤类型的简短总结\n5. benefits: 成分的主要功效点（数组）\n6. potential_concerns: 潜在刺激或有害成分及可能的风险（数组）\n7. rating: 1-10的整体评分',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': imageUrl},
                },
              ],
            },
          ],
        }),
      );

      debugPrint('API请求已发送，状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        debugPrint('收到API响应: $content');

        // 尝试从返回内容中提取JSON
        try {
          final jsonStart = content.indexOf('{');
          final jsonEnd = content.lastIndexOf('}');
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            final jsonStr = content.substring(jsonStart, jsonEnd + 1);
            final result = json.decode(jsonStr);
            debugPrint('成功解析JSON响应: $result');
            return result;
          } else {
            debugPrint('未找到JSON内容，返回原始内容');
            return {'raw_content': content};
          }
        } catch (e) {
          debugPrint('解析JSON失败: $e');
          return {'raw_content': content};
        }
      } else {
        final errorBody = response.body;
        debugPrint('API请求失败: ${response.statusCode}, $errorBody');
        throw Exception('图像分析请求失败: ${response.statusCode}, $errorBody');
      }
    } catch (e) {
      debugPrint('图像分析异常: $e');
      rethrow;
    }
  }

  // 成分分析（基于成分列表和肌肤状态）
  static Future<Map<String, dynamic>> analyzeIngredients(
    List<String> ingredients, [
    Map<String, dynamic>? skinCondition,
  ]) async {
    try {
      String skinInfo = '';
      if (skinCondition != null) {
        skinInfo = '用户肌肤状态：\n';
        skinInfo += '水分: ${skinCondition['hydration']}%, ';
        skinInfo += '油分: ${skinCondition['oil']}%, ';
        skinInfo += '敏感度: ${skinCondition['sensitivity']}%\n';
        if (skinCondition['concerns'] != null) {
          skinInfo +=
              '肌肤问题: ${(skinCondition['concerns'] as List).join(', ')}\n';
        }
      }

      final promptText = '''
$skinInfo
请分析以下护肤品成分对应的功效和潜在危害：
${ingredients.join(', ')}

请以JSON格式返回以下信息：
{
  "summary": "产品总体评价，包括主要功效和适用肌肤类型",
  "benefits": ["功效1", "功效2", "功效3"],
  "potential_concerns": ["风险1", "风险2"],
  "usage_suggestions": ["使用建议1", "使用建议2"],
  "key_ingredients": [
    {"name": "成分1", "function": "功效描述"},
    {"name": "成分2", "function": "功效描述"}
  ],
  "safety_score": 85,
  "safety_level": "安全/中等风险/高风险"
}

确保返回格式正确的JSON，不要包含任何额外的文本说明。
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': _textAnalysisModelId,
          'messages': [
            {
              'role': 'system',
              'content':
                  '你是一个专业的护肤品成分分析师，对各种护肤品成分的功效和潜在危害有深入了解。你的分析简洁明了，重点突出，便于用户理解。请只返回JSON格式的响应，不要包含任何其他文本。',
            },
            {'role': 'user', 'content': promptText},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];

        // 尝试从返回内容中提取JSON
        try {
          final jsonStart = content.indexOf('{');
          final jsonEnd = content.lastIndexOf('}');
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            final jsonStr = content.substring(jsonStart, jsonEnd + 1);
            return json.decode(jsonStr);
          }
        } catch (e) {
          debugPrint('解析JSON失败: $e');
        }

        // 如果无法解析为JSON，构造一个默认结构
        return {
          'summary': content,
          'benefits': [],
          'potential_concerns': [],
          'safety_score': 50,
          'safety_level': '未知',
        };
      } else {
        throw Exception('成分分析请求失败: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('成分分析异常: $e');
      rethrow;
    }
  }

  // 冲突检测
  static Future<String> detectConflicts(
    List<ProductModel> products,
    Map<String, dynamic>? skinCondition,
  ) async {
    try {
      debugPrint('开始检测产品冲突，产品数量: ${products.length}');

      // 准备产品信息
      final List<Map<String, dynamic>> productInfos = products
          .map((p) => {
                'name': p.name,
                'brand': p.brandName,
                'ingredients': p.ingredients.map((i) => i.name).toList(),
              })
          .toList();

      debugPrint('产品信息准备完成: $productInfos');

      String skinInfo = '';
      if (skinCondition != null) {
        skinInfo = '用户肌肤状态：\n';
        skinInfo += '水分: ${skinCondition['hydration']}%, ';
        skinInfo += '油分: ${skinCondition['oil']}%, ';
        skinInfo += '敏感度: ${skinCondition['sensitivity']}%\n';
        if (skinCondition['concerns'] != null) {
          skinInfo +=
              '肌肤问题: ${(skinCondition['concerns'] as List).join(', ')}\n';
        }
      }

      final promptText = '''
$skinInfo
请分析以下几个护肤品混合使用时可能产生的成分冲突：

${productInfos.map((p) => '产品名称: ${p['name']}\n品牌: ${p['brand']}\n成分: ${(p['ingredients'] as List).join(', ')}\n').join('\n')}

请检查这些产品中的成分是否存在相互冲突，尤其关注以下几点：
1. 有效成分之间的相互抵消或降低效果
2. 可能引起刺激或过敏反应的成分组合
3. 不建议同时使用的成分（如维A酸与果酸、烟酰胺与维C等）
4. 基于用户肌肤状态的具体风险

请提供详细分析，并给出使用建议（如调整使用顺序、时间间隔等）。
''';

      debugPrint('发送冲突检测API请求...');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': _textAnalysisModelId,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的护肤品成分分析师，精通各种护肤品成分之间的相互作用和潜在冲突。',
            },
            {'role': 'user', 'content': promptText},
          ],
        }),
      );

      debugPrint('冲突检测API响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['choices'][0]['message']['content'];
        debugPrint('冲突检测结果: $result');
        return result;
      } else {
        final errorBody = response.body;
        debugPrint('冲突检测请求失败: ${response.statusCode}, $errorBody');
        throw Exception('冲突检测请求失败: ${response.statusCode}, $errorBody');
      }
    } catch (e) {
      debugPrint('冲突检测异常: $e');
      rethrow;
    }
  }
}
