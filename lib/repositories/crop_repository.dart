import '../core/constants/firestore_paths.dart';
import '../models/crop_model.dart';
import '../services/firestore_service.dart';

abstract class CropRepository {
  Future<List<CropModel>> getCrops(String userId);

  Stream<List<CropModel>> watchCrops(String userId);

  Future<CropModel?> getCrop(String userId, String cropId);

  Future<String> addCrop(CropModel crop);

  Future<void> updateCrop(CropModel crop);

  Future<void> deleteCrop(String userId, String cropId);
}

class FirebaseCropRepository implements CropRepository {
  FirebaseCropRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<CropModel>> getCrops(String userId) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userCrops(userId),
      queryBuilder: (collection) => collection.orderBy(
        'createdAt',
        descending: true,
      ),
    );

    return data.map((item) => CropModel.fromMap(item)).toList(growable: false);
  }

  @override
  Stream<List<CropModel>> watchCrops(String userId) {
    return _firestoreService
        .watchCollection(
          FirestorePaths.userCrops(userId),
          queryBuilder: (collection) => collection.orderBy(
            'createdAt',
            descending: true,
          ),
        )
        .map(
          (items) => items
              .map((item) => CropModel.fromMap(item))
              .toList(growable: false),
        );
  }

  @override
  Future<CropModel?> getCrop(String userId, String cropId) async {
    final data = await _firestoreService.getDocument(
      FirestorePaths.userCrop(userId, cropId),
    );

    return data == null ? null : CropModel.fromMap(data, id: cropId);
  }

  @override
  Future<String> addCrop(CropModel crop) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userCrops(crop.userId),
      documentId: crop.id,
      data: crop.toMap(),
    );
  }

  @override
  Future<void> updateCrop(CropModel crop) {
    return _firestoreService.updateDocument(
      FirestorePaths.userCrop(crop.userId, crop.id),
      crop.toMap(),
    );
  }

  @override
  Future<void> deleteCrop(String userId, String cropId) {
    return _firestoreService.deleteDocument(
      FirestorePaths.userCrop(userId, cropId),
    );
  }
}
