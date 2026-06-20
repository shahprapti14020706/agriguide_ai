import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/crop_provider.dart';
import '../providers/crop_calendar_provider.dart';
import '../providers/crop_image_provider.dart';
import '../providers/crop_stage_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/disease_detection_provider.dart';
import '../providers/fertilizer_provider.dart';
import '../providers/farm_history_provider.dart';
import '../providers/farm_activity_provider.dart';
import '../providers/irrigation_provider.dart';
import '../providers/language_provider.dart';
import '../providers/market_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/scheme_provider.dart';
import '../providers/weather_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/crop_repository.dart';
import '../repositories/crop_image_repository.dart';
import '../repositories/crop_stage_repository.dart';
import '../repositories/disease_repository.dart';
import '../repositories/farm_history_repository.dart';
import '../repositories/farm_activity_repository.dart';
import '../repositories/fertilizer_repository.dart';
import '../repositories/irrigation_repository.dart';
import '../repositories/market_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/reminder_repository.dart';
import '../repositories/scheme_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/weather_repository.dart';
import '../services/agriculture_ai_agent_service.dart';
import '../services/agriculture_intent_detection_service.dart';
import '../services/agriculture_knowledge_retrieval_service.dart';
import '../services/agriculture_recommendation_engine.dart';
import '../services/disease_analysis_service.dart';
import '../services/disease_recommendation_engine.dart';
import '../services/disease_severity_analyzer.dart';
import '../services/firebase_analytics_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_crashlytics_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';
import '../services/crop_calendar_service.dart';
import '../services/crop_stage_service.dart';
import '../services/farm_activity_service.dart';
import '../services/farm_context_builder.dart';
import '../services/farm_context_service.dart';
import '../services/fertilizer_recommendation_service.dart';
import '../services/app_notification_service.dart';
import '../services/farm_history_service.dart';
import '../services/irrigation_recommendation_service.dart';
import '../services/local_storage_service.dart';
import '../services/market_service.dart';
import '../services/network_service.dart';
import '../services/reminder_service.dart';
import '../services/scheme_service.dart';
import '../services/weather_advisory_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (sl.isRegistered<AppConfigMarker>()) {
    return;
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<AppConfigMarker>(const AppConfigMarker())
    ..registerSingleton<SharedPreferences>(sharedPreferences)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfo(sl<Connectivity>()),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient())
    ..registerLazySingleton<NetworkService>(
      () => NetworkService(
        apiClient: sl<ApiClient>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    ..registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<AgricultureIntentDetectionService>(
      AgricultureIntentDetectionService.new,
    )
    ..registerLazySingleton<AgricultureKnowledgeRetrievalService>(
      AgricultureKnowledgeRetrievalService.new,
    )
    ..registerLazySingleton<AgricultureRecommendationEngine>(
      AgricultureRecommendationEngine.new,
    )
    ..registerLazySingleton<AgricultureAiAgentService>(
      () => AgricultureAiAgentService(
        intentDetectionService: sl<AgricultureIntentDetectionService>(),
        knowledgeRetrievalService: sl<AgricultureKnowledgeRetrievalService>(),
        recommendationEngine: sl<AgricultureRecommendationEngine>(),
      ),
    )
    ..registerLazySingleton<WeatherAdvisoryService>(
      WeatherAdvisoryService.new,
    )
    ..registerLazySingleton<FertilizerRecommendationService>(
      FertilizerRecommendationService.new,
    )
    ..registerLazySingleton<IrrigationRecommendationService>(
      IrrigationRecommendationService.new,
    )
    ..registerLazySingleton<CropStageService>(CropStageService.new)
    ..registerLazySingleton<CropCalendarService>(CropCalendarService.new)
    ..registerLazySingleton<FarmActivityService>(FarmActivityService.new)
    ..registerLazySingleton<FarmContextBuilder>(FarmContextBuilder.new)
    ..registerLazySingleton<FarmContextService>(FarmContextService.new)
    ..registerLazySingleton<MarketService>(MarketService.new)
    ..registerLazySingleton<SchemeService>(SchemeService.new)
    ..registerLazySingleton<ReminderService>(ReminderService.new)
    ..registerLazySingleton<AppNotificationService>(
      AppNotificationService.new,
    )
    ..registerLazySingleton<FarmHistoryService>(FarmHistoryService.new)
    ..registerLazySingleton<DiseaseSeverityAnalyzer>(
      DiseaseSeverityAnalyzer.new,
    )
    ..registerLazySingleton<DiseaseRecommendationEngine>(
      DiseaseRecommendationEngine.new,
    )
    ..registerLazySingleton<DiseaseAnalysisService>(
      () => DiseaseAnalysisService(
        severityAnalyzer: sl<DiseaseSeverityAnalyzer>(),
        recommendationEngine: sl<DiseaseRecommendationEngine>(),
      ),
    )
    ..registerLazySingleton<FirestoreDatabaseService>(
      FirestoreDatabaseService.new,
    )
    ..registerLazySingleton<FirestoreService>(
      () => sl<FirestoreDatabaseService>(),
    )
    ..registerLazySingleton<FirebaseAuthService>(FirebaseAuthService.new)
    ..registerLazySingleton<FirebaseStorageService>(
      FirebaseStorageService.new,
    )
    ..registerLazySingleton<FirebaseMessagingService>(
      FirebaseMessagingService.new,
    )
    ..registerLazySingleton<FirebaseAnalyticsService>(
      FirebaseAnalyticsService.new,
    )
    ..registerLazySingleton<FirebaseCrashlyticsService>(
      FirebaseCrashlyticsService.new,
    )
    ..registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(sl<FirebaseAuthService>()),
    )
    ..registerLazySingleton<UserRepository>(
      () => FirebaseUserRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<CropRepository>(
      () => FirebaseCropRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<CropStageRepository>(
      () => FirebaseCropStageRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<CropImageRepository>(
      () => FirebaseCropImageRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<DiseaseRepository>(
      () => FirebaseDiseaseRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<ChatRepository>(
      () => FirebaseChatRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<WeatherRepository>(
      () => FirebaseWeatherRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<FertilizerRepository>(
      () => FirebaseFertilizerRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<IrrigationRepository>(
      () => FirebaseIrrigationRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<MarketRepository>(
      () => FirebaseMarketRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<SchemeRepository>(
      () => FirebaseSchemeRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<ReminderRepository>(
      () => FirebaseReminderRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<NotificationRepository>(
      () => FirebaseNotificationRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<FarmHistoryRepository>(
      () => FirebaseFarmHistoryRepository(sl<FirestoreService>()),
    )
    ..registerLazySingleton<FarmActivityRepository>(
      () => FirebaseFarmActivityRepository(sl<FirestoreService>()),
    )
    ..registerFactory<AuthProvider>(
      () => AuthProvider(
        authRepository: sl<AuthRepository>(),
        localStorageService: sl<LocalStorageService>(),
        analyticsService: sl<FirebaseAnalyticsService>(),
        crashlyticsService: sl<FirebaseCrashlyticsService>(),
        messagingService: sl<FirebaseMessagingService>(),
      ),
    )
    ..registerFactory<LanguageProvider>(
      () => LanguageProvider(
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<ProfileProvider>(
      () => ProfileProvider(
        userRepository: sl<UserRepository>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<CropProvider>(
      () => CropProvider(
        cropRepository: sl<CropRepository>(),
        storageService: sl<FirebaseStorageService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<CropStageProvider>(
      () => CropStageProvider(cropStageService: sl<CropStageService>()),
    )
    ..registerFactory<CropCalendarProvider>(
      () => CropCalendarProvider(
        cropCalendarService: sl<CropCalendarService>(),
      ),
    )
    ..registerFactory<CropImageProvider>(
      () => CropImageProvider(
        cropImageRepository: sl<CropImageRepository>(),
        storageService: sl<FirebaseStorageService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<DashboardProvider>(
      () => DashboardProvider(
        cropRepository: sl<CropRepository>(),
        weatherRepository: sl<WeatherRepository>(),
        reminderRepository: sl<ReminderRepository>(),
        marketRepository: sl<MarketRepository>(),
        userRepository: sl<UserRepository>(),
        weatherAdvisoryService: sl<WeatherAdvisoryService>(),
        reminderService: sl<ReminderService>(),
        marketService: sl<MarketService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<ChatProvider>(
      () => ChatProvider(
        chatRepository: sl<ChatRepository>(),
        aiAgentService: sl<AgricultureAiAgentService>(),
        farmContextBuilder: sl<FarmContextBuilder>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<DiseaseDetectionProvider>(
      () => DiseaseDetectionProvider(
        diseaseRepository: sl<DiseaseRepository>(),
        diseaseAnalysisService: sl<DiseaseAnalysisService>(),
        storageService: sl<FirebaseStorageService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<WeatherProvider>(
      () => WeatherProvider(
        weatherRepository: sl<WeatherRepository>(),
        weatherAdvisoryService: sl<WeatherAdvisoryService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<FertilizerProvider>(
      () => FertilizerProvider(
        fertilizerRepository: sl<FertilizerRepository>(),
        recommendationService: sl<FertilizerRecommendationService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<IrrigationProvider>(
      () => IrrigationProvider(
        irrigationRepository: sl<IrrigationRepository>(),
        recommendationService: sl<IrrigationRecommendationService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<MarketProvider>(
      () => MarketProvider(
        marketRepository: sl<MarketRepository>(),
        marketService: sl<MarketService>(),
      ),
    )
    ..registerFactory<SchemeProvider>(
      () => SchemeProvider(
        schemeRepository: sl<SchemeRepository>(),
        schemeService: sl<SchemeService>(),
      ),
    )
    ..registerFactory<ReminderProvider>(
      () => ReminderProvider(
        reminderRepository: sl<ReminderRepository>(),
        reminderService: sl<ReminderService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<NotificationProvider>(
      () => NotificationProvider(
        notificationRepository: sl<NotificationRepository>(),
        notificationService: sl<AppNotificationService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<FarmHistoryProvider>(
      () => FarmHistoryProvider(
        farmHistoryRepository: sl<FarmHistoryRepository>(),
        farmHistoryService: sl<FarmHistoryService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    )
    ..registerFactory<FarmActivityProvider>(
      () => FarmActivityProvider(
        farmActivityRepository: sl<FarmActivityRepository>(),
        farmActivityService: sl<FarmActivityService>(),
        localStorageService: sl<LocalStorageService>(),
      ),
    );
}

class AppConfigMarker {
  const AppConfigMarker();

  String get environment => AppConfig.appEnvironment;
  bool get firebaseEnabled => AppConfig.enableFirebase;
}
