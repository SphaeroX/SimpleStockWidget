import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_stock_widget/app/chart_page.dart';
import 'package:simple_stock_widget/app/providers.dart';
import 'package:simple_stock_widget/chart/chart_range.dart';
import 'package:simple_stock_widget/chart/chart_settings.dart';
import 'package:simple_stock_widget/chart/price_history.dart';
import 'package:simple_stock_widget/quotes/providers.dart';
import 'package:simple_stock_widget/settings/settings_repository.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';

import '../helpers/fakes.dart';

class FakeHistoryProvider implements PriceHistoryProvider {
  final calls = <(DateTime?, HistoryInterval)>[];
  @override
  Future<PriceHistory> fetchHistory(
    String symbol, {
    required DateTime? from,
    required DateTime to,
    required HistoryInterval interval,
  }) async {
    calls.add((from, interval));
    final start = to.subtract(const Duration(days: 400));
    return PriceHistory(
      symbol: symbol,
      currency: 'USD',
      points: [for (var i = 0; i <= 400; i++) PricePoint(start.add(Duration(days: i)), 100.0 + i * 0.1)],
    );
  }
}

void main() {
  late InMemoryStore store;
  late FakeHistoryProvider history;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          widgetStorageProvider.overrideWithValue(InMemoryWidgetStorage()),
          quoteProviderProvider.overrideWithValue(FakeQuoteProvider(const {})),
          priceHistoryProviderProvider.overrideWithValue(history),
        ],
        child: const MaterialApp(
          home: ChartPage(
            entry: WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA Corporation'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    store = InMemoryStore();
    history = FakeHistoryProvider();
  });

  testWidgets('lädt den gespeicherten Zeitraum und zeigt Kurs und Veränderung', (tester) async {
    await pump(tester);
    expect(find.text('NVIDIA Corporation'), findsOneWidget);
    expect(history.calls.single.$2, HistoryInterval.day); // Standard 90 Tage
    expect(find.textContaining('%'), findsWidgets);
    expect(find.byKey(const Key('price-chart')), findsOneWidget);
    expect(find.byKey(const Key('rsi-chart')), findsNothing);
  });

  testWidgets('Zeitraum wechseln lädt neu und wird gespeichert', (tester) async {
    await pump(tester);
    await tester.tap(find.text('7 T'));
    await tester.pumpAndSettle();
    expect(history.calls.last.$2, HistoryInterval.hour);
    expect((await SettingsRepository(store).load()).chart.range, ChartRange.d7);
  });

  testWidgets('Werkzeug RSI einblenden', (tester) async {
    await pump(tester);
    await tester.ensureVisible(find.text('RSI 14'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RSI 14'));
    await tester.pumpAndSettle();
    expect((await SettingsRepository(store).load()).chart.tools, contains(ChartTool.rsi));
    expect(find.byKey(const Key('rsi-chart')), findsOneWidget);
  });
}
