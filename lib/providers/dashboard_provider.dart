import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../core/localization/language_strings.dart';
import '../models/chat_message_model.dart';
import '../models/crop_model.dart';
import '../models/market_price_model.dart';
import '../models/reminder_model.dart';
import '../models/user_profile_model.dart';
import '../models/weather_model.dart';
import '../repositories/crop_repository.dart';
import '../repositories/market_repository.dart';
import '../repositories/reminder_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/weather_repository.dart';
import '../services/local_storage_service.dart';
import '../services/market_service.dart';
import '../services/reminder_service.dart';
import '../services/weather_advisory_service.dart';
import 'base_provider.dart';
import 'crop_provider.dart';
import 'language_provider.dart';
import 'profile_provider.dart';
import 'reminder_provider.dart';
import 'weather_provider.dart';

class DashboardProvider extends BaseProvider {
  DashboardProvider({
    required CropRepository cropRepository,
    required WeatherRepository weatherRepository,
    required ReminderRepository reminderRepository,
    required MarketRepository marketRepository,
    required UserRepository userRepository,
    required WeatherAdvisoryService weatherAdvisoryService,
    required ReminderService reminderService,
    required MarketService marketService,
    required LocalStorageService localStorageService,
  })  : _cropRepository = cropRepository,
        _weatherRepository = weatherRepository,
        _reminderRepository = reminderRepository,
        _marketRepository = marketRepository,
        _userRepository = userRepository,
        _weatherAdvisoryService = weatherAdvisoryService,
        _reminderService = reminderService,
        _marketService = marketService,
        _localStorageService = localStorageService;

  final CropRepository _cropRepository;
  final WeatherRepository _weatherRepository;
  final ReminderRepository _reminderRepository;
  final MarketRepository _marketRepository;
  final UserRepository _userRepository;
  final WeatherAdvisoryService _weatherAdvisoryService;
  final ReminderService _reminderService;
  final MarketService _marketService;
  final LocalStorageService _localStorageService;

  List<CropModel> _activeCrops = const [];
  UserProfileModel? _profile;
  WeatherModel? _weatherSummary;
  List<ReminderModel> _pendingReminders = const [];
  MarketPriceModel? _marketSnapshot;
  ChatMessageModel? _aiInsight;

  List<CropModel> get activeCrops => _activeCrops;
  WeatherModel? get weatherSummary => _weatherSummary;
  List<ReminderModel> get pendingReminders => _pendingReminders;
  MarketPriceModel? get marketSnapshot => _marketSnapshot;
  ChatMessageModel? get aiInsight => _aiInsight;

