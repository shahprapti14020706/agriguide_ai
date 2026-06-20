import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../core/config/firebase_runtime.dart';
import '../core/errors/app_exception.dart';

class FirebaseCrashlyticsService {
  FirebaseCrashlyticsService({FirebaseCrashlytics? firebaseCrashlytics})
      : _firebaseCrashlytics = firebaseCrashlytics;

  final FirebaseCrashlytics? _firebaseCrashlytics;

  FirebaseCrashlytics get instance {
    _ensureFirebaseEnabled();
    return _firebaseCrashlytics ?? FirebaseCrashlytics.instance;
  }

  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await instance.setCrashlyticsCollectionEnabled(enabled);
    } on FirebaseException catch (error) {
      throw _mapCrashlyticsException(error);
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      await instance.setUserIdentifier(userId);
    } on FirebaseException catch (error) {
      throw _mapCrashlyticsException(error);
    }
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } on FirebaseException catch (firebaseError) {
      throw _mapCrashlyticsException(firebaseError);
    }
  }

  FlutterExceptionHandler get flutterErrorHandler {
    _ensureFirebaseEnabled();
    return (details) {
      instance.recordFlutterFatalError(details);
    };
  }

  void _ensureFirebaseEnabled() {
    if (!FirebaseRuntime.isAvailable) {
      throw const FirebaseDisabledException();
    }
  }

  AppException _mapCrashlyticsException(FirebaseException error) {
    return AppException(
      error.message ?? 'Firebase Crashlytics operation failed.',
      code: error.code,
      cause: error,
    );
  }
}
