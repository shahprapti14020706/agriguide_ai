import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/config/firebase_runtime.dart';
import '../core/errors/app_exception.dart';

class FirebaseMessagingService {
  FirebaseMessagingService({FirebaseMessaging? firebaseMessaging})
      : _firebaseMessaging = firebaseMessaging;

  final FirebaseMessaging? _firebaseMessaging;

  FirebaseMessaging get instance {
    _ensureFirebaseEnabled();
    return _firebaseMessaging ?? FirebaseMessaging.instance;
  }

  Stream<RemoteMessage> get foregroundMessages {
    _ensureFirebaseEnabled();
    return FirebaseMessaging.onMessage;
  }

  Future<NotificationSettings> requestPermission() async {
    try {
      return await instance.requestPermission();
    } on FirebaseException catch (error) {
      throw _mapMessagingException(error);
    }
  }

  Future<String?> getToken() async {
    try {
      return await instance.getToken();
    } on FirebaseException catch (error) {
      throw _mapMessagingException(error);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await instance.subscribeToTopic(topic);
    } on FirebaseException catch (error) {
      throw _mapMessagingException(error);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await instance.unsubscribeFromTopic(topic);
    } on FirebaseException catch (error) {
      throw _mapMessagingException(error);
    }
  }

  void _ensureFirebaseEnabled() {
    if (!FirebaseRuntime.isAvailable) {
      throw const FirebaseDisabledException();
    }
  }

  AppException _mapMessagingException(FirebaseException error) {
    return AppException(
      error.message ?? 'Firebase Messaging operation failed.',
      code: error.code,
      cause: error,
    );
  }
}
