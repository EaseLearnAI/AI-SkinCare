import 'ingredient_model.dart';
import 'product_model.dart';

class ConflictModel {
  final String id;
  final List<List<String>> ingredientPair;
  final String level;
  final String description;
  final List<String> recommendations;
  final String? source;
  final String createdAt;
  final String updatedAt;

  ConflictModel({
    required this.id,
    required this.ingredientPair,
    required this.level,
    required this.description,
    required this.recommendations,
    this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConflictModel.fromJson(Map<String, dynamic> json) {
    return ConflictModel(
      id: json['id'],
      ingredientPair: List<List<String>>.from(
        json['ingredientPair'].map((x) => List<String>.from(x)),
      ),
      level: json['level'],
      description: json['description'],
      recommendations: List<String>.from(json['recommendations']),
      source: json['source'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredientPair': ingredientPair,
      'level': level,
      'description': description,
      'recommendations': recommendations,
      'source': source,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ConflictCheckResult {
  final List<ConflictDetail> conflicts;
  final List<List<IngredientModel>> compatibleGroups;
  final String? usageSuggestion;

  ConflictCheckResult({
    required this.conflicts,
    required this.compatibleGroups,
    this.usageSuggestion,
  });

  factory ConflictCheckResult.fromJson(Map<String, dynamic> json) {
    return ConflictCheckResult(
      conflicts: List<ConflictDetail>.from(
        json['conflicts'].map((x) => ConflictDetail.fromJson(x)),
      ),
      compatibleGroups: List<List<IngredientModel>>.from(
        json['compatibleGroups'].map(
          (x) => List<IngredientModel>.from(
            x.map((y) => IngredientModel.fromJson(y)),
          ),
        ),
      ),
      usageSuggestion: json['usageSuggestion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conflicts': conflicts.map((x) => x.toJson()).toList(),
      'compatibleGroups':
          compatibleGroups
              .map(
                (group) =>
                    group.map((ingredient) => ingredient.toJson()).toList(),
              )
              .toList(),
      'usageSuggestion': usageSuggestion,
    };
  }
}

class ConflictDetail {
  final List<IngredientModel> ingredientPair;
  final String level;
  final String description;
  final List<String> recommendations;

  ConflictDetail({
    required this.ingredientPair,
    required this.level,
    required this.description,
    required this.recommendations,
  });

  factory ConflictDetail.fromJson(Map<String, dynamic> json) {
    return ConflictDetail(
      ingredientPair: List<IngredientModel>.from(
        json['ingredientPair'].map((x) => IngredientModel.fromJson(x)),
      ),
      level: json['level'],
      description: json['description'],
      recommendations: List<String>.from(json['recommendations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientPair': ingredientPair.map((x) => x.toJson()).toList(),
      'level': level,
      'description': description,
      'recommendations': recommendations,
    };
  }
}

class ProductConflictResult extends ConflictCheckResult {
  final List<ProductModel> products;

  ProductConflictResult({
    required this.products,
    required List<ConflictDetail> conflicts,
    required List<List<IngredientModel>> compatibleGroups,
    String? usageSuggestion,
  }) : super(
         conflicts: conflicts,
         compatibleGroups: compatibleGroups,
         usageSuggestion: usageSuggestion,
       );

  factory ProductConflictResult.fromJson(Map<String, dynamic> json) {
    return ProductConflictResult(
      products: List<ProductModel>.from(
        json['products'].map((x) => ProductModel.fromJson(x)),
      ),
      conflicts: List<ConflictDetail>.from(
        json['conflicts'].map((x) => ConflictDetail.fromJson(x)),
      ),
      compatibleGroups: List<List<IngredientModel>>.from(
        json['compatibleGroups'].map(
          (x) => List<IngredientModel>.from(
            x.map((y) => IngredientModel.fromJson(y)),
          ),
        ),
      ),
      usageSuggestion: json['usageSuggestion'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['products'] = products.map((x) => x.toJson()).toList();
    return baseJson;
  }
}
