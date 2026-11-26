import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_stock_widget/app/providers.dart';
import 'package:simple_stock_widget/app/watchlist_page.dart';
import 'package:simple_stock_widget/quotes/providers.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';

import '../helpers/fakes.dart';

void main() {
  late InMemoryStore store;
  late InMemoryWidgetStorage widget;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          widgetStorageProvider.overrideWithValue(widget),
          quoteProviderProvider.overrideWithValue(FakeQuoteProvider(const {})),
        ],
        child: const MaterialApp(home: WatchlistPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() async {
    store = InMemoryStore();
    widget = InMemoryWidgetStorage();
    await WatchlistRepository(store).save(const [
      WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA', type: QuoteType.equity),
      WatchlistEntry(symbol: 'TSLA', name: 'Tesla', type: QuoteType.equity),
      WatchlistEntry(symbol: 'BTC-EUR', name: 'Bitcoin', type: QuoteType.crypto),
    ]);
  });

  testWidgets('Eintrag per Wischen entfernen', (tester) async {
    await pump(tester);
    expect(find.text('Tesla'), findsOneWidget);
    await tester.drag(find.text('Tesla'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Tesla'), findsNothing);
    expect((await WatchlistRepository(store).load()).map((e) => e.symbol), ['NVDA', 'BTC-EUR']);
    expect(widget.updates, greaterThan(0));
  });

  testWidgets('Einträge umsortieren', (tester) async {
    await pump(tester);
    tester.widget<ReorderableListView>(find.byType(ReorderableListView)).onReorderItem!(0, 2);
    await tester.pumpAndSettle();
    expect((await WatchlistRepository(store).load()).map((e) => e.symbol), ['TSLA', 'BTC-EUR', 'NVDA']);
  });
}
