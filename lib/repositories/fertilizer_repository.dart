import '../core/constants/firestore_paths.dart';
import '../models/fertilizer_recommendation_model.dart';
import '../services/firestore_service.dart';

abstract class FertilizerRepository {
  Future<List<FertilizerRecommendationModel>> getRecommendations(
    String userId,
  );

  Future<String> saveRecommendation(
    FertilizerRecommendationModel recommendation,
  );
}

class FirebaseFertilizerRepository implements FertilizerRepository {
  FirebaseFertilizerRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<FertilizerRecommendationModel>> getRecommendations(
    String userId,
  ) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userFertilizerRecommendations(userId),
      queryBuilder: (collection) => collection.orderBy(
        'createdAt',
        descending: true,
      ),
    );

    return data
        .map((item) => FertilizerRecommendationModel.fromMap(item))
        .toList(growable: false);
  }

  @override
  Future<String> saveRecommendation(
    FertilizerRecommendationModel recommendation,
  ) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userFertilizerRecommendations(
        recommendation.userId,
      ),
      documentId: recommendation.id,
      data: recommendation.toMap(),
    );
  }
}
