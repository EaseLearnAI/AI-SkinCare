class SkinAnalysisModel {
  final String id;
  final String userId;
  final String? imageUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic> quizData;
  final Map<String, dynamic> results;
  final List<RecommendationModel> recommendations;
  final String createdAt;

  SkinAnalysisModel({
    required this.id,
    required this.userId,
    this.imageUrl,
    this.thumbnailUrl,
    required this.quizData,
    required this.results,
    required this.recommendations,
    required this.createdAt,
  });

  factory SkinAnalysisModel.fromJson(Map<String, dynamic> json) {
    List<RecommendationModel> recommendations = [];
    if (json['recommendations'] != null) {
      recommendations = List<RecommendationModel>.from(
        json['recommendations'].map((x) => RecommendationModel.fromJson(x)),
      );
    }

    return SkinAnalysisModel(
      id: json['id'],
      userId: json['userId'],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      quizData: json['quizData'] ?? {},
      results: json['results'] ?? {},
      recommendations: recommendations,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'quizData': quizData,
      'results': results,
      'recommendations': recommendations.map((x) => x.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}

class RecommendationModel {
  final String id;
  final String title;
  final String description;
  final String iconType;
  final String priority;
  final String? timing;
  final List<String>? recommendedProducts;

  RecommendationModel({
    required this.id,
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
      recommendedProducts:
          json['recommendedProducts'] != null
              ? List<String>.from(json['recommendedProducts'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconType': iconType,
      'priority': priority,
      'timing': timing,
      'recommendedProducts': recommendedProducts,
    };
  }
}
