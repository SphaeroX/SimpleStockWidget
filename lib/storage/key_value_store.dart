import 'package:shared_preferences/shared_preferences.dart';

/// Minimaler String-Speicher; in Tests durch eine In-Memory-Variante ersetzt.
abstract interface class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
}

/// Nutzt [SharedPreferencesAsync] (ohne Cache), damit App-Isolate und
/// Hintergrund-Isolates (Reload-Button, WorkManager) dieselben Daten sehen.
class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore([SharedPreferencesAsync? prefs]) : _prefs = prefs ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _prefs;

  @override
  Future<String?> getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
}
