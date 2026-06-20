import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../core/localization/language_strings.dart';
import '../models/crop_model.dart';
import '../models/irrigation_recommendation_model.dart';
import '../models/weather_model.dart';
import '../repositories/irrigation_repository.dart';
import '../services/irrigation_recommendation_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class IrrigationProvider extends BaseProvider {
  IrrigationProvider({
    required IrrigationRepository irrigationRepository,
    required IrrigationRecommendationService recommendationService,
    required LocalStorageService localStorageService,
  })  : _irrigationRepository = irrigationRepository,
        _recommendationService = recommendationService,
        _localStorageService = localStorageService;

  static String _localKey(String userId) =>
      'irrigation_recommendations_$userId';

  final IrrigationRepository _irrigationRepository;
  final IrrigationRecommendationService _recommendationService;
  final LocalStorageService _localStorageService;

  final List<IrrigationRecommendationModel> _history = [];
  IrrigationRecommendationModel? _latestRecommendation;

  List<IrrigationRecommendationModel> get history =>
      List.unmodifiable(_history);
  IrrigationRecommendationModel? get latestRecommendation =>
      _latestRecommendation;

  Future<void> loadRecommendations({
    required String userId,
    CropModel? crop,
    WeatherModel? weather,
    AppLanguage language = AppLanguage.english,
  }) async {
    setLoading();

    try {
      final history = FirebaseRuntime.isAvailable
          ? await _irrigationRepository.getRecommendations(userId)
          : _readLocal(userId);

      _history
        ..clear()
        ..addAll(history);

      if (_history.isEmpty && crop != null) {
        await generateRecommendation(
          userId: userId,
          crop: crop,
          weather: weather,
          language: language,
        );
        return;
      }

      _latestRecommendation = _history.isEmpty ? null : _history.first;
      _history.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<void> generateRecommendation({
    required String userId,
    required CropModel crop,
    WeatherModel? weather,
    AppLanguage language = AppLanguage.english,
  }) async {
    await runGuarded(() async {
      var recommendation = _recommendationService.buildRecommendation(
        userId: userId,
        crop: crop,
        weather: weather,
        language: language,
      );

      if (FirebaseRuntime.isAvailable) {
        final savedId = await _irrigationRepository.saveRecommendation(
          recommendation,
        );
        recommendation = recommendation.copyWith(id: savedId);
      }

      _history.insert(0, recommendation);
      _latestRecommendation = recommendation;
      await _saveLocal(userId);
    });
  }

  List<IrrigationRecommendationModel> _readLocal(String userId) {
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
          (item) => IrrigationRecommendationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _saveLocal(String userId) {
    final data = _history.map((item) => item.toJson()).toList(growable: false);
    return _localStorageService.setString(_localKey(userId), jsonEncode(data));
  }
}
