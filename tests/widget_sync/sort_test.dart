import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/quotes/quote_provider.dart';
import 'package:simple_stock_widget/settings/app_settings.dart';
import 'package:simple_stock_widget/settings/settings_repository.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';
import 'package:simple_stock_widget/widget_sync/payload_builder.dart';
import 'package:simple_stock_widget/widget_sync/refresh_service.dart';
import 'package:simple_stock_widget/widget_sync/widget_keys.dart';

import '../helpers/fakes.dart';

Quote q(String s, double price, double prev) => Quote(symbol: s, price: price, previousClose: prev, currency: 'EUR');

void main() {
  // Manuelle Reihenfolge: NVDA (-3,9 %), dax (-1,3 %), Apple (+2 %), XXX (kein Kurs), BTC (+0,6 %)
  final items = <(WatchlistEntry, Quote?)>[
    (const WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA'), q('NVDA', 149.3, 155.38)),
    (const WatchlistEntry(symbol: '^GDAXI', name: 'DAX', displayName: 'dax'), q('^GDAXI', 24702, 25017)),
    (const WatchlistEntry(symbol: 'AAPL', name: 'Apple', displayName: 'Apple'), q('AAPL', 102, 100)),
    (const WatchlistEntry(symbol: 'XXX', name: 'Ungültig'), null),
    (const WatchlistEntry(symbol: 'BTC-EUR', name: 'Bitcoin'), q('BTC-EUR', 55640, 55306)),
  ];
  List<String> names(SortOrder o) => [for (final (e, _) in sortEntries(items, o)) e.effectiveName];

  test('Manuell: Watchlist-Reihenfolge bleibt', () {
    expect(names(SortOrder.manual), ['NVDA', 'dax', 'Apple', 'XXX', 'BTC-EUR']);
  });

  test('Name A–Z ohne Beachtung der Groß-/Kleinschreibung', () {
    expect(names(SortOrder.nameAsc), ['Apple', 'BTC-EUR', 'dax', 'NVDA', 'XXX']);
  });

  test('Gewinner zuerst (Prozent absteigend), ohne Kurs ans Ende', () {
    expect(names(SortOrder.gainersFirst), ['Apple', 'BTC-EUR', 'dax', 'NVDA', 'XXX']);
  });

  test('Verlierer zuerst (Prozent aufsteigend), ohne Kurs ans Ende', () {
    expect(names(SortOrder.losersFirst), ['NVDA', 'dax', 'BTC-EUR', 'Apple', 'XXX']);
  });

  test('Gleichstand behält die manuelle Reihenfolge', () {
    final tie = <(WatchlistEntry, Quote?)>[
      (const WatchlistEntry(symbol: 'B', name: 'B'), q('B', 101, 100)),
      (const WatchlistEntry(symbol: 'A', name: 'A'), q('A', 202, 200)),
    ];
    expect([for (final (e, _) in sortEntries(tie, SortOrder.gainersFirst)) e.symbol], ['B', 'A']);
  });

  test('Einstellung: Standard manuell, Persistenz, alte Daten', () async {
    final store = InMemoryStore();
    expect((await SettingsRepository(store).load()).sortOrder, SortOrder.manual);
    await SettingsRepository(store).save(const AppSettings(sortOrder: SortOrder.losersFirst));
    expect((await SettingsRepository(store).load()).sortOrder, SortOrder.losersFirst);
    store.data[SettingsRepository.storageKey] = '{"displayCurrency":"EUR"}';
    expect((await SettingsRepository(store).load()).sortOrder, SortOrder.manual);
  });

  test('Widget-Payload ist nach der Einstellung sortiert', () async {
    final store = InMemoryStore();
    await SettingsRepository(store).save(const AppSettings(sortOrder: SortOrder.gainersFirst));
    await WatchlistRepository(store).save([for (final (e, _) in items) e]);
    final widget = InMemoryWidgetStorage();
    await RefreshService(
      quotes: FakeQuoteProvider(
        {for (final (e, quote) in items) e.symbol: ?quote},
        errors: const {'XXX': UnknownSymbolException('XXX')},
      ),
      watchlist: WatchlistRepository(store),
      widgetStorage: widget,
      settings: SettingsRepository(store),
    ).refresh();
    final rows = (jsonDecode(widget.data[WidgetKeys.payload]!) as Map)['rows'] as List;
    expect(rows.map((r) => r['name']), ['Apple', 'BTC-EUR', 'dax', 'NVDA', 'XXX']);
  });
}
