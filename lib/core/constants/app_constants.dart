import 'package:flutter/widgets.dart';

abstract final class AppConstants {
  static const appName = 'AgriGuide AI';
  static const appTagline = 'AI-Powered Agriculture Intelligence Companion';

  static const defaultLocale = Locale('en');
  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  static const requestTimeout = Duration(seconds: 30);
  static const cacheMaxAge = Duration(hours: 6);
}
