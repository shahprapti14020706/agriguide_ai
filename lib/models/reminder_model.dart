import '../core/utils/map_utils.dart';

class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.completed,
    required this.priority,
    required this.createdAt,
    this.cropId,
    this.cropName,
    this.status = 'pending',
    this.completedAt,
    this.snoozedUntil,
  });

  final String id;
  final String userId;
  final String? cropId;
  final String? cropName;
  final String type;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final bool completed;
  final String status;
  final DateTime? completedAt;
  final DateTime? snoozedUntil;
  final String priority;
  final DateTime createdAt;

  factory ReminderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final completed = (map['completed'] as bool?) ??
        ((map['status'] as String? ?? '').toLowerCase() == 'completed');

    return ReminderModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      cropId: map['cropId'] as String?,
      cropName: map['cropName'] as String?,
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      scheduledAt: MapUtils.dateTimeFromValue(map['scheduledAt']) ??
          MapUtils.dateTimeFromValue(map['dueDate']) ??
          DateTime.now(),
      completed: completed,
      status: map['status'] as String? ?? (completed ? 'completed' : 'pending'),
      completedAt: MapUtils.dateTimeFromValue(map['completedAt']),
      snoozedUntil: MapUtils.dateTimeFromValue(map['snoozedUntil']),
      priority: map['priority'] as String? ?? 'normal',
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  DateTime get dueDate => scheduledAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'cropName': cropName,
      'type': type,
      'title': title,
      'description': description,
      'scheduledAt': scheduledAt,
      'dueDate': scheduledAt,
      'completed': completed,
      'status': status,
      'completedAt': completedAt,
      'snoozedUntil': snoozedUntil,
      'priority': priority,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel.fromMap(json);
  }

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? cropId,
    String? cropName,
    String? type,
    String? title,
    String? description,
    DateTime? scheduledAt,
    bool? completed,
    String? status,
    DateTime? completedAt,
    DateTime? snoozedUntil,
    String? priority,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completed: completed ?? this.completed,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
