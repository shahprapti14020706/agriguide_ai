import '../core/utils/map_utils.dart';

class CropCalendarModel {
  const CropCalendarModel({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.activities,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final List<CropCalendarActivityModel> activities;
  final DateTime createdAt;

  factory CropCalendarModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawActivities = map['activities'];
    return CropCalendarModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      cropId: map['cropId'] as String? ?? '',
      cropName: map['cropName'] as String? ?? '',
      activities: rawActivities is List
          ? rawActivities
              .whereType<Map>()
              .map(
                (item) => CropCalendarActivityModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const [],
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'cropName': cropName,
      'activities': activities.map((item) => item.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
}

class CropCalendarActivityModel {
  const CropCalendarActivityModel({
    required this.type,
    required this.title,
    required this.description,
    required this.scheduledDate,
  });

  final String type;
  final String title;
  final String description;
  final DateTime scheduledDate;

  factory CropCalendarActivityModel.fromMap(Map<String, dynamic> map) {
    return CropCalendarActivityModel(
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      scheduledDate:
          MapUtils.dateTimeFromValue(map['scheduledDate']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate,
    };
  }
}
