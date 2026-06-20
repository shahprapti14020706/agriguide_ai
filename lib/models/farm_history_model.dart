import '../core/utils/map_utils.dart';

class FarmHistoryModel {
  const FarmHistoryModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.metadata,
    required this.createdAt,
    this.cropId,
    this.cropName,
    this.relatedEntityId,
  });

  final String id;
  final String userId;
  final String type;
  final String? cropId;
  final String? cropName;
  final String? relatedEntityId;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  factory FarmHistoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return FarmHistoryModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      cropId: map['cropId'] as String?,
      cropName: map['cropName'] as String?,
      relatedEntityId: map['relatedEntityId'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      metadata: MapUtils.stringMapFromValue(map['metadata']),
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'cropId': cropId,
      'cropName': cropName,
      'relatedEntityId': relatedEntityId,
      'title': title,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory FarmHistoryModel.fromJson(Map<String, dynamic> json) {
    return FarmHistoryModel.fromMap(json);
  }
}
