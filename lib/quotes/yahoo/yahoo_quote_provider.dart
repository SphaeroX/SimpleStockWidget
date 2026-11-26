import 'dart:async';

import 'package:http/http.dart' as http;

import '../quote.dart';
import '../quote_provider.dart';
import 'yahoo_chart_parser.dart';

/// [QuoteProvider] auf Basis der inoffiziellen Yahoo-Finance-Chart-API.
class YahooQuoteProvider implements QuoteProvider {
  YahooQuoteProvider(
    this._client, {
    this.timeout = const Duration(seconds: 10),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

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
          quotes[s] = await fetchYahooChartQuote(
            _client,
            s,
            now: now,
          ).timeout(timeout);
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
  Future<List<SymbolSearchResult>> search(String query) async => const [];
}
