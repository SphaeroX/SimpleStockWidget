/// Ein Kurs-Schnappschuss in der Originalwährung der Quelle.
class Quote {
  const Quote({
    required this.symbol,
    required this.price,
    required this.previousClose,
    required this.currency,
    this.name,
  });

  final String symbol;
  final double price;
  final double previousClose;
  final String currency;
  final String? name;

  double get change => price - previousClose;
  double get changePercent => previousClose == 0 ? 0 : change / previousClose * 100;
}