  Future<void> loadDashboard(String userId, {AppLanguage? language}) async {
    setLoading();

    try {
      final selectedLanguage = language ?? _selectedLanguage();
      _activeCrops = await _loadActiveCrops(userId);
      _profile = await _loadProfile(userId);
      _weatherSummary = await _loadWeatherSummary(userId, selectedLanguage);
      _pendingReminders = await _loadPendingReminders(userId);
      _marketSnapshot = await _loadMarketSnapshot();
      _aiInsight = _buildAiInsight(userId, selectedLanguage);
      setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<List<CropModel>> _loadActiveCrops(String userId) async {
    var crops = <CropModel>[];
    if (FirebaseRuntime.isAvailable) {
      crops = await _cropRepository.getCrops(userId);
    }

    if (crops.isEmpty) {
      crops = _readLocalCrops(userId);
    }

    return crops
        .where((crop) => crop.status == 'active')
        .toList(growable: false);
  }

  Future<WeatherModel?> _loadWeatherSummary(
    String userId,
    AppLanguage language,
  ) async {
    var history = <WeatherModel>[];

    if (FirebaseRuntime.isAvailable) {
      history = await _weatherRepository.getWeatherHistory(userId);
    }

    if (history.isEmpty) {
      history = _readLocalWeatherHistory(userId);
    }

    final localizedHistory = history
        .where((item) => item.languageCode == language.code)
        .toList(growable: false);

    if (localizedHistory.isNotEmpty) {
      return localizedHistory.first;
    }

    final weather = _weatherAdvisoryService.buildAdvisory(
      userId: userId,
      profile: _profile,
      crops: _activeCrops,
      language: language,
    );
    await _saveLocalWeatherHistory(userId, [weather]);
    return weather;
  }

  Future<List<ReminderModel>> _loadPendingReminders(String userId) async {
    var reminders = <ReminderModel>[];

    if (FirebaseRuntime.isAvailable) {
      reminders = await _reminderRepository.getReminders(userId);
    }

    if (reminders.isEmpty) {
      reminders = _readLocalReminders(userId);
    }

    if (reminders.isEmpty && _activeCrops.isNotEmpty) {
      reminders = _reminderService.generateCropStageReminders(
        userId: userId,
        crops: _activeCrops,
      );
      await _saveLocalReminders(userId, reminders);
    }

    final activeCropIds = _activeCrops.map((crop) => crop.id).toSet();
    final activeCropNames =
        _activeCrops.map((crop) => crop.cropName.trim().toLowerCase()).toSet();

    final upcoming = reminders.where((reminder) {
      final cropId = reminder.cropId;
      final cropName = reminder.cropName?.trim().toLowerCase();
      final appliesToActiveCrop = (cropId == null && cropName == null) ||
          (cropId != null && activeCropIds.contains(cropId)) ||
          (cropName != null && activeCropNames.contains(cropName));
      return !reminder.completed && appliesToActiveCrop;
    }).toList(growable: false)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return upcoming.take(3).toList(growable: false);
  }

  Future<MarketPriceModel?> _loadMarketSnapshot() async {
    var prices = <MarketPriceModel>[];
    final cropName = _activeCrops.isEmpty ? '' : _activeCrops.first.cropName;

    if (FirebaseRuntime.isAvailable && cropName.trim().isNotEmpty) {
      prices = await _marketRepository.searchMarketPrices(
        cropName: cropName,
        state: _profile?.state,
        district: _profile?.district,
      );
    }

    if (prices.isEmpty) {
      prices = _marketService.fallbackPrices(
        profile: _profile,
        crops: _activeCrops,
      );
    }

    final filtered = _marketService.filterPrices(
      prices: prices,
      query: cropName,
      state: _profile?.state ?? '',
      district: _profile?.district ?? '',
    );

    return (filtered.isEmpty ? prices : filtered).isEmpty
        ? null
        : (filtered.isEmpty ? prices : filtered).first;
  }

  Future<UserProfileModel?> _loadProfile(String userId) async {
    if (FirebaseRuntime.isAvailable) {
      final profile = await _userRepository.getUserProfile(userId);
      if (profile != null) {
        return profile;
      }
    }

    final raw = _localStorageService.getString(
      ProfileProvider.localProfileKey(userId),
    );
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return UserProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<WeatherModel> _readLocalWeatherHistory(String userId) {
    final raw = _localStorageService.getString(
      WeatherProvider.localWeatherKey(userId),
    );
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

  Future<void> _saveLocalWeatherHistory(
    String userId,
    List<WeatherModel> history,
  ) {
    final data = history.map((item) => item.toJson()).toList(growable: false);
    return _localStorageService.setString(
      WeatherProvider.localWeatherKey(userId),
      jsonEncode(data),
    );
  }

  List<ReminderModel> _readLocalReminders(String userId) {
    final raw = _localStorageService.getString(
      ReminderProvider.localRemindersKey(userId),
    );
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => ReminderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> _saveLocalReminders(
    String userId,
    List<ReminderModel> reminders,
  ) {
    final data = reminders.map((item) => item.toJson()).toList(growable: false);
    return _localStorageService.setString(
      ReminderProvider.localRemindersKey(userId),
      jsonEncode(data),
    );
  }

  ChatMessageModel? _buildAiInsight(String userId, AppLanguage language) {
    if (_activeCrops.isEmpty) {
      return null;
    }

    final crop = _activeCrops.first;
    final stage = crop.currentStage.isEmpty
        ? _pick(language, 'current', 'वर्तमान', 'सध्याच्या')
        : crop.currentStage;
    final farmContext = _farmContextText(language);
    final weatherAction = _weatherSummary?.suggestedAction;
    final nextReminder =
        _pendingReminders.isEmpty ? null : _pendingReminders.first;
    final reminderText = nextReminder == null
        ? _pick(
            language,
            'Plan the next field check for this crop.',
            'इस फसल के लिए अगली खेत जांच की योजना बनाएं।',
            'या पिकासाठी पुढील शेत तपासणीची योजना करा.',
          )
        : _pick(
            language,
            '${nextReminder.type} is due ${_relativeDueText(nextReminder.scheduledAt, language)}.',
            '${nextReminder.type} ${_relativeDueText(nextReminder.scheduledAt, language)} देय है।',
            '${nextReminder.type} ${_relativeDueText(nextReminder.scheduledAt, language)} नियोजित आहे.',
          );
    final weatherText = weatherAction == null || weatherAction.isEmpty
        ? _pick(
            language,
            'Check soil moisture before irrigation.',
            'सिंचाई से पहले मिट्टी की नमी जांचें।',
            'सिंचनापूर्वी मातीतील ओलावा तपासा.',
          )
        : weatherAction;

    return ChatMessageModel(
      id: 'local_dashboard_insight',
      chatId: 'dashboard',
      userId: userId,
      role: 'assistant',
      message: _pick(
        language,
        '${crop.cropName} is in $stage stage$farmContext. $reminderText $weatherText',
        '${crop.cropName} $stage अवस्था में है$farmContext। $reminderText $weatherText',
        '${crop.cropName} $stage अवस्थेत आहे$farmContext. $reminderText $weatherText',
      ),
      supportedTopic: true,
      responseSections: const {},
      contextUsed: {
        'cropId': crop.id,
        'stage': stage,
        if (nextReminder != null) 'reminderId': nextReminder.id,
        if (_weatherSummary != null) 'weatherId': _weatherSummary!.id,
      },
      createdAt: DateTime.now(),
    );
  }

  List<CropModel> _readLocalCrops(String userId) {
    final raw = _localStorageService.getString(
      CropProvider.localCropsKey(userId),
    );
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => CropModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  AppLanguage _selectedLanguage() {
    return AppLanguage.fromCode(
      _localStorageService.getString(LanguageProvider.selectedLanguageKey),
    );
  }

  String _farmContextText(AppLanguage language) {
    final parts = [
      if (_profile?.soilType.trim().isNotEmpty == true)
        _pick(
          language,
          '${_profile!.soilType} soil',
          '${_profile!.soilType} मिट्टी',
          '${_profile!.soilType} माती',
        ),
      if (_profile?.irrigationMethod.trim().isNotEmpty == true)
        _pick(
          language,
          '${_profile!.irrigationMethod} irrigation',
          '${_profile!.irrigationMethod} सिंचाई',
          '${_profile!.irrigationMethod} सिंचन',
        ),
    ];
    if (parts.isEmpty) {
      return '';
    }
    return _pick(
      language,
      ' with ${parts.join(' and ')}',
      ' और ${parts.join(' व ')} के साथ',
      ' आणि ${parts.join(' व ')}सह',
    );
  }

  String _relativeDueText(DateTime scheduledAt, AppLanguage language) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
    );
    final days = dueDay.difference(today).inDays;
    if (days <= 0) {
      return _pick(language, 'today', 'आज', 'आज');
    }
    if (days == 1) {
      return _pick(language, 'tomorrow', 'कल', 'उद्या');
    }
    return _pick(
      language,
      'within $days days',
      '$days दिनों के भीतर',
      '$days दिवसांत',
    );
  }

  String _pick(AppLanguage language, String en, String hi, String mr) {
    return switch (language) {
      AppLanguage.hindi => hi,
      AppLanguage.marathi => mr,
      AppLanguage.english => en,
    };
  }
}
