import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/config/firebase_runtime.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../di/service_locator.dart';
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
import '../services/firebase_analytics_service.dart';
import 'routes/app_router.dart';
import 'routes/route_names.dart';

class AgriGuideApp extends StatelessWidget {
  const AgriGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => sl<AuthProvider>(),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => sl<LanguageProvider>(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => sl<ProfileProvider>(),
        ),
        ChangeNotifierProvider<CropProvider>(
          create: (_) => sl<CropProvider>(),
        ),
        ChangeNotifierProvider<CropStageProvider>(
          create: (_) => sl<CropStageProvider>(),
        ),
        ChangeNotifierProvider<CropCalendarProvider>(
          create: (_) => sl<CropCalendarProvider>(),
        ),
        ChangeNotifierProvider<CropImageProvider>(
          create: (_) => sl<CropImageProvider>(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => sl<DashboardProvider>(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => sl<ChatProvider>(),
        ),
        ChangeNotifierProvider<DiseaseDetectionProvider>(
          create: (_) => sl<DiseaseDetectionProvider>(),
        ),
        ChangeNotifierProvider<WeatherProvider>(
          create: (_) => sl<WeatherProvider>(),
        ),
        ChangeNotifierProvider<FertilizerProvider>(
          create: (_) => sl<FertilizerProvider>(),
        ),
        ChangeNotifierProvider<IrrigationProvider>(
          create: (_) => sl<IrrigationProvider>(),
        ),
        ChangeNotifierProvider<MarketProvider>(
          create: (_) => sl<MarketProvider>(),
        ),
        ChangeNotifierProvider<SchemeProvider>(
          create: (_) => sl<SchemeProvider>(),
        ),
        ChangeNotifierProvider<ReminderProvider>(
          create: (_) => sl<ReminderProvider>(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => sl<NotificationProvider>(),
        ),
        ChangeNotifierProvider<FarmHistoryProvider>(
          create: (_) => sl<FarmHistoryProvider>(),
        ),
        ChangeNotifierProvider<FarmActivityProvider>(
          create: (_) => sl<FarmActivityProvider>(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: languageProvider.locale,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            navigatorObservers: FirebaseRuntime.isAvailable
                ? [
                    FirebaseAnalyticsObserver(
                      analytics: sl<FirebaseAnalyticsService>().instance,
                    ),
                  ]
                : const [],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('mr'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
