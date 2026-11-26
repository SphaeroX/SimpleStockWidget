import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/app/chart_page.dart';
import 'package:simple_stock_widget/app/deep_link.dart';
import 'package:simple_stock_widget/app/providers.dart';
import 'package:simple_stock_widget/main.dart';
import 'package:simple_stock_widget/quotes/providers.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';

import '../helpers/fakes.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {Uri? initial, Stream<Uri?>? links}) async {
    final store = InMemoryStore();
    await WatchlistRepository(store).save([
      const WatchlistEntry(symbol: 'IWDA.L', name: 'iShares', type: QuoteType.etf).withDisplayName('msci world'),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          widgetStorageProvider.overrideWithValue(InMemoryWidgetStorage()),
          quoteProviderProvider.overrideWithValue(FakeQuoteProvider(const {})),
          priceHistoryProviderProvider.overrideWithValue(EmptyHistoryProvider()),
        ],
        child: SimpleStockApp(initialLink: () async => initial, links: links ?? const Stream.empty()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('Start über Widget-Link öffnet den Chart mit Eintrag aus der Watchlist', (tester) async {
    await pumpApp(tester, initial: chartUriFor('IWDA.L'));
    final page = tester.widget<ChartPage>(find.byType(ChartPage));
    expect(page.entry.displayName, 'msci world');
  });

  testWidgets('Link während die App läuft; unbekanntes Symbol geht trotzdem', (tester) async {
    final links = StreamController<Uri?>();
    await pumpApp(tester, links: links.stream);
    expect(find.byType(ChartPage), findsNothing);
    links.add(chartUriFor('BTC-EUR'));
    await tester.pumpAndSettle();
    expect(tester.widget<ChartPage>(find.byType(ChartPage)).entry.symbol, 'BTC-EUR');
    await links.close();
  });

  testWidgets('andere Links öffnen keinen Chart', (tester) async {
    await pumpApp(tester, initial: Uri.parse('simplestock://reload'));
    expect(find.byType(ChartPage), findsNothing);
  });
}
