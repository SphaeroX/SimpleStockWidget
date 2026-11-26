/// Keys im gemeinsamen home_widget-Speicher. In Kotlin/Swift exakt gespiegelt.
abstract final class WidgetKeys {
  static const payload = 'ssw_payload';

  /// Zeitstempel (ms) eines laufenden Refreshs, leer wenn keiner läuft.
  static const loading = 'ssw_loading';

  /// Zeitstempel (ms) der letzten WorkManager-Ausführung (Debugging).
  static const lastBackgroundRun = 'ssw_last_background_run';
}
