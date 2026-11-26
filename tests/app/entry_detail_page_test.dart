import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_stock_widget/app/entry_detail_page.dart';
import 'package:simple_stock_widget/app/providers.dart';
import 'package:simple_stock_widget/quotes/providers.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('Anzeigename setzen und speichern', (tester) async {
    final store = InMemoryStore();
    const entry = WatchlistEntry(symbol: 'IWDA.L', name: 'iShares', type: QuoteType.etf);
    await WatchlistRepository(store).save(const [entry]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          widgetStorageProvider.overrideWithValue(InMemoryWidgetStorage()),
          quoteProviderProvider.overrideWithValue(FakeQuoteProvider(const {})),
        ],
        child: const MaterialApp(home: EntryDetailPage(entry: entry)),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'msci world');
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect((await WatchlistRepository(store).load()).single.displayName, 'msci world');
  });
}
