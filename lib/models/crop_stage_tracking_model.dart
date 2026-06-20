import '../core/utils/map_utils.dart';

class CropStageModel {
  const CropStageModel({
    required this.id,
    required this.cropId,
    required this.userId,
    required this.stageName,
    required this.startedAt,
    required this.expectedEndAt,
    required this.daysInStage,
    required this.daysRemaining,
    required this.progress,
    required this.manualOverride,
    required this.createdAt,
  });

  final String id;
  final String cropId;
  final String userId;
  final String stageName;
  final DateTime startedAt;
  final DateTime expectedEndAt;
  final int daysInStage;
  final int daysRemaining;
  final double progress;
  final bool manualOverride;
  final DateTime createdAt;

  factory CropStageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CropStageModel(
      id: id ?? map['id'] as String? ?? '',
      cropId: map['cropId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      stageName: map['stageName'] as String? ?? '',
      startedAt: MapUtils.dateTimeFromValue(map['startedAt']) ?? DateTime.now(),
      expectedEndAt:
          MapUtils.dateTimeFromValue(map['expectedEndAt']) ?? DateTime.now(),
      daysInStage: (map['daysInStage'] as num?)?.toInt() ?? 0,
      daysRemaining: (map['daysRemaining'] as num?)?.toInt() ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      manualOverride: map['manualOverride'] as bool? ?? false,
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropId': cropId,
      'userId': userId,
      'stageName': stageName,
      'startedAt': startedAt,
      'expectedEndAt': expectedEndAt,
      'daysInStage': daysInStage,
      'daysRemaining': daysRemaining,
      'progress': progress,
      'manualOverride': manualOverride,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory CropStageModel.fromJson(Map<String, dynamic> json) {
    return CropStageModel.fromMap(json);
  }
}
