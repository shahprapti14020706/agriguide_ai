import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  String? getString(String key) => _preferences.getString(key);

  Future<bool> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  bool? getBool(String key) => _preferences.getBool(key);

  Future<bool> setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  int? getInt(String key) => _preferences.getInt(key);

  Future<bool> setInt(String key, int value) {
    return _preferences.setInt(key, value);
  }

  double? getDouble(String key) => _preferences.getDouble(key);

  Future<bool> setDouble(String key, double value) {
    return _preferences.setDouble(key, value);
  }

  List<String> getStringList(String key) {
    return _preferences.getStringList(key) ?? const [];
  }

  Future<bool> setStringList(String key, List<String> value) {
    return _preferences.setStringList(key, value);
  }

  Future<bool> remove(String key) => _preferences.remove(key);

  Future<bool> clear() => _preferences.clear();
}
