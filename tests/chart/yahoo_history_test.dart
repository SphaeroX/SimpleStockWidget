import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simple_stock_widget/chart/price_history.dart';
import 'package:simple_stock_widget/quotes/quote_provider.dart';
import 'package:simple_stock_widget/quotes/yahoo/yahoo_chart_parser.dart';
import 'package:simple_stock_widget/quotes/yahoo/yahoo_quote_provider.dart';

String fixture(String n) => File('tests/fixtures/$n').readAsStringSync();

void main() {
  test('parst Zeitstempel und Schlusskurse der Tageshistorie', () {
    final h = parseYahooHistory(fixture('yahoo_history_nvda_1d.json'));
    expect(h.symbol, 'NVDA');
    expect(h.currency, 'USD');
    expect(h.points.length, 276);
    expect(h.points.first.close, closeTo(180.28, 0.01));
    expect(h.points.first.time.isBefore(h.points.last.time), isTrue);
  });

  test('Lücken (null) werden übersprungen, Pence normalisiert', () {
    const body =
        '{"chart":{"result":[{"meta":{"symbol":"VOD.L","currency":"GBp"},'
        '"timestamp":[100,200,300],"indicators":{"quote":[{"close":[101.0,null,103.0]}]}}],"error":null}}';
    final h = parseYahooHistory(body);
    expect(h.points.map((p) => p.close), [1.01, 1.03]);
    expect(h.currency, 'GBP');
  });

  test('Provider ruft period1/period2/interval ab', () async {
    late Uri called;
    final p = YahooQuoteProvider(
      MockClient((req) async {
        called = req.url;
        return http.Response(fixture('yahoo_history_nvda_1h.json'), 200);
      }),
    );
    final from = DateTime.utc(2026, 11, 1);
    final to = DateTime.utc(2026, 11, 26);
    final h = await p.fetchHistory('NVDA', from: from, to: to, interval: HistoryInterval.hour);
    expect(called.path, '/v8/finance/chart/NVDA');
    expect(called.queryParameters['interval'], '1h');
    expect(called.queryParameters['period1'], '${from.millisecondsSinceEpoch ~/ 1000}');
    expect(called.queryParameters['period2'], '${to.millisecondsSinceEpoch ~/ 1000}');
    expect(h.points, isNotEmpty);
  });

  test('ohne from: range=max', () async {
    late Uri called;
    final p = YahooQuoteProvider(
      MockClient((req) async {
        called = req.url;
        return http.Response(fixture('yahoo_history_nvda_1d.json'), 200);
      }),
    );
    await p.fetchHistory('NVDA', from: null, to: DateTime.utc(2026), interval: HistoryInterval.week);
    expect(called.queryParameters['range'], 'max');
    expect(called.queryParameters['interval'], '1wk');
  });

  test('HTTP 404 → UnknownSymbolException', () async {
    final p = YahooQuoteProvider(MockClient((_) async => http.Response('{}', 404)));
    expect(
      () => p.fetchHistory('X', from: null, to: DateTime.utc(2026), interval: HistoryInterval.day),
      throwsA(isA<UnknownSymbolException>()),
    );
  });
}
