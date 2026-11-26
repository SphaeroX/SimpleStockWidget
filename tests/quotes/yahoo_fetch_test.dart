import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simple_stock_widget/quotes/yahoo/yahoo_chart_parser.dart';

void main() {
  test('fetchYahooChartQuote ruft den Chart-Endpunkt auf und parst die Antwort', () async {
    late Uri called;
    final client = MockClient((req) async {
      called = req.url;
      return http.Response(File('tests/fixtures/yahoo_chart_nvda.json').readAsStringSync(), 200);
    });
    final q = await fetchYahooChartQuote(client, 'NVDA');
    expect(called.host, 'query1.finance.yahoo.com');
    expect(called.path, '/v8/finance/chart/NVDA');
    expect(called.queryParameters['range'], '1d');
    expect(q.price, 149.3);
  });
}
