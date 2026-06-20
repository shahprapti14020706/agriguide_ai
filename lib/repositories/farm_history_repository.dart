import '../core/constants/firestore_paths.dart';
import '../models/farm_history_model.dart';
import '../services/firestore_service.dart';

abstract class FarmHistoryRepository {
  Future<List<FarmHistoryModel>> getFarmHistory(String userId);

  Stream<List<FarmHistoryModel>> watchFarmHistory(String userId);

  Future<String> addHistoryItem(FarmHistoryModel history);

  Future<void> deleteHistoryItem(String userId, String historyId);
}

class FirebaseFarmHistoryRepository implements FarmHistoryRepository {
  FirebaseFarmHistoryRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<FarmHistoryModel>> getFarmHistory(String userId) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userFarmHistory(userId),
      queryBuilder: (collection) => collection.orderBy(
        'createdAt',
        descending: true,
      ),
    );

    return data
        .map((item) => FarmHistoryModel.fromMap(item))
        .toList(growable: false);
  }

  @override
  Stream<List<FarmHistoryModel>> watchFarmHistory(String userId) {
    return _firestoreService
        .watchCollection(
          FirestorePaths.userFarmHistory(userId),
          queryBuilder: (collection) => collection.orderBy(
            'createdAt',
            descending: true,
          ),
        )
        .map(
          (items) => items
              .map((item) => FarmHistoryModel.fromMap(item))
              .toList(growable: false),
        );
  }

  @override
  Future<String> addHistoryItem(FarmHistoryModel history) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userFarmHistory(history.userId),
      documentId: history.id,
      data: history.toMap(),
    );
  }

  @override
  Future<void> deleteHistoryItem(String userId, String historyId) {
    return _firestoreService.deleteDocument(
      FirestorePaths.userFarmHistoryItem(userId, historyId),
    );
  }
}
