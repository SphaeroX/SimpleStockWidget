import 'quote.dart';

/// Austauschbare Kursquelle. Implementierungen kapseln alle quellenspezifischen Details.
abstract interface class QuoteProvider {
  /// Lädt Kurse für [symbols]. Einzelne Fehler landen in [QuoteBatch.errors],
  /// die übrigen Kurse werden trotzdem geliefert.
  Future<QuoteBatch> fetchQuotes(List<String> symbols);

  /// Sucht Werte per Name oder Ticker.
  Future<List<SymbolSearchResult>> search(String query);
}

class QuoteBatch {
  const QuoteBatch({required this.quotes, required this.errors});
  final Map<String, Quote> quotes;
  final Map<String, QuoteException> errors;
}

class SymbolSearchResult {
  const SymbolSearchResult({required this.symbol, required this.name, required this.type, this.exchange});
  final String symbol;
  final String name;
  final QuoteType type;
  final String? exchange;
}

sealed class QuoteException implements Exception {
  const QuoteException(this.message);
  final String message;
  @override
  String toString() => '$runtimeType: $message';
}

class NetworkQuoteException extends QuoteException {
  const NetworkQuoteException(super.message);
}

class UnknownSymbolException extends QuoteException {
  const UnknownSymbolException(super.message);
}

class RateLimitException extends QuoteException {
  const RateLimitException(super.message);
}

class ParseQuoteException extends QuoteException {
  const ParseQuoteException(super.message);
}
