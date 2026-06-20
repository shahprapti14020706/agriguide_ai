import '../core/errors/app_exception.dart';
import '../models/auth_user_model.dart';
import '../services/firebase_auth_service.dart';

abstract class AuthRepository {
  AuthUserModel? get currentUser;

  Stream<AuthUserModel?> authStateChanges();

  Future<AuthUserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._authService);

  final FirebaseAuthService _authService;

  @override
  AuthUserModel? get currentUser {
    final user = _authService.currentUser;
    return user == null ? null : AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Stream<AuthUserModel?> authStateChanges() {
    return _authService.authStateChanges().map(
          (user) => user == null ? null : AuthUserModel.fromFirebaseUser(user),
        );
  }

  @override
  Future<AuthUserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw const DataNotFoundException('Registered user was not returned.');
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw const DataNotFoundException('Signed-in user was not returned.');
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }
}
