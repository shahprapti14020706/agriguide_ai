import '../core/utils/map_utils.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.role,
    required this.message,
    required this.supportedTopic,
    required this.responseSections,
    required this.contextUsed,
    required this.createdAt,
    this.intent,
  });

  final String id;
  final String chatId;
  final String userId;
  final String role;
  final String message;
  final String? intent;
  final bool supportedTopic;
  final Map<String, dynamic> responseSections;
  final Map<String, dynamic> contextUsed;
  final DateTime createdAt;

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessageModel(
      id: id ?? map['id'] as String? ?? '',
      chatId: map['chatId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      message: map['message'] as String? ?? '',
      intent: map['intent'] as String?,
      supportedTopic: map['supportedTopic'] as bool? ?? true,
      responseSections: MapUtils.stringMapFromValue(map['responseSections']),
      contextUsed: MapUtils.stringMapFromValue(map['contextUsed']),
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'userId': userId,
      'role': role,
      'message': message,
      'intent': intent,
      'supportedTopic': supportedTopic,
      'responseSections': responseSections,
      'contextUsed': contextUsed,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel.fromMap(json);
  }
}
