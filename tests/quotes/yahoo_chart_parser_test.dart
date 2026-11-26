import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/quotes/yahoo/yahoo_chart_parser.dart';

String fixture(String name) => File('tests/fixtures/$name').readAsStringSync();

void main() {
  group('parseYahooChart', () {
    test('parst Kurs, Vortagesschluss und Währung von NVDA', () {
      final q = parseYahooChart(fixture('yahoo_chart_nvda.json'));
      expect(q.symbol, 'NVDA');
      expect(q.price, 149.3);
      expect(q.previousClose, 155.38);
      expect(q.currency, 'USD');
      expect(q.change, closeTo(-6.08, 1e-9));
      expect(q.changePercent, closeTo(-3.913, 1e-3));
    });

    test('wirft YahooParseException bei kaputtem JSON', () {
      expect(() => parseYahooChart('{kaputt'), throwsA(isA<YahooParseException>()));
    });

    test('wirft YahooParseException bei leerem Ergebnis', () {
      expect(() => parseYahooChart('{"chart":{"result":[],"error":null}}'), throwsA(isA<YahooParseException>()));
    });
  });
}
