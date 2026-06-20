import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../core/errors/app_exception.dart';
import '../models/auth_user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/firebase_analytics_service.dart';
import '../services/firebase_crashlytics_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class AuthProvider extends BaseProvider {
  AuthProvider({
    required AuthRepository authRepository,
    required LocalStorageService localStorageService,
    required FirebaseAnalyticsService analyticsService,
    required FirebaseCrashlyticsService crashlyticsService,
    required FirebaseMessagingService messagingService,
  })  : _authRepository = authRepository,
        _localStorageService = localStorageService,
        _analyticsService = analyticsService,
        _crashlyticsService = crashlyticsService,
        _messagingService = messagingService;

  static const _authUserKey = 'auth_user';
  static const _onboardingCompleteKey = 'onboarding_complete';

  final AuthRepository _authRepository;
  final LocalStorageService _localStorageService;
  final FirebaseAnalyticsService _analyticsService;
  final FirebaseCrashlyticsService _crashlyticsService;
  final FirebaseMessagingService _messagingService;

  AuthUserModel? _currentUser;
  String? _successMessage;

  AuthUserModel? get currentUser => _currentUser;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get onboardingComplete =>
      _localStorageService.getBool(_onboardingCompleteKey) ?? false;

  Future<void> initialize() async {
    setLoading();

    try {
      _currentUser = FirebaseRuntime.isAvailable
          ? _authRepository.currentUser
          : _readLocalUser();
      await _syncFirebaseUserState(_currentUser);
      setSuccess();
    } catch (error) {
      _currentUser = _readLocalUser();
      await _syncFirebaseUserState(_currentUser);
      setSuccess();
    }
  }

  Future<void> completeOnboarding() async {
    await _localStorageService.setBool(_onboardingCompleteKey, true);
    safeNotifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await runGuarded(() async {
      _currentUser = FirebaseRuntime.isAvailable
          ? await _authRepository.registerWithEmailAndPassword(
              email: email,
              password: password,
            )
          : AuthUserModel(
              id: _localUserId(email),
              email: email.trim(),
              displayName: fullName.trim(),
              emailVerified: true,
            );

      await _saveLocalUser(_currentUser!);
      await _syncFirebaseUserState(_currentUser);
      _successMessage = 'Account created successfully';
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await runGuarded(() async {
      _currentUser = FirebaseRuntime.isAvailable
          ? await _authRepository.signInWithEmailAndPassword(
              email: email,
              password: password,
            )
          : AuthUserModel(
              id: _localUserId(email),
              email: email.trim(),
              emailVerified: true,
            );

      await _saveLocalUser(_currentUser!);
      await _syncFirebaseUserState(_currentUser);
      _successMessage = 'Signed in successfully';
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await runGuarded(() async {
      if (FirebaseRuntime.isAvailable) {
        await _authRepository.sendPasswordResetEmail(email.trim());
      }

      _successMessage = 'Password reset instructions have been sent';
    });
  }

  Future<void> logout() async {
    await runGuarded(() async {
      final previousUser = _currentUser;
      if (FirebaseRuntime.isAvailable) {
        try {
          await _authRepository.signOut();
        } catch (_) {
          // Keep local session cleanup resilient if Firebase sign-out fails.
        }
      }

      _currentUser = null;
      await _localStorageService.remove(_authUserKey);
      await _clearFirebaseUserState(previousUser);
      _successMessage = 'Signed out successfully';
    });
  }

  void clearMessages() {
    _successMessage = null;
    resetState();
  }

  AuthUserModel? _readLocalUser() {
    final raw = _localStorageService.getString(_authUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return AuthUserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _saveLocalUser(AuthUserModel user) {
    return _localStorageService.setString(
      _authUserKey,
      jsonEncode(user.toJson()),
    );
  }

  String _localUserId(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw const AppException('Email is required');
    }

    return 'local_${normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
  }

  Future<void> _syncFirebaseUserState(AuthUserModel? user) async {
    if (!FirebaseRuntime.isAvailable) {
      return;
    }

    try {
      await _analyticsService.setUserId(user?.id);
      if (user != null) {
        await _crashlyticsService.setUserId(user.id);
        await _messagingService.subscribeToTopic('users_${user.id}');
      }
    } catch (_) {
      // Analytics, Crashlytics, and FCM should never block auth state changes.
    }
  }

  Future<void> _clearFirebaseUserState(AuthUserModel? user) async {
    if (!FirebaseRuntime.isAvailable) {
      return;
    }

    try {
      if (user != null) {
        await _messagingService.unsubscribeFromTopic('users_${user.id}');
      }
      await _analyticsService.setUserId(null);
    } catch (_) {
      // Firebase side effects should never block local logout.
    }
  }
}
