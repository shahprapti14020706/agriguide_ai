class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    if (code == null) {
      return 'AppException: $message';
    }

    return 'AppException($code): $message';
  }
}

class FirebaseDisabledException extends AppException {
  const FirebaseDisabledException()
      : super(
          'Firebase is disabled. Start the app with '
          '--dart-define=ENABLE_FIREBASE=true after Firebase is configured.',
          code: 'firebase-disabled',
        );
}

class DataNotFoundException extends AppException {
  const DataNotFoundException(super.message) : super(code: 'data-not-found');
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause})
      : super(code: 'network-error');
}
