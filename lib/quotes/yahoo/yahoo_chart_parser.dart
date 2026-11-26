import 'dart:convert';
import 'package:http/http.dart' as http;

import '../quote.dart';

class YahooParseException implements Exception {
  YahooParseException(this.message);
  final String message;
  @override
  String toString() => 'YahooParseException: $message';
}

/// Parst eine Antwort von `v8/finance/chart/<symbol>?range=1d&interval=1d`.
Quote parseYahooChart(String body) {
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final results = (json['chart'] as Map<String, dynamic>)['result'] as List?;
    if (results == null || results.isEmpty) {
      throw YahooParseException('Kein Ergebnis');
    }
    final meta = (results.first as Map<String, dynamic>)['meta'] as Map<String, dynamic>;
    return Quote(
      symbol: meta['symbol'] as String,
      price: (meta['regularMarketPrice'] as num).toDouble(),
      previousClose: ((meta['chartPreviousClose'] ?? meta['previousClose']) as num).toDouble(),
      currency: meta['currency'] as String,
      name: (meta['shortName'] ?? meta['longName']) as String?,
    );
  } on YahooParseException {
    rethrow;
  } catch (e) {
    throw YahooParseException(e.toString());
  }
}

const yahooHost = 'query1.finance.yahoo.com';
const yahooHeaders = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64)'};

Uri yahooChartUri(String symbol) =>
    Uri.https(yahooHost, '/v8/finance/chart/$symbol', {'range': '1d', 'interval': '1d'});

/// Minimaler Abruf eines Symbols (Durchstich, wird in Task 02 vom Provider abgelöst).
Future<Quote> fetchYahooChartQuote(http.Client client, String symbol) async {
  final res = await client.get(yahooChartUri(symbol), headers: yahooHeaders);
  return parseYahooChart(res.body);
}
