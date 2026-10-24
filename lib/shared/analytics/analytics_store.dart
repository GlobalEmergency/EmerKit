import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AnalyticsStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesAnalyticsStore implements AnalyticsStore {
  SharedPreferencesAsync? _instance;
  SharedPreferencesAsync get _preferences =>
      _instance ??= SharedPreferencesAsync();
  static const _key = 'emerkit_analytics_v1';

  @override
  Future<String?> read() async => _preferences.getString(_key);

  @override
  Future<void> write(String value) async => _preferences.setString(_key, value);
}
