import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/config/firebase_runtime.dart';
import '../core/errors/app_exception.dart';

class FirebaseAnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? firebaseAnalytics})
      : _firebaseAnalytics = firebaseAnalytics;

  final FirebaseAnalytics? _firebaseAnalytics;

  FirebaseAnalytics get instance {
    _ensureFirebaseEnabled();
    return _firebaseAnalytics ?? FirebaseAnalytics.instance;
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await instance.logEvent(name: name, parameters: parameters);
    } on FirebaseException catch (error) {
      throw _mapAnalyticsException(error);
    }
  }

  Future<void> setUserId(String? userId) async {
    try {
      await instance.setUserId(id: userId);
    } on FirebaseException catch (error) {
      throw _mapAnalyticsException(error);
    }
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await instance.setUserProperty(name: name, value: value);
    } on FirebaseException catch (error) {
      throw _mapAnalyticsException(error);
    }
  }

  void _ensureFirebaseEnabled() {
    if (!FirebaseRuntime.isAvailable) {
      throw const FirebaseDisabledException();
    }
  }

  AppException _mapAnalyticsException(FirebaseException error) {
    return AppException(
      error.message ?? 'Firebase Analytics operation failed.',
      code: error.code,
      cause: error,
    );
  }
}
