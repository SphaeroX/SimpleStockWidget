import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../quotes/yahoo/yahoo_quote_provider.dart';
import '../settings/settings_repository.dart';
import '../storage/key_value_store.dart';
import '../watchlist/watchlist_repository.dart';
import 'refresh_service.dart';
import 'widget_storage.dart';

/// URI, die der Reload-Button im Widget an den Hintergrund-Callback schickt.
final reloadUri = Uri.parse('simplestock://reload');

/// Produktive Verdrahtung des Refresh-Ablaufs für Isolates ohne Riverpod (Widget-Callback, WorkManager).
RefreshService createDefaultRefreshService() {
  final store = SharedPreferencesStore();
  return RefreshService(
    quotes: YahooQuoteProvider(http.Client()),
    watchlist: WatchlistRepository(store),
    widgetStorage: const HomeWidgetStorage(),
    settings: SettingsRepository(store),
  );
}

/// Wird von home_widget in einem Hintergrund-Isolate aufgerufen (Reload-Button im Widget).
@pragma('vm:entry-point')
Future<void> widgetInteractivityCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri?.host != reloadUri.host) return;
  try {
    await createDefaultRefreshService().refresh(showLoading: true);
  } catch (_) {
    // Alte Daten bleiben stehen; Fehleranzeige folgt in Task 10.
  }
}
