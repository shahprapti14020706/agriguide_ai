import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../core/localization/language_strings.dart';
import '../models/crop_model.dart';
import '../models/fertilizer_recommendation_model.dart';
import '../models/weather_model.dart';
import '../repositories/fertilizer_repository.dart';
import '../services/fertilizer_recommendation_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class FertilizerProvider extends BaseProvider {
  FertilizerProvider({
    required FertilizerRepository fertilizerRepository,
    required FertilizerRecommendationService recommendationService,
    required LocalStorageService localStorageService,
  })  : _fertilizerRepository = fertilizerRepository,
        _recommendationService = recommendationService,
        _localStorageService = localStorageService;

  static String _localKey(String userId) =>
      'fertilizer_recommendations_$userId';

  final FertilizerRepository _fertilizerRepository;
  final FertilizerRecommendationService _recommendationService;
  final LocalStorageService _localStorageService;

  final List<FertilizerRecommendationModel> _history = [];
  FertilizerRecommendationModel? _latestRecommendation;

  List<FertilizerRecommendationModel> get history =>
      List.unmodifiable(_history);
  FertilizerRecommendationModel? get latestRecommendation =>
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
          ? await _fertilizerRepository.getRecommendations(userId)
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
        final savedId = await _fertilizerRepository.saveRecommendation(
          recommendation,
        );
        recommendation = recommendation.copyWith(id: savedId);
      }

      _history.insert(0, recommendation);
      _latestRecommendation = recommendation;
      await _saveLocal(userId);
    });
  }

  List<FertilizerRecommendationModel> _readLocal(String userId) {
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
          (item) => FertilizerRecommendationModel.fromJson(
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
