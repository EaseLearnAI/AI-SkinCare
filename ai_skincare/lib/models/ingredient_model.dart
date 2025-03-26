class IngredientModel {
  final String id;
  final String name;
  final List<String>? alias;
  final String? engName;
  final String? casNumber;
  final String? category;
  final String? function;
  final String? description;
  final int safetyLevel;
  final String? safetyDescription;
  final String irritationRisk;
  final String acneRisk;
  final String? allergicRisk;
  final bool? pregnancySafe;
  final List<String>? researchPapers;
  final List<String>? suitableSkinTypes;
  final List<String>? notSuitableSkinTypes;
  final String? createdAt;
  final String? updatedAt;

  IngredientModel({
    required this.id,
    required this.name,
    this.alias,
    this.engName,
    this.casNumber,
    this.category,
    this.function,
    this.description,
    required this.safetyLevel,
    this.safetyDescription,
    required this.irritationRisk,
    required this.acneRisk,
    this.allergicRisk,
    this.pregnancySafe,
    this.researchPapers,
    this.suitableSkinTypes,
    this.notSuitableSkinTypes,
    this.createdAt,
    this.updatedAt,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'],
      name: json['name'],
      alias: json['alias'] != null ? List<String>.from(json['alias']) : null,
      engName: json['engName'],
      casNumber: json['casNumber'],
      category: json['category'],
      function: json['function'],
      description: json['description'],
      safetyLevel: json['safetyLevel'],
      safetyDescription: json['safetyDescription'],
      irritationRisk: json['irritationRisk'],
      acneRisk: json['acneRisk'],
      allergicRisk: json['allergicRisk'],
      pregnancySafe: json['pregnancySafe'],
      researchPapers:
          json['researchPapers'] != null
              ? List<String>.from(json['researchPapers'])
              : null,
      suitableSkinTypes:
          json['suitableSkinTypes'] != null
              ? List<String>.from(json['suitableSkinTypes'])
              : null,
      notSuitableSkinTypes:
          json['notSuitableSkinTypes'] != null
              ? List<String>.from(json['notSuitableSkinTypes'])
              : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'engName': engName,
      'casNumber': casNumber,
      'category': category,
      'function': function,
      'description': description,
      'safetyLevel': safetyLevel,
      'safetyDescription': safetyDescription,
      'irritationRisk': irritationRisk,
      'acneRisk': acneRisk,
      'allergicRisk': allergicRisk,
      'pregnancySafe': pregnancySafe,
      'researchPapers': researchPapers,
      'suitableSkinTypes': suitableSkinTypes,
      'notSuitableSkinTypes': notSuitableSkinTypes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
