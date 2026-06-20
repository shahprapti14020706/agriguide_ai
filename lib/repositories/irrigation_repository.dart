import '../core/constants/firestore_paths.dart';
import '../models/irrigation_recommendation_model.dart';
import '../services/firestore_service.dart';

abstract class IrrigationRepository {
  Future<List<IrrigationRecommendationModel>> getRecommendations(
    String userId,
  );

  Future<String> saveRecommendation(
    IrrigationRecommendationModel recommendation,
  );
}

class FirebaseIrrigationRepository implements IrrigationRepository {
  FirebaseIrrigationRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<IrrigationRecommendationModel>> getRecommendations(
    String userId,
  ) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userIrrigationRecommendations(userId),
      queryBuilder: (collection) => collection.orderBy(
        'createdAt',
        descending: true,
      ),
    );

    return data
        .map((item) => IrrigationRecommendationModel.fromMap(item))
        .toList(growable: false);
  }

  @override
  Future<String> saveRecommendation(
    IrrigationRecommendationModel recommendation,
  ) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userIrrigationRecommendations(
        recommendation.userId,
      ),
      documentId: recommendation.id,
      data: recommendation.toMap(),
    );
  }
}
