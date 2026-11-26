import 'dart:convert';

import '../quotes/quote.dart';
import '../storage/key_value_store.dart';
import 'watchlist_entry.dart';

class DuplicateEntryException implements Exception {
  const DuplicateEntryException(this.symbol);
  final String symbol;
  @override
  String toString() => '$symbol ist bereits in der Watchlist';
}

const defaultWatchlist = [
  WatchlistEntry(symbol: '^GDAXI', name: 'DAX', type: QuoteType.marketIndex),
  WatchlistEntry(symbol: '^GSPC', name: 'S&P 500', type: QuoteType.marketIndex),
  WatchlistEntry(symbol: 'EUNL.DE', name: 'iShares Core MSCI World', type: QuoteType.etf),
];

class WatchlistRepository {
  WatchlistRepository(this._store);
  final KeyValueStore _store;

  static const storageKey = 'watchlist';

  Future<List<WatchlistEntry>> load() async {
    final raw = await _store.getString(storageKey);
    if (raw == null) return List.of(defaultWatchlist);
    try {
      return [for (final e in jsonDecode(raw) as List) WatchlistEntry.fromJson(e as Map<String, dynamic>)];
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<WatchlistEntry> entries) =>
      _store.setString(storageKey, jsonEncode([for (final e in entries) e.toJson()]));

  Future<List<WatchlistEntry>> add(WatchlistEntry entry) async {
    final list = await load();
    if (list.any((e) => e.symbol == entry.symbol)) {
      throw DuplicateEntryException(entry.symbol);
    }
    list.add(entry);
    await save(list);
    return list;
  }

  Future<List<WatchlistEntry>> remove(String symbol) async {
    final list = await load()
      ..removeWhere((e) => e.symbol == symbol);
    await save(list);
    return list;
  }

  /// Verschiebt wie `ReorderableListView.onReorder`: [newIndex] zählt vor dem Entfernen.
  Future<List<WatchlistEntry>> reorder(int oldIndex, int newIndex) async {
    final list = await load();
    if (newIndex > oldIndex) newIndex -= 1;
    list.insert(newIndex, list.removeAt(oldIndex));
    await save(list);
    return list;
  }

  Future<List<WatchlistEntry>> replace(WatchlistEntry entry) async {
    final list = [for (final e in await load()) e.symbol == entry.symbol ? entry : e];
    await save(list);
    return list;
  }
}
