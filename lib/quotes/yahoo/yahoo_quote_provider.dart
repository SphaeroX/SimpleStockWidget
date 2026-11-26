import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../chart/price_history.dart';
import '../quote.dart';
import '../quote_provider.dart';
import 'yahoo_chart_parser.dart';

/// [QuoteProvider] auf Basis der inoffiziellen Yahoo-Finance-Chart-API.
class YahooQuoteProvider implements QuoteProvider, PriceHistoryProvider {
  YahooQuoteProvider(this._client, {this.timeout = const Duration(seconds: 10), DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final http.Client _client;
  final Duration timeout;
  final DateTime Function() _clock;

  @override
  Future<QuoteBatch> fetchQuotes(List<String> symbols) async {
    final quotes = <String, Quote>{};
    final errors = <String, QuoteException>{};
    final now = _clock();
    await Future.wait(
      symbols.toSet().map((s) async {
        try {
          quotes[s] = await fetchYahooChartQuote(_client, s, now: now).timeout(timeout);
        } on QuoteException catch (e) {
          errors[s] = e;
        } on TimeoutException {
          errors[s] = NetworkQuoteException('Timeout für $s');
        } on http.ClientException catch (e) {
          errors[s] = NetworkQuoteException(e.message);
        } catch (e) {
          errors[s] = NetworkQuoteException(e.toString());
        }
      }),
    );
    return QuoteBatch(
      quotes: {
        for (final s in symbols)
          if (quotes[s] != null) s: quotes[s]!,
      },
      errors: errors,
    );
  }

  @override
  Future<List<SymbolSearchResult>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final uri = Uri.https(yahooHost, '/v1/finance/search', {
      'q': q,
      'quotesCount': '15',
      'newsCount': '0',
      'listsCount': '0',
    });
    final http.Response res;
    try {
      res = await _client.get(uri, headers: yahooHeaders).timeout(timeout);
    } on TimeoutException {
      throw const NetworkQuoteException('Timeout bei der Suche');
    } on http.ClientException catch (e) {
      throw NetworkQuoteException(e.message);
    }
    if (res.statusCode == 429) throw const RateLimitException('Suche');
    if (res.statusCode != 200) {
      throw NetworkQuoteException('HTTP ${res.statusCode} bei der Suche');
    }
    try {
      final quotes = (jsonDecode(res.body) as Map<String, dynamic>)['quotes'] as List? ?? const [];
      return [
        for (final raw in quotes.cast<Map<String, dynamic>>())
          if (raw['symbol'] is String && raw['quoteType'] is String)
            SymbolSearchResult(
              symbol: raw['symbol'] as String,
              name: ((raw['longname'] ?? raw['shortname'] ?? raw['symbol']) as String).trim(),
              type: yahooQuoteType(raw['quoteType'] as String),
              exchange: raw['exchDisp'] as String?,
            ),
      ];
    } catch (e) {
      throw ParseQuoteException(e.toString());
    }
  }

  @override
  Future<PriceHistory> fetchHistory(
    String symbol, {
    required DateTime? from,
    required DateTime to,
    required HistoryInterval interval,
  }) async {
    int sec(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;
    final uri = Uri.https(yahooHost, '/v8/finance/chart/$symbol', {
      if (from == null) 'range': 'max' else ...{'period1': '${sec(from)}', 'period2': '${sec(to)}'},
      'interval': interval.yahooCode,
    });
    final http.Response res;
    try {
      res = await _client.get(uri, headers: yahooHeaders).timeout(timeout * 2);
    } on TimeoutException {
      throw NetworkQuoteException('Timeout beim Verlauf von $symbol');
    } on http.ClientException catch (e) {
      throw NetworkQuoteException(e.message);
    }
    switch (res.statusCode) {
      case 200:
        return parseYahooHistory(res.body);
      case 404:
        throw UnknownSymbolException(symbol);
      case 429:
        throw RateLimitException(symbol);
      default:
        throw NetworkQuoteException('HTTP ${res.statusCode} beim Verlauf von $symbol');
    }
  }
}
