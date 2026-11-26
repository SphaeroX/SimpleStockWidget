const _weekdays = ['Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.', 'So.'];

String _two(int v) => v.toString().padLeft(2, '0');

/// Kopfzeile des Widgets, z. B. „22:48 Mi.“ (ohne intl-Initialisierung, auch im Hintergrund-Isolate nutzbar).
String formatUpdatedLabel(DateTime t) => '${_two(t.hour)}:${_two(t.minute)} ${_weekdays[t.weekday - 1]}';
