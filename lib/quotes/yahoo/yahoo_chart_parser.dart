import 'dart:convert';

import 'package:http/http.dart' as http;

import '../quote.dart';
import '../quote_provider.dart';

class YahooParseException extends ParseQuoteException {
  const YahooParseException(super.message);
}

QuoteType yahooQuoteType(String? t) => switch (t) {
  'EQUITY' => QuoteType.equity,
  'ETF' => QuoteType.etf,
  'INDEX' => QuoteType.marketIndex,
  'CRYPTOCURRENCY' => QuoteType.crypto,
  'CURRENCY' => QuoteType.currency,
  'MUTUALFUND' => QuoteType.fund,
  _ => QuoteType.other,
};

MarketState _marketState(Map<String, dynamic> meta, QuoteType type, DateTime now) {
  if (type == QuoteType.crypto) return MarketState.open;
  final periods = meta['currentTradingPeriod'];
  if (periods is! Map<String, dynamic>) return MarketState.unknown;
  final t = now.millisecondsSinceEpoch ~/ 1000;
  bool inPeriod(String key) {
    final p = periods[key];
    if (p is! Map<String, dynamic>) return false;
    return t >= (p['start'] as num) && t < (p['end'] as num);
  }

  if (inPeriod('regular')) return MarketState.open;
  if (inPeriod('pre')) return MarketState.pre;
  if (inPeriod('post')) return MarketState.post;
  return MarketState.closed;
}

/// Parst eine Antwort von `v8/finance/chart/<symbol>?range=1d&interval=1d`.
Quote parseYahooChart(String body, {DateTime? now}) {
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final results = (json['chart'] as Map<String, dynamic>)['result'] as List?;
    if (results == null || results.isEmpty) {
      throw const YahooParseException('Kein Ergebnis');
    }
    final meta = (results.first as Map<String, dynamic>)['meta'] as Map<String, dynamic>;
    final type = yahooQuoteType(meta['instrumentType'] as String?);
    final time = meta['regularMarketTime'] as num?;
    return Quote(
      symbol: meta['symbol'] as String,
      price: (meta['regularMarketPrice'] as num).toDouble(),
      previousClose: ((meta['chartPreviousClose'] ?? meta['previousClose']) as num).toDouble(),
      currency: meta['currency'] as String,
      name: (meta['longName'] ?? meta['shortName'] as String?)?.toString().trim(),
      type: type,
      marketState: _marketState(meta, type, now ?? DateTime.now()),
      marketTime: time == null ? null : DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000, isUtc: true),
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

/// Ruft ein einzelnes Symbol ab und bildet HTTP-Fehler auf [QuoteException]s ab.
Future<Quote> fetchYahooChartQuote(http.Client client, String symbol, {DateTime? now}) async {
  final res = await client.get(yahooChartUri(symbol), headers: yahooHeaders);
  switch (res.statusCode) {
    case 200:
      return parseYahooChart(res.body, now: now);
    case 404:
      throw UnknownSymbolException(symbol);
    case 429:
      throw RateLimitException(symbol);
    default:
      throw NetworkQuoteException('HTTP ${res.statusCode} für $symbol');
  }
}
