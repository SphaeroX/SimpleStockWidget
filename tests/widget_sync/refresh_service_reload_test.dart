import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/quotes/quote_provider.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';
import 'package:simple_stock_widget/widget_sync/refresh_service.dart';
import 'package:simple_stock_widget/widget_sync/widget_keys.dart';

import '../helpers/fakes.dart';

class ThrowingQuoteProvider implements QuoteProvider {
  @override
  Future<QuoteBatch> fetchQuotes(List<String> symbols) async => throw const NetworkQuoteException('offline');
  @override
  Future<List<SymbolSearchResult>> search(String query) async => const [];
}

class SlowQuoteProvider extends FakeQuoteProvider {
  SlowQuoteProvider(super.quotes);
  final gate = Completer<void>();
  @override
  Future<QuoteBatch> fetchQuotes(List<String> symbols) async {
    final r = super.fetchQuotes(symbols);
    await gate.future;
    return r;
  }
}

const nvda = Quote(symbol: 'NVDA', price: 149.3, previousClose: 155.38, currency: 'USD');

void main() {
  late InMemoryStore store;
  late InMemoryWidgetStorage widget;
  var now = DateTime(2026, 11, 25, 22, 48);

  setUp(() async {
    store = InMemoryStore();
    widget = InMemoryWidgetStorage();
    now = DateTime(2026, 11, 25, 22, 48);
    await WatchlistRepository(store).save(const [WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA')]);
  });

  RefreshService service(quotes) =>
      RefreshService(quotes: quotes, watchlist: WatchlistRepository(store), widgetStorage: widget, clock: () => now);

  test('schreibt Payload und Zeitstempel und setzt das Lade-Flag zurück', () async {
    final states = <String?>[];
    widget.onSave = (k, v) => k == WidgetKeys.loading ? states.add(v) : null;
    await service(FakeQuoteProvider({'NVDA': nvda})).refresh(showLoading: true);
    final json = jsonDecode(widget.data[WidgetKeys.payload]!) as Map<String, dynamic>;
    expect(json['updatedAt'], now.millisecondsSinceEpoch);
    expect(states, [now.millisecondsSinceEpoch.toString(), '']);
    expect(widget.updates, 2); // Ladezustand anzeigen + Ergebnis
  });

  test('Fehler im Provider: alter Payload bleibt, Lade-Flag wird zurückgesetzt', () async {
    widget.data[WidgetKeys.payload] = '{"old":true}';
    await expectLater(service(ThrowingQuoteProvider()).refresh(), throwsA(isA<NetworkQuoteException>()));
    expect(widget.data[WidgetKeys.payload], '{"old":true}');
    expect(widget.data[WidgetKeys.loading], '');
  });

  test('alle Kurse fehlgeschlagen: alter Payload bleibt', () async {
    widget.data[WidgetKeys.payload] = '{"old":true}';
    final p = FakeQuoteProvider(const {}, errors: const {'NVDA': NetworkQuoteException('x')});
    await expectLater(service(p).refresh(), throwsA(isA<QuoteException>()));
    expect(widget.data[WidgetKeys.payload], '{"old":true}');
  });

  test('paralleler zweiter Aufruf wird ignoriert', () async {
    final slow = SlowQuoteProvider({'NVDA': nvda});
    final s = service(slow);
    final a = s.refresh();
    final b = s.refresh();
    slow.gate.complete();
    await Future.wait([a, b]);
    expect(slow.fetchCalls.length, 1);
  });

  test('laufender Refresh eines anderen Isolates (< 60 s) wird respektiert, veralteter nicht', () async {
    final p = FakeQuoteProvider({'NVDA': nvda});
    widget.data[WidgetKeys.loading] = now.subtract(const Duration(seconds: 20)).millisecondsSinceEpoch.toString();
    expect(await service(p).refresh(), isNull);
    expect(p.fetchCalls, isEmpty);

    widget.data[WidgetKeys.loading] = now.subtract(const Duration(minutes: 5)).millisecondsSinceEpoch.toString();
    expect(await service(p).refresh(), isNotNull);
    expect(p.fetchCalls.length, 1);
  });
}
