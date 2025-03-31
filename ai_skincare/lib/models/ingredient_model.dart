class IngredientModel {
  final String id;
  final String name;
  final String? function;
  final int safetyLevel; // 0-100，表示安全级别
  final String? category;
  final String? description;
  final List<String>? suitableSkinTypes;
  final List<String>? warningsAndRestrictions;
  final Map<String, dynamic>? scientificData;

  IngredientModel({
    required this.id,
    required this.name,
    this.function,
    required this.safetyLevel,
    this.category,
    this.description,
    this.suitableSkinTypes,
    this.warningsAndRestrictions,
    this.scientificData,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      function: json['function'],
      safetyLevel: json['safety_level'] ?? 50,
      category: json['category'],
      description: json['description'],
      suitableSkinTypes:
          json['suitable_skin_types'] != null
              ? List<String>.from(json['suitable_skin_types'])
              : null,
      warningsAndRestrictions:
          json['warnings_and_restrictions'] != null
              ? List<String>.from(json['warnings_and_restrictions'])
              : null,
      scientificData: json['scientific_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'function': function,
      'safety_level': safetyLevel,
      'category': category,
      'description': description,
      'suitable_skin_types': suitableSkinTypes,
      'warnings_and_restrictions': warningsAndRestrictions,
      'scientific_data': scientificData,
    };
  }
}
