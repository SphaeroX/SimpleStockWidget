import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_stock_widget/app/providers.dart';
import 'package:simple_stock_widget/app/settings_page.dart';
import 'package:simple_stock_widget/quotes/providers.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/settings/app_settings.dart';
import 'package:simple_stock_widget/settings/settings_repository.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';
import 'package:simple_stock_widget/widget_sync/widget_keys.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('Moduswechsel speichert die Einstellung und aktualisiert das Widget', (tester) async {
    final store = InMemoryStore();
    final widget = InMemoryWidgetStorage();
    await WatchlistRepository(store).save(const [WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA')]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          widgetStorageProvider.overrideWithValue(widget),
          quoteProviderProvider.overrideWithValue(
            FakeQuoteProvider({
              'NVDA': const Quote(symbol: 'NVDA', price: 149.3, previousClose: 155.38, currency: 'USD'),
            }),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beides'));
    await tester.pumpAndSettle();

    expect((await SettingsRepository(store).load()).changeMode, ChangeMode.both);
    final rows = (jsonDecode(widget.data[WidgetKeys.payload]!) as Map)['rows'] as List;
    expect(rows.single['change'], '-6,08 (-3,91 %)');
  });
}
