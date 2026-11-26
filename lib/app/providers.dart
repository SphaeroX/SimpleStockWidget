import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../quotes/providers.dart';
import '../storage/key_value_store.dart';
import '../watchlist/watchlist_entry.dart';
import '../watchlist/watchlist_repository.dart';
import '../widget_sync/refresh_service.dart';
import '../widget_sync/widget_storage.dart';

final keyValueStoreProvider = Provider<KeyValueStore>((ref) => SharedPreferencesStore());

final widgetStorageProvider = Provider<WidgetStorage>((ref) => const HomeWidgetStorage());

final watchlistRepositoryProvider = Provider<WatchlistRepository>(
  (ref) => WatchlistRepository(ref.watch(keyValueStoreProvider)),
);

final refreshServiceProvider = Provider<RefreshService>(
  (ref) => RefreshService(
    quotes: ref.watch(quoteProviderProvider),
    watchlist: ref.watch(watchlistRepositoryProvider),
    widgetStorage: ref.watch(widgetStorageProvider),
  ),
);

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
