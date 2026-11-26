import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/app/deep_link.dart';

void main() {
  test('Chart-Link mit Symbol (auch Sonderzeichen)', () {
    expect(chartUriFor('^GDAXI').toString(), 'simplestock://chart?symbol=%5EGDAXI');
    expect(chartSymbolFromUri(chartUriFor('^GDAXI')), '^GDAXI');
    expect(chartSymbolFromUri(Uri.parse('simplestock://chart?symbol=BTC-EUR')), 'BTC-EUR');
  });

  test('andere oder leere Links ergeben kein Symbol', () {
    expect(chartSymbolFromUri(null), isNull);
    expect(chartSymbolFromUri(Uri.parse('simplestock://reload')), isNull);
    expect(chartSymbolFromUri(Uri.parse('simplestock://chart')), isNull);
  });
}
