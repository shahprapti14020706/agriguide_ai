import '../core/utils/map_utils.dart';

class IrrigationRecommendationModel {
  const IrrigationRecommendationModel({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.soilType,
    required this.irrigationMethod,
    required this.cropStage,
    required this.waterRequirement,
    required this.irrigationFrequency,
    required this.nextIrrigationDate,
    required this.advisoryNotes,
    required this.alerts,
    required this.schedule,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final String soilType;
  final String irrigationMethod;
  final String cropStage;
  final String waterRequirement;
  final String irrigationFrequency;
  final DateTime nextIrrigationDate;
  final List<String> advisoryNotes;
  final List<String> alerts;
  final List<String> schedule;
  final DateTime createdAt;

  factory IrrigationRecommendationModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return IrrigationRecommendationModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      cropId: map['cropId'] as String? ?? '',
      cropName: map['cropName'] as String? ?? '',
      soilType: map['soilType'] as String? ?? '',
      irrigationMethod: map['irrigationMethod'] as String? ?? '',
      cropStage: map['cropStage'] as String? ?? '',
      waterRequirement: map['waterRequirement'] as String? ?? '',
      irrigationFrequency: map['irrigationFrequency'] as String? ?? '',
      nextIrrigationDate:
          MapUtils.dateTimeFromValue(map['nextIrrigationDate']) ??
              DateTime.now(),
      advisoryNotes: MapUtils.stringListFromValue(map['advisoryNotes']),
      alerts: MapUtils.stringListFromValue(map['alerts']),
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
      'soilType': soilType,
      'irrigationMethod': irrigationMethod,
      'cropStage': cropStage,
      'waterRequirement': waterRequirement,
      'irrigationFrequency': irrigationFrequency,
      'nextIrrigationDate': nextIrrigationDate,
      'advisoryNotes': advisoryNotes,
      'alerts': alerts,
      'schedule': schedule,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory IrrigationRecommendationModel.fromJson(Map<String, dynamic> json) {
    return IrrigationRecommendationModel.fromMap(json);
  }

  IrrigationRecommendationModel copyWith({String? id}) {
    return IrrigationRecommendationModel(
      id: id ?? this.id,
      userId: userId,
      cropId: cropId,
      cropName: cropName,
      soilType: soilType,
      irrigationMethod: irrigationMethod,
      cropStage: cropStage,
      waterRequirement: waterRequirement,
      irrigationFrequency: irrigationFrequency,
      nextIrrigationDate: nextIrrigationDate,
      advisoryNotes: advisoryNotes,
      alerts: alerts,
      schedule: schedule,
      createdAt: createdAt,
    );
  }
}
