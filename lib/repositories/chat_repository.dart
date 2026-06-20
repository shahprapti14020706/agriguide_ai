import '../core/constants/firestore_paths.dart';
import '../models/chat_message_model.dart';
import '../services/firestore_service.dart';

abstract class ChatRepository {
  Future<List<ChatMessageModel>> getMessages(String userId, String chatId);

  Stream<List<ChatMessageModel>> watchMessages(String userId, String chatId);

  Future<String> addMessage(ChatMessageModel message);

  Future<void> deleteMessage(
    String userId,
    String chatId,
    String messageId,
  );
}

class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<ChatMessageModel>> getMessages(
    String userId,
    String chatId,
  ) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userChatMessages(userId, chatId),
      queryBuilder: (collection) => collection.orderBy('createdAt'),
    );

    return data
        .map((item) => ChatMessageModel.fromMap(item))
        .toList(growable: false);
  }

  @override
  Stream<List<ChatMessageModel>> watchMessages(String userId, String chatId) {
    return _firestoreService
        .watchCollection(
          FirestorePaths.userChatMessages(userId, chatId),
          queryBuilder: (collection) => collection.orderBy('createdAt'),
        )
        .map(
          (items) => items
              .map((item) => ChatMessageModel.fromMap(item))
              .toList(growable: false),
        );
  }

  @override
  Future<String> addMessage(ChatMessageModel message) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userChatMessages(
        message.userId,
        message.chatId,
      ),
      documentId: message.id,
      data: message.toMap(),
    );
  }

  @override
  Future<void> deleteMessage(
    String userId,
    String chatId,
    String messageId,
  ) {
    return _firestoreService.deleteDocument(
      FirestorePaths.userChatMessage(userId, chatId, messageId),
    );
  }
}
