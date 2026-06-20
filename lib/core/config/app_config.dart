abstract final class AppConfig {
  static const appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const enableFirebaseValue = String.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: 'true',
  );

  static const firebaseEnablementExplicit = enableFirebaseValue != '';

  static const enableFirebase = enableFirebaseValue == 'true';

  static const openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '',
  );

  static const agmarknetBaseUrl = String.fromEnvironment(
    'AGMARKNET_BASE_URL',
    defaultValue: '',
  );

  static bool get isProduction => appEnvironment == 'production';
}
