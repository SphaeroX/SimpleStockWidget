import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

import '../quotes/yahoo/yahoo_quote_provider.dart';
import '../settings/settings_repository.dart';
import '../storage/key_value_store.dart';
import '../watchlist/watchlist_repository.dart';
import 'refresh_service.dart';
import 'update_scheduler.dart';
import 'widget_keys.dart';
import 'widget_storage.dart';

/// URI, die der Reload-Button im Widget an den Hintergrund-Callback schickt.
final reloadUri = Uri.parse('simplestock://reload');

/// URI, die das Widget beim Hinzufügen schickt, damit das Auto-Update geplant wird.
final scheduleUri = Uri.parse('simplestock://schedule');

/// Plant das Auto-Update gemäß gespeicherter Einstellungen (App-Start, Einstellungsänderung, Widget hinzugefügt).
/// Nur Android: iOS bestimmt die Aktualisierung über die WidgetKit-Timeline (Task 12).
Future<void> applyUpdateSchedule() async {
  if (!Platform.isAndroid) return;
  final settings = await SettingsRepository(SharedPreferencesStore()).load();
  await UpdateScheduler(const WorkmanagerScheduler(), hasWidget: hasInstalledHomeWidgets).apply(settings);
}

/// Einstiegspunkt für WorkManager-Jobs (eigenes Hintergrund-Isolate).
@pragma('vm:entry-point')
void workmanagerDispatcher() {
  Workmanager().executeTask((task, input) async {
    try {
      await const HomeWidgetStorage().saveString(
        WidgetKeys.lastBackgroundRun,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
      await createDefaultRefreshService().refresh();
    } catch (_) {
      // Alte Daten bleiben stehen; nächster Lauf versucht es erneut.
    }
    return true;
  });
}

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
  if (uri?.host == scheduleUri.host) {
    await Workmanager().initialize(workmanagerDispatcher);
    await applyUpdateSchedule();
    return;
  }
  if (uri?.host != reloadUri.host) return;
  try {
    await createDefaultRefreshService().refresh(showLoading: true);
  } catch (_) {
    // Alte Daten bleiben stehen; Fehleranzeige folgt in Task 10.
  }
}
