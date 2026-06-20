import 'package:firebase_auth/firebase_auth.dart';

import '../core/config/firebase_runtime.dart';
import '../core/errors/app_exception.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  FirebaseAuth get instance {
    _ensureFirebaseEnabled();
    return _firebaseAuth ?? FirebaseAuth.instance;
  }

  User? get currentUser => instance.currentUser;

  Stream<User?> authStateChanges() => instance.authStateChanges();

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AppException(
        error.message ?? 'Unable to create account.',
        code: error.code,
        cause: error,
      );
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AppException(
        error.message ?? 'Unable to sign in.',
        code: error.code,
        cause: error,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AppException(
        error.message ?? 'Unable to send password reset email.',
        code: error.code,
        cause: error,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await instance.signOut();
    } on FirebaseAuthException catch (error) {
      throw AppException(
        error.message ?? 'Unable to sign out.',
        code: error.code,
        cause: error,
      );
    }
  }

  void _ensureFirebaseEnabled() {
    if (!FirebaseRuntime.isAvailable) {
      throw const FirebaseDisabledException();
    }
  }
}
