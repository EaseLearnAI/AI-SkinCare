import 'ingredient_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String? subCategory;
  final String? imageUrl;
  final String? description;
  final double? price;
  final String? currency;
  final String? size;
  final double? rating;
  final int? reviewCount;
  final List<IngredientModel>? ingredients;
  final ProductAnalysisModel? analysis;
  final String createdAt;
  final String updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    this.subCategory,
    this.imageUrl,
    this.description,
    this.price,
    this.currency,
    this.size,
    this.rating,
    this.reviewCount,
    this.ingredients,
    this.analysis,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<IngredientModel>? ingredients;
    if (json['ingredients'] != null) {
      ingredients = List<IngredientModel>.from(
        json['ingredients'].map((x) => IngredientModel.fromJson(x)),
      );
    }

    return ProductModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      category: json['category'],
      subCategory: json['subCategory'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      size: json['size'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      ingredients: ingredients,
      analysis:
          json['analysis'] != null
              ? ProductAnalysisModel.fromJson(json['analysis'])
              : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'subCategory': subCategory,
      'imageUrl': imageUrl,
      'description': description,
      'price': price,
      'currency': currency,
      'size': size,
      'rating': rating,
      'reviewCount': reviewCount,
      'ingredients': ingredients?.map((x) => x.toJson()).toList(),
      'analysis': analysis?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ProductAnalysisModel {
  final int safetyScore;
  final int effectivenessScore;
  final int suitabilityScore;
  final List<String>? goodFor;
  final List<String>? notRecommendedFor;
  final List<HighlightModel>? highlights;

  ProductAnalysisModel({
    required this.safetyScore,
    required this.effectivenessScore,
    required this.suitabilityScore,
    this.goodFor,
    this.notRecommendedFor,
    this.highlights,
  });

  factory ProductAnalysisModel.fromJson(Map<String, dynamic> json) {
    List<HighlightModel>? highlights;
    if (json['highlights'] != null) {
      highlights = List<HighlightModel>.from(
        json['highlights'].map((x) => HighlightModel.fromJson(x)),
      );
    }

    return ProductAnalysisModel(
      safetyScore: json['safetyScore'],
      effectivenessScore: json['effectivenessScore'],
      suitabilityScore: json['suitabilityScore'],
      goodFor:
          json['goodFor'] != null ? List<String>.from(json['goodFor']) : null,
      notRecommendedFor:
          json['notRecommendedFor'] != null
              ? List<String>.from(json['notRecommendedFor'])
              : null,
      highlights: highlights,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'safetyScore': safetyScore,
      'effectivenessScore': effectivenessScore,
      'suitabilityScore': suitabilityScore,
      'goodFor': goodFor,
      'notRecommendedFor': notRecommendedFor,
      'highlights': highlights?.map((x) => x.toJson()).toList(),
    };
  }
}

class HighlightModel {
  final String type; // 'good' or 'warning'
  final String description;

  HighlightModel({required this.type, required this.description});

  factory HighlightModel.fromJson(Map<String, dynamic> json) {
    return HighlightModel(type: json['type'], description: json['description']);
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'description': description};
  }
}
