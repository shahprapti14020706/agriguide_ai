import '../core/utils/map_utils.dart';

class DiseaseReportModel {
  const DiseaseReportModel({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.imageUrl,
    required this.plantPart,
    required this.diseaseName,
    required this.confidenceScore,
    required this.severity,
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.prevention,
    required this.recommendedAction,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String cropId;
  final String imageUrl;
  final String plantPart;
  final String diseaseName;
  final double confidenceScore;
  final String severity;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;
  final List<String> prevention;
  final String recommendedAction;
  final DateTime createdAt;

  factory DiseaseReportModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return DiseaseReportModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      cropId: map['cropId'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      plantPart: map['plantPart'] as String? ?? '',
      diseaseName: map['diseaseName'] as String? ?? '',
      confidenceScore: (map['confidenceScore'] as num?)?.toDouble() ?? 0,
      severity: map['severity'] as String? ?? '',
      symptoms: MapUtils.stringListFromValue(map['symptoms']),
      causes: MapUtils.stringListFromValue(map['causes']),
      treatment: MapUtils.stringListFromValue(map['treatment']),
      prevention: MapUtils.stringListFromValue(map['prevention']),
      recommendedAction: map['recommendedAction'] as String? ?? '',
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'imageUrl': imageUrl,
      'plantPart': plantPart,
      'diseaseName': diseaseName,
      'confidenceScore': confidenceScore,
      'severity': severity,
      'symptoms': symptoms,
      'causes': causes,
      'treatment': treatment,
      'prevention': prevention,
      'recommendedAction': recommendedAction,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory DiseaseReportModel.fromJson(Map<String, dynamic> json) {
    return DiseaseReportModel.fromMap(json);
  }

  DiseaseReportModel copyWith({
    String? id,
    String? userId,
    String? cropId,
    String? imageUrl,
    String? plantPart,
    String? diseaseName,
    double? confidenceScore,
    String? severity,
    List<String>? symptoms,
    List<String>? causes,
    List<String>? treatment,
    List<String>? prevention,
    String? recommendedAction,
    DateTime? createdAt,
  }) {
    return DiseaseReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropId: cropId ?? this.cropId,
      imageUrl: imageUrl ?? this.imageUrl,
      plantPart: plantPart ?? this.plantPart,
      diseaseName: diseaseName ?? this.diseaseName,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      severity: severity ?? this.severity,
      symptoms: symptoms ?? this.symptoms,
      causes: causes ?? this.causes,
      treatment: treatment ?? this.treatment,
      prevention: prevention ?? this.prevention,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
