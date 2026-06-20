import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../core/config/firebase_runtime.dart';
import '../core/errors/app_exception.dart';

class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  final FirebaseStorage? _firebaseStorage;

  FirebaseStorage get instance {
    _ensureFirebaseEnabled();
    return _firebaseStorage ?? FirebaseStorage.instance;
  }

  Future<String> uploadFile({
    required String storagePath,
    required File file,
    SettableMetadata? metadata,
  }) async {
    try {
      final ref = instance.ref(storagePath);
      final task = await ref.putFile(file, metadata);
      return task.ref.getDownloadURL();
    } on FirebaseException catch (error) {
      throw _mapStorageException(error);
    }
  }

  Future<String> uploadData({
    required String storagePath,
    required Uint8List data,
    SettableMetadata? metadata,
  }) async {
    try {
      final ref = instance.ref(storagePath);
      final task = await ref.putData(data, metadata);
      return task.ref.getDownloadURL();
    } on FirebaseException catch (error) {
      throw _mapStorageException(error);
    }
  }

  Future<void> deleteFile(String storagePath) async {
    try {
      await instance.ref(storagePath).delete();
    } on FirebaseException catch (error) {
      throw _mapStorageException(error);
    }
  }

  Future<String> getDownloadUrl(String storagePath) async {
    try {
      return await instance.ref(storagePath).getDownloadURL();
    } on FirebaseException catch (error) {
      throw _mapStorageException(error);
    }
  }

  void _ensureFirebaseEnabled() {
    if (!FirebaseRuntime.isAvailable) {
      throw const FirebaseDisabledException();
    }
  }

  AppException _mapStorageException(FirebaseException error) {
    return AppException(
      error.message ?? 'Storage operation failed.',
      code: error.code,
      cause: error,
    );
  }
}
