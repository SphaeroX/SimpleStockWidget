import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../quotes/providers.dart';
import '../settings/app_settings.dart';
import '../settings/settings_repository.dart';
import '../storage/key_value_store.dart';
import '../watchlist/watchlist_entry.dart';
import '../watchlist/watchlist_repository.dart';
import '../widget_sync/background.dart';
import '../widget_sync/refresh_service.dart';
import '../widget_sync/widget_storage.dart';

final keyValueStoreProvider = Provider<KeyValueStore>((ref) => SharedPreferencesStore());

final widgetStorageProvider = Provider<WidgetStorage>((ref) => const HomeWidgetStorage());

final watchlistRepositoryProvider = Provider<WatchlistRepository>(
  (ref) => WatchlistRepository(ref.watch(keyValueStoreProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(keyValueStoreProvider)),
);

final refreshServiceProvider = Provider<RefreshService>(
  (ref) => RefreshService(
    quotes: ref.watch(quoteProviderProvider),
    watchlist: ref.watch(watchlistRepositoryProvider),
    widgetStorage: ref.watch(widgetStorageProvider),
    settings: ref.watch(settingsRepositoryProvider),
  ),
);

/// Plant das Auto-Update neu; in Tests durch einen No-op ersetzbar.
final scheduleUpdatesProvider = Provider<Future<void> Function()>((ref) => applyUpdateSchedule);

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => ref.read(settingsRepositoryProvider).load();

  Future<void> change(AppSettings Function(AppSettings) change) async {
    final current = state.value ?? await future;
    final next = change(current);
    await ref.read(settingsRepositoryProvider).save(next);
    state = AsyncData(next);
    ref.read(refreshServiceProvider).refresh().ignore();
    if (next.updateInterval != current.updateInterval) ref.read(scheduleUpdatesProvider)().ignore();
  }
}

final watchlistProvider = AsyncNotifierProvider<WatchlistNotifier, List<WatchlistEntry>>(WatchlistNotifier.new);

class WatchlistNotifier extends AsyncNotifier<List<WatchlistEntry>> {
  WatchlistRepository get _repo => ref.read(watchlistRepositoryProvider);

  @override
  Future<List<WatchlistEntry>> build() => _repo.load();

  Future<void> add(WatchlistEntry entry) => _apply(() => _repo.add(entry));
  Future<void> remove(String symbol) => _apply(() => _repo.remove(symbol));
  Future<void> reorder(int oldIndex, int newIndex) => _apply(() => _repo.reorder(oldIndex, newIndex));
  Future<void> replace(WatchlistEntry entry) => _apply(() => _repo.replace(entry));

  Future<void> _apply(Future<List<WatchlistEntry>> Function() change) async {
    state = AsyncData(await change());
    _refreshWidget();
  }

  void _refreshWidget() {
    ref.read(refreshServiceProvider).refresh().ignore();
  }
}
