import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/quotes/quote_provider.dart';
import 'package:simple_stock_widget/settings/app_settings.dart';
import 'package:simple_stock_widget/settings/settings_repository.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';
import 'package:simple_stock_widget/widget_sync/refresh_service.dart';
import 'package:simple_stock_widget/widget_sync/widget_keys.dart';
import 'package:simple_stock_widget/widget_sync/widget_status.dart';

import '../helpers/fakes.dart';

void main() {
  final now = DateTime(2026, 11, 25, 22, 48);

  group('Veraltet-Regel (älter als 2× Intervall)', () {
    for (final i in UpdateInterval.values) {
      test('${i.minutes} Min', () {
        expect(staleAt(now, i), now.add(Duration(minutes: 2 * i.minutes)));
        expect(
          isStale(
            updatedAt: now,
            now: now.add(Duration(minutes: 2 * i.minutes)),
            interval: i,
          ),
          isFalse,
        );
        expect(
          isStale(
            updatedAt: now,
            now: now.add(Duration(minutes: 2 * i.minutes, seconds: 1)),
            interval: i,
          ),
          isTrue,
        );
      });
    }
  });

  test('Fehlertexte', () {
    expect(errorLabelFor(const NetworkQuoteException('x')), 'Offline');
    expect(errorLabelFor(const RateLimitException('x')), 'Zu viele Anfragen');
    expect(errorLabelFor(Exception('x')), 'Fehler');
  });

  group('Payload', () {
    late InMemoryStore store;
    late InMemoryWidgetStorage widget;

    setUp(() {
      store = InMemoryStore();
      widget = InMemoryWidgetStorage();
    });

    RefreshService service(FakeQuoteProvider p) => RefreshService(
      quotes: p,
      watchlist: WatchlistRepository(store),
      widgetStorage: widget,
      settings: SettingsRepository(store),
      clock: () => now,
    );

    Map<String, dynamic> payload() => jsonDecode(widget.data[WidgetKeys.payload]!) as Map<String, dynamic>;

    test('Marktstatus: geschlossen/vor-/nachbörslich abgeblendet, offen und Krypto normal', () async {
      await WatchlistRepository(store).save(const [
        WatchlistEntry(symbol: 'A', name: 'A'),
        WatchlistEntry(symbol: 'B', name: 'B'),
        WatchlistEntry(symbol: 'C', name: 'C'),
        WatchlistEntry(symbol: 'BTC-EUR', name: 'BTC', type: QuoteType.crypto),
      ]);
      Quote q(String s, MarketState m) => Quote(symbol: s, price: 1, previousClose: 1, currency: 'EUR', marketState: m);
      await service(
        FakeQuoteProvider({
          'A': q('A', MarketState.closed),
          'B': q('B', MarketState.post),
          'C': q('C', MarketState.open),
          'BTC-EUR': q('BTC-EUR', MarketState.open),
        }),
      ).refresh();
      final rows = (payload()['rows'] as List).cast<Map<String, dynamic>>();
      expect(rows.map((r) => r['dim'] ?? false), [true, true, false, false]);
      expect(payload()['staleAt'], now.add(const Duration(minutes: 60)).millisecondsSinceEpoch);
      expect(payload()['staleLabel'], 'Veraltet · Stand 22:48 Mi.');
      expect(widget.data[WidgetKeys.error], '');
    });

    test('Teilfehler: betroffener Eintrag mit „–“, Rest normal', () async {
      await WatchlistRepository(
        store,
      ).save(const [WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA'), WatchlistEntry(symbol: 'XXX', name: 'Ungültig')]);
      await service(
        FakeQuoteProvider(
          {'NVDA': const Quote(symbol: 'NVDA', price: 149.3, previousClose: 155.38, currency: 'USD')},
          errors: const {'XXX': UnknownSymbolException('XXX')},
        ),
      ).refresh();
      final rows = (payload()['rows'] as List).cast<Map<String, dynamic>>();
      expect(rows.length, 2);
      expect(rows[0]['price'], '149,30');
      expect(rows[1], {'name': 'XXX', 'price': '–', 'change': '–', 'dir': 'neutral', 'error': true});
    });

    test('Totalfehler: alte Werte bleiben, Fehlerhinweis kommt dazu', () async {
      await WatchlistRepository(store).save(const [WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA')]);
      widget.data[WidgetKeys.payload] = jsonEncode({
        'updatedAt': 1,
        'updatedLabel': '21:00 Mi.',
        'rows': [
          {'name': 'NVDA', 'price': '149,30', 'change': '-3,91 %', 'dir': 'down'},
        ],
      });
      final p = FakeQuoteProvider(const {}, errors: const {'NVDA': NetworkQuoteException('offline')});
      await expectLater(service(p).refresh(), throwsA(isA<NetworkQuoteException>()));
      expect(payload()['rows'], hasLength(1));
      expect(payload()['updatedLabel'], '21:00 Mi.');
      expect(widget.data[WidgetKeys.error], 'Offline · Stand 21:00 Mi.');
      expect(widget.updates, greaterThan(0));
    });

    test('Totalfehler ohne alte Daten: leere Liste mit Fehlerhinweis', () async {
      await WatchlistRepository(store).save(const [WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA')]);
      final p = FakeQuoteProvider(const {}, errors: const {'NVDA': NetworkQuoteException('offline')});
      await expectLater(service(p).refresh(), throwsA(isA<QuoteException>()));
      expect(widget.data[WidgetKeys.payload], isNull);
      expect(widget.data[WidgetKeys.error], 'Offline');
    });

    test('leere Watchlist → Leerzustand', () async {
      await WatchlistRepository(store).save(const []);
      await service(FakeQuoteProvider(const {})).refresh();
      expect(payload()['empty'], isTrue);
      expect(payload()['rows'], isEmpty);
    });
  });
}
