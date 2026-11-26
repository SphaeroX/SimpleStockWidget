import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';
import 'package:simple_stock_widget/widget_sync/refresh_service.dart';
import 'package:simple_stock_widget/widget_sync/widget_keys.dart';

import '../helpers/fakes.dart';

void main() {
  test('Widget zeigt eigenen Anzeigenamen', () async {
    final store = InMemoryStore();
    final repo = WatchlistRepository(store);
    await repo.save([
      const WatchlistEntry(symbol: 'IWDA.L', name: 'iShares', type: QuoteType.etf).withDisplayName('msci world'),
    ]);
    final widget = InMemoryWidgetStorage();
    await RefreshService(
      quotes: FakeQuoteProvider({
        'IWDA.L': const Quote(symbol: 'IWDA.L', price: 133.99, previousClose: 136.61, currency: 'USD'),
      }),
      watchlist: repo,
      widgetStorage: widget,
    ).refresh();
    final json = jsonDecode(widget.data[WidgetKeys.payload]!) as Map<String, dynamic>;
    expect((json['rows'] as List).single['name'], 'msci world');
  });

  test('Payload enthält Einträge in Watchlist-Reihenfolge', () async {
    final store = InMemoryStore();
    final repo = WatchlistRepository(store);
    await repo.save(const [
      WatchlistEntry(symbol: 'TSLA', name: 'Tesla', type: QuoteType.equity),
      WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA', type: QuoteType.equity),
    ]);
    final widget = InMemoryWidgetStorage();
    final service = RefreshService(
      quotes: FakeQuoteProvider({
        'NVDA': const Quote(symbol: 'NVDA', price: 149.3, previousClose: 155.38, currency: 'USD'),
        'TSLA': const Quote(symbol: 'TSLA', price: 380.14, previousClose: 384.68, currency: 'USD'),
      }),
      watchlist: repo,
      widgetStorage: widget,
      clock: () => DateTime(2026, 11, 25, 22, 48),
    );

    await service.refresh();

    final json = jsonDecode(widget.data[WidgetKeys.payload]!) as Map<String, dynamic>;
    final rows = (json['rows'] as List).cast<Map<String, dynamic>>();
    expect(rows.map((r) => r['name']), ['TSLA', 'NVDA']);
    expect(rows.last['price'], '149,30');
    expect(rows.last['dir'], 'down');
    expect(widget.updates, 1);
  });
}
