@Tags(['live'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:simple_stock_widget/quotes/yahoo/yahoo_quote_provider.dart';

void main() {
  test('echter Abruf: Aktie, Index, Krypto und FX-Paar', () async {
    final p = YahooQuoteProvider(http.Client());
    final batch = await p.fetchQuotes(['NVDA', '^GDAXI', 'BTC-EUR', 'USDEUR=X', 'VOD.L']);
    expect(batch.errors, isEmpty);
    expect(batch.quotes['USDEUR=X']!.price, inInclusiveRange(0.5, 1.5));
    expect(batch.quotes['VOD.L']!.currency, 'GBp');
  });

  test('echte Suche', () async {
    final results = await YahooQuoteProvider(http.Client()).search('nvidia');
    expect(results.map((r) => r.symbol), contains('NVDA'));
  });
}
