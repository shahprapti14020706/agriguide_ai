import '../core/constants/firestore_paths.dart';
import '../models/crop_image_model.dart';
import '../services/firestore_service.dart';

abstract class CropImageRepository {
  Future<List<CropImageModel>> getImages(String userId, {String? cropId});
  Future<String> saveImage(CropImageModel image);
  Future<void> deleteImage(String userId, String imageId);
}

class FirebaseCropImageRepository implements CropImageRepository {
  FirebaseCropImageRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<CropImageModel>> getImages(
    String userId, {
    String? cropId,
  }) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userCropImages(userId),
      queryBuilder: (collection) {
        if (cropId != null && cropId.isNotEmpty) {
          return collection.where('cropId', isEqualTo: cropId);
        }
        return collection;
      },
    );
    return data.map((item) => CropImageModel.fromMap(item)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<String> saveImage(CropImageModel image) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userCropImages(image.userId),
      documentId: image.id,
      data: image.toMap(),
    );
  }

  @override
  Future<void> deleteImage(String userId, String imageId) {
    return _firestoreService.deleteDocument(
      FirestorePaths.userCropImage(userId, imageId),
    );
  }
}
