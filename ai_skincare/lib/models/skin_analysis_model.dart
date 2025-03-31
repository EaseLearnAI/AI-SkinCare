class SkinAnalysisModel {
  final String id;
  final String userId;
  final DateTime createdAt;
  final Map<String, dynamic> analysisData;
  final List<SkinIssue> skinIssues;
  final List<String> recommendations;

  SkinAnalysisModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.analysisData,
    required this.skinIssues,
    required this.recommendations,
  });

  // 从API响应创建模型
  factory SkinAnalysisModel.fromApiResponse(Map<String, dynamic> response,
      {String userId = 'guest'}) {
    final List<SkinIssue> issues = [];
    final List<String> recommendations = [];

    // 如果没有检测到人脸，返回空分析
    if (!response.containsKey('result')) {
      return SkinAnalysisModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        createdAt: DateTime.now(),
        analysisData: response,
        skinIssues: [],
        recommendations: ['未检测到人脸，请确保脸部在图像中清晰可见'],
      );
    }

    final result = response['result'];

    // 检测肤质类型
    if (result.containsKey('skin_type')) {
      int skinType = result['skin_type'];
      String skinTypeName = '';

      switch (skinType) {
        case 0:
          skinTypeName = '油性皮肤';
          issues.add(SkinIssue(
            name: '油性皮肤',
            description: '您的肌肤属于油性皮肤，容易出油',
            severity: 1,
            solutionType: 'skincare',
          ));
          recommendations.add('使用控油洁面产品，避免使用油性产品');
          recommendations.add('可以尝试含有水杨酸的护肤品，帮助控制油脂分泌');
          break;
        case 1:
          skinTypeName = '干性皮肤';
          issues.add(SkinIssue(
            name: '干性皮肤',
            description: '您的肌肤属于干性皮肤，缺乏水分和油脂',
            severity: 1,
            solutionType: 'skincare',
          ));
          recommendations.add('选择温和的保湿洁面产品，避免含有酒精的产品');
          recommendations.add('使用含有透明质酸、甘油等保湿成分的护肤品');
          break;
        case 2:
          skinTypeName = '中性皮肤';
          issues.add(SkinIssue(
            name: '中性皮肤',
            description: '您的肌肤属于中性皮肤，状态良好',
            severity: 0,
            solutionType: 'skincare',
          ));
          recommendations.add('保持现有的护肤习惯，定期使用温和的清洁和保湿产品');
          recommendations.add('不要忘记防晒，保持良好的生活习惯');
          break;
        case 3:
          skinTypeName = '混合性皮肤';
          issues.add(SkinIssue(
            name: '混合性皮肤',
            description: '您的肌肤属于混合性皮肤，T区易出油，两颊较干燥',
            severity: 1,
            solutionType: 'skincare',
          ));
          recommendations.add('T区使用控油产品，两颊使用保湿产品，针对性护理');
          recommendations.add('避免使用过于刺激的产品，保持肌肤水油平衡');
          break;
      }
    }

    // 检测毛孔问题
    bool hasPoreIssue = false;
    if (result.containsKey('pores_forehead') &&
        result['pores_forehead']['value'] == "1") {
      hasPoreIssue = true;
      issues.add(SkinIssue(
        name: '前额毛孔粗大',
        description: '您的前额毛孔较为粗大',
        severity: 2,
        solutionType: 'pore',
      ));
    }

    if (result.containsKey('pores_left_cheek') &&
        result['pores_left_cheek']['value'] == "1") {
      hasPoreIssue = true;
      issues.add(SkinIssue(
        name: '左脸颊毛孔粗大',
        description: '您的左脸颊毛孔较为粗大',
        severity: 2,
        solutionType: 'pore',
      ));
    }

    if (result.containsKey('pores_right_cheek') &&
        result['pores_right_cheek']['value'] == "1") {
      hasPoreIssue = true;
      issues.add(SkinIssue(
        name: '右脸颊毛孔粗大',
        description: '您的右脸颊毛孔较为粗大',
        severity: 2,
        solutionType: 'pore',
      ));
    }

    if (result.containsKey('pores_jaw') &&
        result['pores_jaw']['value'] == "1") {
      hasPoreIssue = true;
      issues.add(SkinIssue(
        name: '下巴毛孔粗大',
        description: '您的下巴毛孔较为粗大',
        severity: 2,
        solutionType: 'pore',
      ));
    }

    if (hasPoreIssue) {
      recommendations.add('使用含有水杨酸、果酸等成分的产品，帮助疏通毛孔');
      recommendations.add('定期使用深层清洁面膜，减少油脂堆积');
    }

    // 检测黑头问题
    if (result.containsKey('blackhead') &&
        result['blackhead']['value'] == "1") {
      issues.add(SkinIssue(
        name: '黑头问题',
        description: '您的肌肤存在黑头问题',
        severity: 2,
        solutionType: 'pore',
      ));
      recommendations.add('使用含有BHA成分的产品，帮助溶解黑头');
      recommendations.add('避免用手挤压黑头，可能会导致毛孔扩大和感染');
    }

    // 检测痘痘问题
    if (result.containsKey('acne') && result['acne']['value'] == "1") {
      issues.add(SkinIssue(
        name: '痘痘问题',
        description: '您的肌肤存在痘痘问题',
        severity: 3,
        solutionType: 'acne',
      ));
      recommendations.add('使用含有水杨酸、苯甲酰过氧化物的产品治疗痘痘');
      recommendations.add('保持面部清洁，避免使用过于油腻的产品');
    }

    // 检测细纹和皱纹
    bool hasWrinkle = false;
    if (result.containsKey('eye_finelines') &&
        result['eye_finelines']['value'] == "1") {
      hasWrinkle = true;
      issues.add(SkinIssue(
        name: '眼部细纹',
        description: '您的眼部存在细纹',
        severity: 1,
        solutionType: 'antiaging',
      ));
    }

    if (result.containsKey('forehead_wrinkle') &&
        result['forehead_wrinkle']['value'] == "1") {
      hasWrinkle = true;
      issues.add(SkinIssue(
        name: '抬头纹',
        description: '您的前额存在抬头纹',
        severity: 2,
        solutionType: 'antiaging',
      ));
    }

    if (result.containsKey('crows_feet') &&
        result['crows_feet']['value'] == "1") {
      hasWrinkle = true;
      issues.add(SkinIssue(
        name: '鱼尾纹',
        description: '您的眼角存在鱼尾纹',
        severity: 2,
        solutionType: 'antiaging',
      ));
    }

    if (result.containsKey('glabella_wrinkle') &&
        result['glabella_wrinkle']['value'] == "1") {
      hasWrinkle = true;
      issues.add(SkinIssue(
        name: '眉间纹',
        description: '您的眉间存在皱纹',
        severity: 2,
        solutionType: 'antiaging',
      ));
    }

    if (result.containsKey('nasolabial_fold') &&
        result['nasolabial_fold']['value'] == "1") {
      hasWrinkle = true;
      issues.add(SkinIssue(
        name: '法令纹',
        description: '您的面部存在法令纹',
        severity: 2,
        solutionType: 'antiaging',
      ));
    }

    if (hasWrinkle) {
      recommendations.add('使用含有视黄醇、胜肽、透明质酸等成分的抗衰老产品');
      recommendations.add('加强防晒保护，紫外线是导致皮肤老化的主要原因');
    }

    // 检测眼部问题
    if (result.containsKey('eye_pouch') &&
        result['eye_pouch']['value'] == "1") {
      issues.add(SkinIssue(
        name: '眼袋',
        description: '您的眼部存在眼袋问题',
        severity: 1,
        solutionType: 'eye',
      ));
      recommendations.add('使用含有咖啡因的眼霜，帮助减轻眼袋');
      recommendations.add('保持充足的睡眠，减少盐分摄入，避免水分滞留');
    }

    if (result.containsKey('dark_circle') &&
        result['dark_circle']['value'] == "1") {
      issues.add(SkinIssue(
        name: '黑眼圈',
        description: '您的眼部存在黑眼圈问题',
        severity: 1,
        solutionType: 'eye',
      ));
      recommendations.add('使用含有维生素C、K的眼霜，帮助淡化黑眼圈');
      recommendations.add('保持充足的睡眠，避免长时间用眼疲劳');
    }

    // 检测色斑问题
    if (result.containsKey('skin_spot') &&
        result['skin_spot']['value'] == "1") {
      issues.add(SkinIssue(
        name: '色斑',
        description: '您的肌肤存在色斑问题',
        severity: 2,
        solutionType: 'spot',
      ));
      recommendations.add('使用含有维生素C、熊果素等美白成分的产品');
      recommendations.add('加强防晒保护，避免紫外线加重色素沉着');
    }

    // 如果没有检测到明显问题，添加一些基础护理建议
    if (issues.isEmpty) {
      issues.add(SkinIssue(
        name: '肌肤状态良好',
        description: '您的肌肤状态总体良好',
        severity: 0,
        solutionType: 'basic',
      ));
      recommendations.add('继续保持良好的护肤习惯，定期做基础护理');
      recommendations.add('不要忘记日常防晒，保持健康的生活方式');
    }

    // 返回构建的模型
    return SkinAnalysisModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      createdAt: DateTime.now(),
      analysisData: response,
      skinIssues: issues,
      recommendations: recommendations,
    );
  }

  // 转换为后端API所需的JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'analysisData': analysisData,
      'skinIssues': skinIssues.map((issue) => issue.toJson()).toList(),
      'recommendations': recommendations,
    };
  }
  
  // 从JSON数据创建模型
  factory SkinAnalysisModel.fromJson(Map<String, dynamic> json) {
    List<SkinIssue> issues = [];
    List<String> recs = [];
    
    if (json.containsKey('skinIssues') && json['skinIssues'] is List) {
      issues = (json['skinIssues'] as List)
          .map((issue) => SkinIssue(
                name: issue['name'] ?? '',
                description: issue['description'] ?? '',
                severity: issue['severity'] ?? 0,
                solutionType: issue['solutionType'] ?? 'basic',
              ))
          .toList();
    }
    
    if (json.containsKey('recommendations') && json['recommendations'] is List) {
      recs = (json['recommendations'] as List).cast<String>();
    }
    
    return SkinAnalysisModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['userId'] ?? 'guest',
      createdAt: json.containsKey('createdAt') && json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      analysisData: json['analysisData'] ?? {},
      skinIssues: issues,
      recommendations: recs,
    );
  }
}

class SkinIssue {
  final String name;
  final String description;
  final int severity; // 0-轻微 1-中等 2-严重 3-非常严重
  final String
      solutionType; // skincare, pore, acne, antiaging, eye, spot, basic

  SkinIssue({
    required this.name,
    required this.description,
    required this.severity,
    required this.solutionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'severity': severity,
      'solutionType': solutionType,
    };
  }
}

class RecommendationModel {
  final String? id;
  final String title;
  final String description;
  final String iconType;
  final String priority;
  final String? timing;
  final List<String>? recommendedProducts;

  RecommendationModel({
    this.id,
    required this.title,
    required this.description,
    required this.iconType,
    required this.priority,
    this.timing,
    this.recommendedProducts,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconType: json['iconType'],
      priority: json['priority'],
      timing: json['timing'],
      recommendedProducts: json['recommendedProducts'] != null
          ? List<String>.from(json['recommendedProducts'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'iconType': iconType,
      'priority': priority,
      'timing': timing,
      'recommendedProducts': recommendedProducts,
    };
  }
}
