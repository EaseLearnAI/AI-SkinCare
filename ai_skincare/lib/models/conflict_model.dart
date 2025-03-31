import 'ingredient_model.dart';
import 'product_model.dart';

class ConflictDetectionModel {
  final String id;
  final String userId;
  final String type; // 'products' 或 'ingredients'
  final ConflictInputs inputs;
  final List<ConflictDetail> conflicts;
  final List<String> compatibleGroups;
  final String? usageSuggestion;
  final String? aiPrompt;
  final String? aiResponse;
  final String createdAt;

  ConflictDetectionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.inputs,
    required this.conflicts,
    required this.compatibleGroups,
    this.usageSuggestion,
    this.aiPrompt,
    this.aiResponse,
    required this.createdAt,
  });

  factory ConflictDetectionModel.fromJson(Map<String, dynamic> json) {
    // 处理MongoDB的_id到id的映射
    String id = json['id'] ?? json['_id'] ?? '';

    return ConflictDetectionModel(
      id: id,
      userId: json['userId'],
      type: json['type'],
      inputs: ConflictInputs.fromJson(json['inputs']),
      conflicts: List<ConflictDetail>.from(
        json['conflicts'].map((x) => ConflictDetail.fromJson(x)),
      ),
      compatibleGroups: List<String>.from(json['compatibleGroups']),
      usageSuggestion: json['usageSuggestion'],
      aiPrompt: json['aiPrompt'],
      aiResponse: json['aiResponse'],
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'inputs': inputs.toJson(),
      'conflicts': conflicts.map((x) => x.toJson()).toList(),
      'compatibleGroups': compatibleGroups,
      'usageSuggestion': usageSuggestion,
      'aiPrompt': aiPrompt,
      'aiResponse': aiResponse,
      'createdAt': createdAt,
    };
  }

  // 转换为MongoDB存储格式
  Map<String, dynamic> toMongoJson() {
    return {
      'userId': userId,
      'type': type,
      'inputs': inputs.toJson(),
      'conflicts': conflicts.map((x) => x.toJson()).toList(),
      'compatibleGroups': compatibleGroups,
      'usageSuggestion': usageSuggestion,
      'aiPrompt': aiPrompt,
      'aiResponse': aiResponse,
      'created_at': createdAt,
    };
  }
}

class ConflictInputs {
  final List<String>? products;
  final List<String>? ingredientLists;
  final String? skinType;
  final String? skinStatus;

  ConflictInputs({
    this.products,
    this.ingredientLists,
    this.skinType,
    this.skinStatus,
  });

  factory ConflictInputs.fromJson(Map<String, dynamic> json) {
    return ConflictInputs(
      products:
          json['products'] != null ? List<String>.from(json['products']) : null,
      ingredientLists:
          json['ingredientLists'] != null
              ? List<String>.from(json['ingredientLists'])
              : null,
      skinType: json['skinType'],
      skinStatus: json['skinStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products,
      'ingredientLists': ingredientLists,
      'skinType': skinType,
      'skinStatus': skinStatus,
    };
  }
}

class ConflictDetail {
  final List<dynamic> items; // 可能是产品ID列表或成分列表索引
  final List<String> problematicItems; // 具体冲突的成分
  final String level; // 冲突等级（severe/moderate/mild）
  final String description;
  final String? aiRecommendations;

  ConflictDetail({
    required this.items,
    required this.problematicItems,
    required this.level,
    required this.description,
    this.aiRecommendations,
  });

  factory ConflictDetail.fromJson(Map<String, dynamic> json) {
    return ConflictDetail(
      items: json['items'],
      problematicItems: List<String>.from(json['problematicItems']),
      level: json['level'],
      description: json['description'],
      aiRecommendations: json['aiRecommendations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'problematicItems': problematicItems,
      'level': level,
      'description': description,
      'aiRecommendations': aiRecommendations,
    };
  }
}

// 产品冲突检测结果
class ProductConflictResult {
  final List<ProductModel> products;
  final List<ConflictItem> conflicts;
  final String summary;
  final List<String> recommendations;
  final bool hasConflict;

  ProductConflictResult({
    required this.products,
    required this.conflicts,
    required this.summary,
    required this.recommendations,
    required this.hasConflict,
  });

  factory ProductConflictResult.fromJson(Map<String, dynamic> json) {
    List<ProductModel> productsList = [];
    if (json['products'] != null) {
      productsList =
          (json['products'] as List)
              .map((p) => ProductModel.fromJson(p))
              .toList();
    }

    List<ConflictItem> conflictsList = [];
    if (json['conflicts'] != null) {
      conflictsList =
          (json['conflicts'] as List)
              .map((c) => ConflictItem.fromJson(c))
              .toList();
    }

    List<String> recommendationsList = [];
    if (json['recommendations'] != null) {
      recommendationsList = List<String>.from(json['recommendations']);
    }

    return ProductConflictResult(
      products: productsList,
      conflicts: conflictsList,
      summary: json['summary'] ?? '',
      recommendations: recommendationsList,
      hasConflict: json['has_conflict'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'conflicts': conflicts.map((c) => c.toJson()).toList(),
      'summary': summary,
      'recommendations': recommendations,
      'has_conflict': hasConflict,
    };
  }
}

// 成分冲突检测结果
class IngredientConflictResult {
  final List<IngredientModel> ingredients;
  final List<ConflictItem> conflicts;
  final String summary;
  final List<String> recommendations;
  final bool hasConflict;

  IngredientConflictResult({
    required this.ingredients,
    required this.conflicts,
    required this.summary,
    required this.recommendations,
    required this.hasConflict,
  });

  factory IngredientConflictResult.fromJson(Map<String, dynamic> json) {
    List<IngredientModel> ingredientsList = [];
    if (json['ingredients'] != null) {
      ingredientsList =
          (json['ingredients'] as List)
              .map((i) => IngredientModel.fromJson(i))
              .toList();
    }

    List<ConflictItem> conflictsList = [];
    if (json['conflicts'] != null) {
      conflictsList =
          (json['conflicts'] as List)
              .map((c) => ConflictItem.fromJson(c))
              .toList();
    }

    List<String> recommendationsList = [];
    if (json['recommendations'] != null) {
      recommendationsList = List<String>.from(json['recommendations']);
    }

    return IngredientConflictResult(
      ingredients: ingredientsList,
      conflicts: conflictsList,
      summary: json['summary'] ?? '',
      recommendations: recommendationsList,
      hasConflict: json['has_conflict'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'conflicts': conflicts.map((c) => c.toJson()).toList(),
      'summary': summary,
      'recommendations': recommendations,
      'has_conflict': hasConflict,
    };
  }
}

// 冲突项
class ConflictItem {
  final String id;
  final String title;
  final String description;
  final String severity; // low, medium, high
  final List<String> conflictingItems; // 可以是成分ID或产品ID
  final String? resolutionSuggestion;

  ConflictItem({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.conflictingItems,
    this.resolutionSuggestion,
  });

  factory ConflictItem.fromJson(Map<String, dynamic> json) {
    List<String> conflictingItemsList = [];
    if (json['conflicting_items'] != null) {
      conflictingItemsList = List<String>.from(json['conflicting_items']);
    }

    return ConflictItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'medium',
      conflictingItems: conflictingItemsList,
      resolutionSuggestion: json['resolution_suggestion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity,
      'conflicting_items': conflictingItems,
      'resolution_suggestion': resolutionSuggestion,
    };
  }
}
