import '../core/utils/map_utils.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.sentAt,
    this.relatedEntityId,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime sentAt;
  final String? relatedEntityId;

  String get message => body;
  bool get isRead => read;
  DateTime get createdAt => sentAt;

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return NotificationModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: (map['body'] as String?) ?? (map['message'] as String?) ?? '',
      type: map['type'] as String? ?? '',
      read: (map['read'] as bool?) ?? (map['isRead'] as bool?) ?? false,
      sentAt: MapUtils.dateTimeFromValue(map['sentAt']) ??
          MapUtils.dateTimeFromValue(map['createdAt']) ??
          DateTime.now(),
      relatedEntityId: map['relatedEntityId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'message': body,
      'type': type,
      'read': read,
      'isRead': read,
      'sentAt': sentAt,
      'createdAt': sentAt,
      'relatedEntityId': relatedEntityId,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel.fromMap(json);
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    bool? read,
    DateTime? sentAt,
    String? relatedEntityId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      read: read ?? this.read,
      sentAt: sentAt ?? this.sentAt,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
    );
  }
}
