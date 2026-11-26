import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/quotes/quote_provider.dart';
import 'package:simple_stock_widget/quotes/yahoo/yahoo_chart_parser.dart';
import 'package:simple_stock_widget/quotes/yahoo/yahoo_quote_provider.dart';

String fixture(String name) => File('tests/fixtures/$name').readAsStringSync();

const fixtures = {
  'NVDA': 'yahoo_chart_nvda.json',
  'EVK.DE': 'yahoo_chart_evk_de.json',
  'IWDA.L': 'yahoo_chart_iwda_l.json',
  '^GDAXI': 'yahoo_chart_gdaxi.json',
  'BTC-EUR': 'yahoo_chart_btc_eur.json',
};

// NVDA-Fixture: pre 1795597200–1795617000, regular 1795617000–1795640400, post bis 1795654800.
DateTime at(int epochSec) =>
    DateTime.fromMillisecondsSinceEpoch(epochSec * 1000, isUtc: true);

MockClient fixtureClient() => MockClient((req) async {
  final symbol = Uri.decodeComponent(req.url.pathSegments.last);
  final f = fixtures[symbol];
  if (f == null)
    return http.Response(fixture('yahoo_chart_xxxxinvalid.json'), 404);
  return http.Response(fixture(f), 200);
});

void main() {
  group('Mapping aller Symboltypen', () {
    test('Typ, Währung, Kurs und Vortagesschluss', () async {
      final provider = YahooQuoteProvider(
        fixtureClient(),
        clock: () => at(1795620000),
      );
      final batch = await provider.fetchQuotes(fixtures.keys.toList());
      expect(batch.errors, isEmpty);
      expect(batch.quotes['NVDA']!.type, QuoteType.equity);
      expect(batch.quotes['EVK.DE']!.currency, 'EUR');
      expect(batch.quotes['EVK.DE']!.previousClose, 18.45);
      expect(batch.quotes['IWDA.L']!.type, QuoteType.etf);
      expect(batch.quotes['IWDA.L']!.currency, 'USD');
      expect(batch.quotes['^GDAXI']!.type, QuoteType.marketIndex);
      expect(batch.quotes['^GDAXI']!.price, 24702.13);
      expect(batch.quotes['BTC-EUR']!.type, QuoteType.crypto);
      expect(batch.quotes['NVDA']!.name, 'NVIDIA Corporation');
    });
  });

  group('Marktstatus', () {
    MarketState stateAt(int sec, [String f = 'yahoo_chart_nvda.json']) =>
        parseYahooChart(fixture(f), now: at(sec)).marketState;

    test('regulär offen', () => expect(stateAt(1795620000), MarketState.open));
    test('vorbörslich', () => expect(stateAt(1795600000), MarketState.pre));
    test('nachbörslich', () => expect(stateAt(1795645000), MarketState.post));
    test('geschlossen', () => expect(stateAt(1795660000), MarketState.closed));
    test(
      'Krypto ist immer offen',
      () => expect(
        stateAt(1795660000, 'yahoo_chart_btc_eur.json'),
        MarketState.open,
      ),
    );
    test('ohne Handelszeiten unbekannt', () {
      const body =
          '{"chart":{"result":[{"meta":{"symbol":"X","currency":"EUR","instrumentType":"EQUITY",'
          '"regularMarketPrice":1,"chartPreviousClose":1}}],"error":null}}';
      expect(
        parseYahooChart(body, now: at(0)).marketState,
        MarketState.unknown,
      );
    });
  });

  group('Fehler', () {
    test('ungültiges Symbol verhindert die anderen Ergebnisse nicht', () async {
      final provider = YahooQuoteProvider(
        fixtureClient(),
        clock: () => at(1795620000),
      );
      final batch = await provider.fetchQuotes(['NVDA', 'XXXXINVALID']);
      expect(batch.quotes.keys, ['NVDA']);
      expect(batch.errors['XXXXINVALID'], isA<UnknownSymbolException>());
    });

    test('HTTP 429 → RateLimitException', () async {
      final p = YahooQuoteProvider(
        MockClient((_) async => http.Response('Too Many Requests', 429)),
      );
      expect(
        (await p.fetchQuotes(['NVDA'])).errors['NVDA'],
        isA<RateLimitException>(),
      );
    });

    test('HTTP 500 → NetworkQuoteException', () async {
      final p = YahooQuoteProvider(
        MockClient((_) async => http.Response('oops', 500)),
      );
      expect(
        (await p.fetchQuotes(['NVDA'])).errors['NVDA'],
        isA<NetworkQuoteException>(),
      );
    });

    test('ClientException → NetworkQuoteException', () async {
      final p = YahooQuoteProvider(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(
        (await p.fetchQuotes(['NVDA'])).errors['NVDA'],
        isA<NetworkQuoteException>(),
      );
    });

    test('Timeout → NetworkQuoteException', () async {
      final p = YahooQuoteProvider(
        MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 10),
      );
      expect(
        (await p.fetchQuotes(['NVDA'])).errors['NVDA'],
        isA<NetworkQuoteException>(),
      );
    });

    test('kaputtes JSON → ParseQuoteException', () async {
      final p = YahooQuoteProvider(
        MockClient((_) async => http.Response('{kaputt', 200)),
      );
      expect(
        (await p.fetchQuotes(['NVDA'])).errors['NVDA'],
        isA<ParseQuoteException>(),
      );
    });
  });

  test('Austauschbarkeit: Fake-Provider erfüllt die Schnittstelle', () async {
    final QuoteProvider p = FakeQuoteProvider({
      'A': const Quote(
        symbol: 'A',
        price: 2,
        previousClose: 1,
        currency: 'EUR',
      ),
    });
    expect((await p.fetchQuotes(['A'])).quotes['A']!.change, 1);
  });
}

class FakeQuoteProvider implements QuoteProvider {
  FakeQuoteProvider(this.data);
  final Map<String, Quote> data;
  @override
  Future<QuoteBatch> fetchQuotes(List<String> symbols) async => QuoteBatch(
    quotes: {
      for (final s in symbols)
        if (data[s] != null) s: data[s]!,
    },
    errors: const {},
  );
  @override
  Future<List<SymbolSearchResult>> search(String query) async => const [];
}
