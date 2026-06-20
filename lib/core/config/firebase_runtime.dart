import 'package:firebase_core/firebase_core.dart';

import 'app_config.dart';

abstract final class FirebaseRuntime {
  static bool get isAvailable =>
      AppConfig.enableFirebase && Firebase.apps.isNotEmpty;
}
