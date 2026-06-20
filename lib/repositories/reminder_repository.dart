import '../core/constants/firestore_paths.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';

abstract class ReminderRepository {
  Future<List<ReminderModel>> getReminders(String userId);

  Stream<List<ReminderModel>> watchReminders(String userId);

  Future<String> addReminder(ReminderModel reminder);

  Future<void> updateReminder(ReminderModel reminder);

  Future<void> deleteReminder(String userId, String reminderId);
}

class FirebaseReminderRepository implements ReminderRepository {
  FirebaseReminderRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<ReminderModel>> getReminders(String userId) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userReminders(userId),
      queryBuilder: (collection) => collection.orderBy('scheduledAt'),
    );

    return data
        .map((item) => ReminderModel.fromMap(item))
        .toList(growable: false);
  }

  @override
  Stream<List<ReminderModel>> watchReminders(String userId) {
    return _firestoreService
        .watchCollection(
          FirestorePaths.userReminders(userId),
          queryBuilder: (collection) => collection.orderBy('scheduledAt'),
        )
        .map(
          (items) => items
              .map((item) => ReminderModel.fromMap(item))
              .toList(growable: false),
        );
  }

  @override
  Future<String> addReminder(ReminderModel reminder) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userReminders(reminder.userId),
      documentId: reminder.id,
      data: reminder.toMap(),
    );
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) {
    return _firestoreService.updateDocument(
      FirestorePaths.userReminder(reminder.userId, reminder.id),
      reminder.toMap(),
    );
  }

  @override
  Future<void> deleteReminder(String userId, String reminderId) {
    return _firestoreService.deleteDocument(
      FirestorePaths.userReminder(userId, reminderId),
    );
  }
}
