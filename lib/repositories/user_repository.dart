import '../core/constants/firestore_paths.dart';
import '../models/user_profile_model.dart';
import '../services/firestore_service.dart';

abstract class UserRepository {
  Future<UserProfileModel?> getUserProfile(String userId);

  Stream<UserProfileModel?> watchUserProfile(String userId);

  Future<String> saveUserProfile(UserProfileModel profile);

  Future<String> updateUserProfile(UserProfileModel profile);

  Future<void> deleteUserProfile(String userId);
}

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<UserProfileModel?> getUserProfile(String userId) async {
    final data = await _firestoreService.getDocument(
      FirestorePaths.user(userId),
    );

    return data == null ? null : UserProfileModel.fromMap(data, id: userId);
  }

  @override
  Stream<UserProfileModel?> watchUserProfile(String userId) {
    return _firestoreService
        .watchDocument(FirestorePaths.user(userId))
        .map((data) => data == null ? null : UserProfileModel.fromMap(data));
  }

  @override
  Future<String> saveUserProfile(UserProfileModel profile) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestoreCollections.users,
      documentId: profile.id,
      data: profile.toMap(),
    );
  }

  @override
  Future<String> updateUserProfile(UserProfileModel profile) async {
    await _firestoreService.updateDocument(
      FirestorePaths.user(profile.id),
      {
        ...profile.toMap(),
        'id': profile.id,
      },
    );
    return profile.id;
  }

  @override
  Future<void> deleteUserProfile(String userId) {
    return _firestoreService.deleteDocument(FirestorePaths.user(userId));
  }
}
