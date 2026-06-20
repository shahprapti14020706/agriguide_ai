import '../core/utils/map_utils.dart';

class CropModel {
  const CropModel({
    required this.id,
    required this.userId,
    required this.cropName,
    required this.variety,
    required this.areaUnderCultivation,
    required this.sowingDate,
    required this.expectedHarvestDate,
    required this.soilType,
    required this.irrigationMethod,
    required this.currentStage,
    required this.cropAgeDays,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.imageUrl,
  });

  final String id;
  final String userId;
  final String cropName;
  final String variety;
  final double areaUnderCultivation;
  final DateTime sowingDate;
  final DateTime expectedHarvestDate;
  final String soilType;
  final String irrigationMethod;
  final String currentStage;
  final int cropAgeDays;
  final String status;
  final String? notes;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CropModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CropModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      cropName: map['cropName'] as String? ?? '',
      variety: map['variety'] as String? ?? '',
      areaUnderCultivation:
          (map['areaUnderCultivation'] as num?)?.toDouble() ?? 0,
      sowingDate:
          MapUtils.dateTimeFromValue(map['sowingDate']) ?? DateTime.now(),
      expectedHarvestDate:
          MapUtils.dateTimeFromValue(map['expectedHarvestDate']) ??
              DateTime.now(),
      soilType: map['soilType'] as String? ?? '',
      irrigationMethod: map['irrigationMethod'] as String? ?? '',
      currentStage: map['currentStage'] as String? ?? '',
      cropAgeDays: (map['cropAgeDays'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'active',
      notes: map['notes'] as String?,
      imageUrl: map['imageUrl'] as String?,
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
      updatedAt: MapUtils.dateTimeFromValue(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropName': cropName,
      'variety': variety,
      'areaUnderCultivation': areaUnderCultivation,
      'sowingDate': sowingDate,
      'expectedHarvestDate': expectedHarvestDate,
      'soilType': soilType,
      'irrigationMethod': irrigationMethod,
      'currentStage': currentStage,
      'cropAgeDays': cropAgeDays,
      'status': status,
      'notes': notes,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel.fromMap(json);
  }

  CropModel copyWith({
    String? id,
    String? userId,
    String? cropName,
    String? variety,
    double? areaUnderCultivation,
    DateTime? sowingDate,
    DateTime? expectedHarvestDate,
    String? soilType,
    String? irrigationMethod,
    String? currentStage,
    int? cropAgeDays,
    String? status,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CropModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropName: cropName ?? this.cropName,
      variety: variety ?? this.variety,
      areaUnderCultivation: areaUnderCultivation ?? this.areaUnderCultivation,
      sowingDate: sowingDate ?? this.sowingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      soilType: soilType ?? this.soilType,
      irrigationMethod: irrigationMethod ?? this.irrigationMethod,
      currentStage: currentStage ?? this.currentStage,
      cropAgeDays: cropAgeDays ?? this.cropAgeDays,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
