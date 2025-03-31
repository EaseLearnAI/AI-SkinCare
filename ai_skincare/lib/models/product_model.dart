import 'ingredient_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String brandName;
  final String imageUrl;
  final String description;
  final String category;
  final List<IngredientModel> ingredients;
  final Map<String, dynamic>? analysisResult;
  final double rating;
  final int reviewCount;
  final double price;
  final String currency;
  final bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    required this.brandName,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.ingredients,
    this.analysisResult,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.price = 0.0,
    this.currency = "CNY",
    this.isFavorite = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<IngredientModel> ingredientsList = [];
    if (json['ingredients'] != null) {
      ingredientsList = (json['ingredients'] as List)
          .map((i) => IngredientModel.fromJson(i))
          .toList();
    }

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brandName: json['brandName'] ?? json['brand'] ?? json['brand_name'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      ingredients: ingredientsList,
      analysisResult: json['analysisResult'] ?? json['analysis_result'],
      rating: (json['rating'] is num) ? json['rating'].toDouble() : 0.0,
      reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,
      price: (json['price'] is num) ? json['price'].toDouble() : 0.0,
      currency: json['currency'] ?? 'CNY',
      isFavorite: json['isFavorite'] ?? json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand_name': brandName,
      'image_url': imageUrl,
      'description': description,
      'category': category,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'analysis_result': analysisResult,
      'rating': rating,
      'review_count': reviewCount,
      'price': price,
      'currency': currency,
      'is_favorite': isFavorite,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? brandName,
    String? imageUrl,
    String? description,
    String? category,
    List<IngredientModel>? ingredients,
    Map<String, dynamic>? analysisResult,
    double? rating,
    int? reviewCount,
    double? price,
    String? currency,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brandName: brandName ?? this.brandName,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      analysisResult: analysisResult ?? this.analysisResult,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ProductAnalysisModel {
  final int safetyScore;
  final int effectivenessScore;
  final int suitabilityScore;
  final List<HighlightModel>? highlights;

  ProductAnalysisModel({
    required this.safetyScore,
    required this.effectivenessScore,
    required this.suitabilityScore,
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
      highlights: highlights,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'safetyScore': safetyScore,
      'effectivenessScore': effectivenessScore,
      'suitabilityScore': suitabilityScore,
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
