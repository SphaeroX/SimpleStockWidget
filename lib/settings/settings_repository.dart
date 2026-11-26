import 'dart:convert';

import '../storage/key_value_store.dart';
import 'app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._store);
  final KeyValueStore _store;

  static const storageKey = 'settings';

  Future<AppSettings> load() async {
    final raw = await _store.getString(storageKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) => _store.setString(storageKey, jsonEncode(settings.toJson()));
}
