import '../core/constants/firestore_paths.dart';
import '../models/farm_activity_model.dart';
import '../services/firestore_service.dart';

abstract class FarmActivityRepository {
  Future<List<FarmActivityModel>> getActivities(String userId);
  Future<String> saveActivity(FarmActivityModel activity);
  Future<void> deleteActivity(String userId, String activityId);
}

class FirebaseFarmActivityRepository implements FarmActivityRepository {
  FirebaseFarmActivityRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<FarmActivityModel>> getActivities(String userId) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userFarmActivities(userId),
      queryBuilder: (collection) => collection.orderBy(
        'activityDate',
        descending: true,
      ),
    );
    return data.map((item) => FarmActivityModel.fromMap(item)).toList();
  }

  @override
  Future<String> saveActivity(FarmActivityModel activity) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userFarmActivities(activity.userId),
      documentId: activity.id,
      data: activity.toMap(),
    );
  }

  @override
  Future<void> deleteActivity(String userId, String activityId) {
    return _firestoreService.deleteDocument(
      FirestorePaths.userFarmActivity(userId, activityId),
    );
  }
}
