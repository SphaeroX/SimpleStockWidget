enum QuoteType { equity, etf, marketIndex, crypto, currency, fund, other }

enum MarketState { open, pre, post, closed, unknown }

/// Ein Kurs-Schnappschuss in der Originalwährung der Quelle.
class Quote {
  const Quote({
    required this.symbol,
    required this.price,
    required this.previousClose,
    required this.currency,
    this.name,
    this.type = QuoteType.other,
    this.marketState = MarketState.unknown,
    this.marketTime,
  });

  final String symbol;
  final double price;
  final double previousClose;
  final String currency;
  final String? name;
  final QuoteType type;
  final MarketState marketState;
  final DateTime? marketTime;

  double get change => price - previousClose;
  double get changePercent => previousClose == 0 ? 0 : change / previousClose * 100;
}
