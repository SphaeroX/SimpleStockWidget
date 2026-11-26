/// Keys im gemeinsamen home_widget-Speicher. In Kotlin/Swift exakt gespiegelt.
abstract final class WidgetKeys {
  static const payload = 'ssw_payload';

  /// Zeitstempel (ms) eines laufenden Refreshs, leer wenn keiner läuft.
  static const loading = 'ssw_loading';

  /// Fehlerhinweis des letzten Refreshs (z. B. „Offline · Stand 22:48 Mi.“), leer wenn erfolgreich.
  static const error = 'ssw_error';

  /// Zeitstempel (ms) der letzten WorkManager-Ausführung (Debugging).
  static const lastBackgroundRun = 'ssw_last_background_run';
}
