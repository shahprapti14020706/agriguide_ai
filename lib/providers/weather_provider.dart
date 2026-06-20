import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../core/localization/language_strings.dart';
import '../models/crop_model.dart';
import '../models/user_profile_model.dart';
import '../models/weather_model.dart';
import '../repositories/weather_repository.dart';
import '../services/local_storage_service.dart';
import '../services/weather_advisory_service.dart';
import 'base_provider.dart';

class WeatherProvider extends BaseProvider {
  WeatherProvider({
    required WeatherRepository weatherRepository,
    required WeatherAdvisoryService weatherAdvisoryService,
    required LocalStorageService localStorageService,
  })  : _weatherRepository = weatherRepository,
        _weatherAdvisoryService = weatherAdvisoryService,
        _localStorageService = localStorageService;

  static String localWeatherKey(String userId) => 'weather_advisories_$userId';

  final WeatherRepository _weatherRepository;
  final WeatherAdvisoryService _weatherAdvisoryService;
  final LocalStorageService _localStorageService;

  final List<WeatherModel> _history = [];
  WeatherModel? _currentWeather;

  List<WeatherModel> get history => List.unmodifiable(_history);
  WeatherModel? get currentWeather => _currentWeather;

  Future<void> loadWeather({
    required String userId,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
    AppLanguage language = AppLanguage.english,
  }) async {
    setLoading();

    try {
      final history = FirebaseRuntime.isAvailable
          ? await _weatherRepository.getWeatherHistory(userId)
          : _readLocalHistory(userId);

      final localizedHistory = history
          .where((item) => item.languageCode == language.code)
          .toList(growable: false);

      _history
        ..clear()
        ..addAll(localizedHistory);

      if (_history.isEmpty) {
        await generateWeather(
          userId: userId,
          profile: profile,
          crops: crops,
          language: language,
        );
        return;
      }

      _currentWeather = _history.first;
      setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<void> generateWeather({
    required String userId,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
    AppLanguage language = AppLanguage.english,
  }) async {
    await runGuarded(() async {
      var weather = _weatherAdvisoryService.buildAdvisory(
        userId: userId,
        profile: profile,
        crops: crops,
        language: language,
      );

      if (FirebaseRuntime.isAvailable) {
        final savedId = await _weatherRepository.saveWeatherData(weather);
        weather = weather.copyWith(id: savedId);
      }

      _history.insert(0, weather);
      _currentWeather = weather;
      await _saveLocalHistory(userId);
    });
  }

  List<WeatherModel> _readLocalHistory(String userId) {
    final raw = _localStorageService.getString(localWeatherKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => WeatherModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> _saveLocalHistory(String userId) {
    final data = _history.map((item) => item.toJson()).toList(growable: false);
    return _localStorageService.setString(
      localWeatherKey(userId),
      jsonEncode(data),
    );
  }
}
