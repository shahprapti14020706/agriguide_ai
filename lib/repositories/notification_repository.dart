import '../core/constants/firestore_paths.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);

  Stream<List<NotificationModel>> watchNotifications(String userId);

  Future<String> addNotification(NotificationModel notification);

  Future<void> markAsRead(String userId, String notificationId);

  Future<void> deleteNotification(String userId, String notificationId);
}

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userNotifications(userId),
      queryBuilder: (collection) => collection.orderBy(
        'sentAt',
        descending: true,
      ),
    );

    return data
        .map((item) => NotificationModel.fromMap(item))
        .toList(growable: false);
  }

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _firestoreService
        .watchCollection(
          FirestorePaths.userNotifications(userId),
          queryBuilder: (collection) => collection.orderBy(
            'sentAt',
            descending: true,
          ),
        )
        .map(
          (items) => items
              .map((item) => NotificationModel.fromMap(item))
              .toList(growable: false),
        );
  }

  @override
  Future<String> addNotification(NotificationModel notification) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userNotifications(notification.userId),
      documentId: notification.id,
      data: notification.toMap(),
    );
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) {
    return _firestoreService.updateDocument(
      FirestorePaths.userNotification(userId, notificationId),
      {'read': true},
    );
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) {
    return _firestoreService.deleteDocument(
      FirestorePaths.userNotification(userId, notificationId),
    );
  }
}
