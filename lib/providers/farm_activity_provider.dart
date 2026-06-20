import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../models/farm_activity_model.dart';
import '../repositories/farm_activity_repository.dart';
import '../services/farm_activity_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class FarmActivityProvider extends BaseProvider {
  FarmActivityProvider({
    required FarmActivityRepository farmActivityRepository,
    required FarmActivityService farmActivityService,
    required LocalStorageService localStorageService,
  })  : _farmActivityRepository = farmActivityRepository,
        _farmActivityService = farmActivityService,
        _localStorageService = localStorageService;

  static String _localKey(String userId) => 'farm_activities_$userId';

  final FarmActivityRepository _farmActivityRepository;
  final FarmActivityService _farmActivityService;
  final LocalStorageService _localStorageService;
  final List<FarmActivityModel> _activities = [];

  List<FarmActivityModel> get activities => List.unmodifiable(_activities);

  Future<void> loadActivities(String userId) async {
    setLoading();
    try {
      final loaded = FirebaseRuntime.isAvailable
          ? await _farmActivityRepository.getActivities(userId)
          : _readLocal(userId);
      _activities
        ..clear()
        ..addAll(loaded);
      _activities.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<void> saveActivity(FarmActivityModel activity) async {
    await runGuarded(() async {
      var saved = activity;
      if (FirebaseRuntime.isAvailable) {
        final id = await _farmActivityRepository.saveActivity(activity);
        saved = FarmActivityModel.fromMap({...activity.toMap(), 'id': id});
      }
      _activities.insert(0, saved);
      await _saveLocal(saved.userId);
    });
  }

  FarmActivityModel createActivity({
    required String userId,
    required String type,
    required String title,
    required String description,
    String? cropId,
    String? cropName,
    String? quantity,
    double? cost,
  }) {
    return _farmActivityService.createActivity(
      userId: userId,
      type: type,
      title: title,
      description: description,
      cropId: cropId,
      cropName: cropName,
      quantity: quantity,
      cost: cost,
    );
  }

  List<FarmActivityModel> _readLocal(String userId) {
    final raw = _localStorageService.getString(_localKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map(
          (item) => FarmActivityModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> _saveLocal(String userId) {
    final data = _activities.map((item) => item.toJson()).toList();
    return _localStorageService.setString(_localKey(userId), jsonEncode(data));
  }
}
