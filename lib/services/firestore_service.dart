import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/config/firebase_runtime.dart';
import '../core/errors/app_exception.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get instance {
    _ensureFirebaseEnabled();
    return _firestore ?? FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return instance.collection(path);
  }

  DocumentReference<Map<String, dynamic>> document(String path) {
    return instance.doc(path);
  }

  Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      final snapshot = await document(path).get();
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return null;
      }

      return {
        ...data,
        'id': snapshot.id,
      };
    } on FirebaseException catch (error) {
      debugPrint('Firestore getDocument failed: path=$path code=${error.code}');
      throw _mapFirestoreException(error);
    }
  }

  Future<List<Map<String, dynamic>>> getCollection(
    String path, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>> collection,
    )? queryBuilder,
  }) async {
    try {
      final baseCollection = collection(path);
      final query = queryBuilder?.call(baseCollection) ?? baseCollection;
      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => {
              ...doc.data(),
              'id': doc.id,
            },
          )
          .toList(growable: false);
    } on FirebaseException catch (error) {
      debugPrint('Firestore getCollection failed: path=$path code=${error.code}');
      throw _mapFirestoreException(error);
    }
  }

  Stream<Map<String, dynamic>?> watchDocument(String path) {
    return document(path).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      return {
        ...data,
        'id': snapshot.id,
      };
    });
  }

  Stream<List<Map<String, dynamic>>> watchCollection(
    String path, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>> collection,
    )? queryBuilder,
  }) {
    final baseCollection = collection(path);
    final query = queryBuilder?.call(baseCollection) ?? baseCollection;

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  ...doc.data(),
                  'id': doc.id,
                },
              )
              .toList(growable: false),
        );
  }

  Future<String> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      final doc = await collection(collectionPath).add(data);
      return doc.id;
    } on FirebaseException catch (error) {
      throw _mapFirestoreException(error);
    }
  }

  Future<String> setDocumentWithId({
    required String collectionPath,
    required String? documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    try {
      final doc = documentId == null || documentId.trim().isEmpty
          ? collection(collectionPath).doc()
          : collection(collectionPath).doc(documentId.trim());

      await doc.set(
        {
          ...data,
          'id': doc.id,
        },
        SetOptions(merge: merge),
      );

      return doc.id;
    } on FirebaseException catch (error) {
      throw _mapFirestoreException(error);
    }
  }

  Future<void> setDocument(
    String documentPath,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      await document(documentPath).set(data, SetOptions(merge: merge));
    } on FirebaseException catch (error) {
      throw _mapFirestoreException(error);
    }
  }

  Future<void> updateDocument(
    String documentPath,
    Map<String, dynamic> data,
  ) async {
    try {
      await document(documentPath).update(data);
    } on FirebaseException catch (error) {
      throw _mapFirestoreException(error);
    }
  }

  Future<void> deleteDocument(String documentPath) async {
    try {
      await document(documentPath).delete();
    } on FirebaseException catch (error) {
      throw _mapFirestoreException(error);
    }
  }

  void _ensureFirebaseEnabled() {
    if (!FirebaseRuntime.isAvailable) {
      throw const FirebaseDisabledException();
    }
  }

  AppException _mapFirestoreException(FirebaseException error) {
    return AppException(
      error.message ?? 'Firestore operation failed.',
      code: error.code,
      cause: error,
    );
  }
}

class FirestoreDatabaseService extends FirestoreService {
  FirestoreDatabaseService({super.firestore});
}
