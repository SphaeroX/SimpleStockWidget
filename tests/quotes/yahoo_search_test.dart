import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/quotes/yahoo/yahoo_quote_provider.dart';

void main() {
  test('Suche parst Symbol, Name, Typ und Börse', () async {
    late Uri called;
    final p = YahooQuoteProvider(
      MockClient((req) async {
        called = req.url;
        return http.Response(File('tests/fixtures/yahoo_search_msci.json').readAsStringSync(), 200);
      }),
    );
    final results = await p.search('msci world');
    expect(called.path, '/v1/finance/search');
    expect(called.queryParameters['q'], 'msci world');
    expect(results.first.symbol, 'IWDA.AS');
    expect(results.first.type, QuoteType.etf);
    expect(results.first.exchange, 'Amsterdam');
    expect(results.first.name, isNotEmpty);
    expect(results.any((r) => r.type == QuoteType.marketIndex), isTrue);
  });

  test('leere Suche ruft nichts ab', () async {
    var calls = 0;
    final p = YahooQuoteProvider(
      MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    expect(await p.search('  '), isEmpty);
    expect(calls, 0);
  });
}
