import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase options are only configured for Android in this project.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2GJc9J-OvHizJOuY2xDm8GcuvHe3a8gc',
    appId: '1:822926761732:android:5b83f74e19fefa1e817a51',
    messagingSenderId: '822926761732',
    projectId: 'agriguide-ai-cd650',
    storageBucket: 'agriguide-ai-cd650.firebasestorage.app',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB6Im6irpzkGqSTaxWuwIuzbfbLY23NHrg',
    appId: '1:822926761732:web:850f11e03c7b503c817a51',
    messagingSenderId: '822926761732',
    projectId: 'agriguide-ai-cd650',
    authDomain: 'agriguide-ai-cd650.firebaseapp.com',
    storageBucket: 'agriguide-ai-cd650.firebasestorage.app',
    measurementId: 'G-0VWSB9LSM8',
  );
}
