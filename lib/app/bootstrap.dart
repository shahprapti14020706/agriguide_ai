import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/config/firebase_runtime.dart';
import '../di/service_locator.dart';
import '../firebase_options.dart';
import '../services/firebase_analytics_service.dart';
import '../services/firebase_crashlytics_service.dart';
import '../services/firebase_messaging_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();
  _validateProductionConfiguration();
  await _initializeFirebaseIfEnabled();
  await _configureFirebaseIntegrations();

  runApp(const AgriGuideApp());
}

void _validateProductionConfiguration() {
  if (!AppConfig.isProduction) {
    return;
  }

  if (!AppConfig.firebaseEnablementExplicit || !AppConfig.enableFirebase) {
    throw StateError(
      'Production builds must explicitly enable Firebase with '
      '--dart-define=APP_ENV=production '
      '--dart-define=ENABLE_FIREBASE=true.',
    );
  }
}

Future<void> _initializeFirebaseIfEnabled() async {
  if (!AppConfig.enableFirebase) {
    return;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'bootstrap',
        context: ErrorDescription('Firebase initialization failed.'),
      ),
    );
    rethrow;
  }
}

Future<void> _configureFirebaseIntegrations() async {
  if (!FirebaseRuntime.isAvailable) {
    return;
  }

  try {
    final crashlyticsService = sl<FirebaseCrashlyticsService>();
    await crashlyticsService.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = crashlyticsService.flutterErrorHandler;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      crashlyticsService.recordError(error, stackTrace, fatal: true);
      return true;
    };

    await sl<FirebaseMessagingService>().requestPermission();
    await sl<FirebaseMessagingService>().getToken();
    await sl<FirebaseAnalyticsService>().logEvent(name: 'app_started');
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'bootstrap',
        context: ErrorDescription('Firebase integration setup failed.'),
      ),
    );
  }
}
