import '../core/utils/map_utils.dart';

class FertilizerRecommendationModel {
  const FertilizerRecommendationModel({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.variety,
    required this.soilType,
    required this.cropStage,
    required this.recommendedFertilizer,
    required this.quantity,
    required this.applicationTiming,
    required this.precautions,
    required this.nutrientRequirements,
    required this.schedule,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final String variety;
  final String soilType;
  final String cropStage;
  final String recommendedFertilizer;
  final String quantity;
  final String applicationTiming;
  final List<String> precautions;
  final Map<String, dynamic> nutrientRequirements;
  final List<String> schedule;
  final DateTime createdAt;

  factory FertilizerRecommendationModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return FertilizerRecommendationModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      cropId: map['cropId'] as String? ?? '',
      cropName: map['cropName'] as String? ?? '',
      variety: map['variety'] as String? ?? '',
      soilType: map['soilType'] as String? ?? '',
      cropStage: map['cropStage'] as String? ?? '',
      recommendedFertilizer: map['recommendedFertilizer'] as String? ?? '',
      quantity: map['quantity'] as String? ?? '',
      applicationTiming: map['applicationTiming'] as String? ?? '',
      precautions: MapUtils.stringListFromValue(map['precautions']),
      nutrientRequirements:
          MapUtils.stringMapFromValue(map['nutrientRequirements']),
      schedule: MapUtils.stringListFromValue(map['schedule']),
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'cropName': cropName,
      'variety': variety,
      'soilType': soilType,
      'cropStage': cropStage,
      'recommendedFertilizer': recommendedFertilizer,
      'quantity': quantity,
      'applicationTiming': applicationTiming,
      'precautions': precautions,
      'nutrientRequirements': nutrientRequirements,
      'schedule': schedule,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory FertilizerRecommendationModel.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendationModel.fromMap(json);
  }

  FertilizerRecommendationModel copyWith({String? id}) {
    return FertilizerRecommendationModel(
      id: id ?? this.id,
      userId: userId,
      cropId: cropId,
      cropName: cropName,
      variety: variety,
      soilType: soilType,
      cropStage: cropStage,
      recommendedFertilizer: recommendedFertilizer,
      quantity: quantity,
      applicationTiming: applicationTiming,
      precautions: precautions,
      nutrientRequirements: nutrientRequirements,
      schedule: schedule,
      createdAt: createdAt,
    );
  }
}
