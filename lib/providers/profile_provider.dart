import 'dart:convert';

import '../models/user_profile_model.dart';
import '../repositories/user_repository.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class ProfileProvider extends BaseProvider {
  ProfileProvider({
    required UserRepository userRepository,
    required LocalStorageService localStorageService,
  })  : _userRepository = userRepository,
        _localStorageService = localStorageService;

  static String localProfileKey(String userId) => 'profile_$userId';

  final UserRepository _userRepository;
  final LocalStorageService _localStorageService;

  UserProfileModel? _profile;
  String? _successMessage;

  UserProfileModel? get profile => _profile;
  String? get successMessage => _successMessage;
  bool get hasCompletedProfile => _profile?.profileCompleted ?? false;

  Future<void> loadProfile(String userId) async {
    setLoading();

    try {
      try {
        _profile = await _userRepository.getUserProfile(userId);
      } catch (_) {
        _profile = _readLocalProfile(userId);
      }
      _profile == null ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    await runGuarded(() async {
      var completedProfile = profile.copyWith(
        profileCompleted: true,
        updatedAt: DateTime.now(),
      );

      try {
        final savedProfileId = await _userRepository.saveUserProfile(
          completedProfile,
        );
        completedProfile = completedProfile.copyWith(id: savedProfileId);
      } catch (_) {
        await _saveLocalProfile(completedProfile);
        _profile = completedProfile;
        _successMessage = 'Farmer profile saved locally';
        return;
      }

      await _saveLocalProfile(completedProfile);
      _profile = completedProfile;
      _successMessage = 'Farmer profile saved successfully';
    });
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    await runGuarded(() async {
      var updatedProfile = profile.copyWith(updatedAt: DateTime.now());

      try {
        final savedProfileId = await _userRepository.updateUserProfile(
          updatedProfile,
        );
        updatedProfile = updatedProfile.copyWith(id: savedProfileId);
      } catch (_) {
        await _saveLocalProfile(updatedProfile);
        _profile = updatedProfile;
        _successMessage = 'Farmer profile updated locally';
        return;
      }

      await _saveLocalProfile(updatedProfile);
      _profile = updatedProfile;
      _successMessage = 'Farmer profile updated successfully';
    });
  }

  void clearMessages() {
    _successMessage = null;
    resetState();
  }

  UserProfileModel? _readLocalProfile(String userId) {
    final raw = _localStorageService.getString(localProfileKey(userId));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return UserProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _saveLocalProfile(UserProfileModel profile) {
    return _localStorageService.setString(
      localProfileKey(profile.id),
      jsonEncode(profile.toJson()),
    );
  }
}
