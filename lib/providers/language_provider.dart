import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../core/localization/language_strings.dart';
import '../services/local_storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider({
    required LocalStorageService localStorageService,
  }) : _localStorageService = localStorageService;

  static const selectedLanguageKey = 'selected_language';

  final LocalStorageService _localStorageService;

  AppLanguage _language = AppLanguage.english;
  bool _initialized = false;

  AppLanguage get language => _language;
  LanguageStrings get strings => LanguageStrings(_language);
  Locale get locale => _language.locale;
  bool get initialized => _initialized;
  bool get hasSelectedLanguage =>
      _localStorageService.getString(selectedLanguageKey)?.isNotEmpty ?? false;

  Future<void> initialize() async {
    final code = _localStorageService.getString(selectedLanguageKey);
    _language = AppLanguage.fromCode(code);
    _initialized = true;
    notifyListeners();
  }

  Future<void> selectLanguage(AppLanguage language) async {
    _language = language;
    _initialized = true;
    await _localStorageService.setString(selectedLanguageKey, language.code);
    notifyListeners();
  }
}

extension LanguageContext on BuildContext {
  LanguageStrings get l10n => watch<LanguageProvider>().strings;
}
