import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../models/crop_model.dart';
import '../models/farm_history_model.dart';
import '../repositories/farm_history_repository.dart';
import '../services/farm_history_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class FarmHistoryProvider extends BaseProvider {
  FarmHistoryProvider({
    required FarmHistoryRepository farmHistoryRepository,
    required FarmHistoryService farmHistoryService,
    required LocalStorageService localStorageService,
  })  : _farmHistoryRepository = farmHistoryRepository,
        _farmHistoryService = farmHistoryService,
        _localStorageService = localStorageService;

  static String _localKey(String userId) => 'farm_history_$userId';

  final FarmHistoryRepository _farmHistoryRepository;
  final FarmHistoryService _farmHistoryService;
  final LocalStorageService _localStorageService;

  final List<FarmHistoryModel> _history = [];
  String _typeFilter = '';
  String _cropFilter = '';

  List<FarmHistoryModel> get history {
    return _history.where((item) {
      final typeMatches = _typeFilter.isEmpty || item.type == _typeFilter;
      final cropMatches = _cropFilter.isEmpty || item.cropId == _cropFilter;
      return typeMatches && cropMatches;
    }).toList(growable: false);
  }

  Future<void> loadHistory(
    String userId, {
    List<CropModel> crops = const [],
  }) async {
    setLoading();
    try {
      final loaded = FirebaseRuntime.isAvailable
          ? await _farmHistoryRepository.getFarmHistory(userId)
          : _readLocal(userId);
      _history
        ..clear()
        ..addAll(loaded);
      if (_history.isEmpty) {
        _history.addAll(
          _farmHistoryService.fallbackHistory(userId: userId, crops: crops),
        );
        await _saveLocal(userId);
      }
      _history.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  void applyFilters({String type = '', String cropId = ''}) {
    _typeFilter = type;
    _cropFilter = cropId;
    history.isEmpty ? setEmpty() : setSuccess();
  }

  Future<void> addHistory(FarmHistoryModel item) async {
    await runGuarded(() async {
      var saved = item;
      if (FirebaseRuntime.isAvailable) {
        final id = await _farmHistoryRepository.addHistoryItem(item);
        saved = FarmHistoryModel.fromMap({...item.toMap(), 'id': id});
      }
      _history.insert(0, saved);
      await _saveLocal(saved.userId);
    });
  }

  FarmHistoryModel? byId(String id) {
    for (final item in _history) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  List<FarmHistoryModel> _readLocal(String userId) {
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
          (item) => FarmHistoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<void> _saveLocal(String userId) {
    final data = _history.map((item) => item.toJson()).toList(growable: false);
    return _localStorageService.setString(_localKey(userId), jsonEncode(data));
  }
}
