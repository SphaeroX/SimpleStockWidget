enum HistoryInterval {
  hour('1h'),
  day('1d'),
  week('1wk');

  const HistoryInterval(this.yahooCode);

  /// Kürzel im Yahoo-Format; andere Quellen bilden selbst ab.
  final String yahooCode;
}

class PricePoint {
  const PricePoint(this.time, this.close);
  final DateTime time;
  final double close;
}

class PriceHistory {
  const PriceHistory({required this.symbol, required this.currency, required this.points});
  final String symbol;
  final String currency;
  final List<PricePoint> points;
}

/// Quelle für Kursverläufe (getrennt von [QuoteProvider], damit bestehende Fakes unberührt bleiben).
abstract interface class PriceHistoryProvider {
  /// [from] `null` = gesamte verfügbare Historie.
  Future<PriceHistory> fetchHistory(
    String symbol, {
    required DateTime? from,
    required DateTime to,
    required HistoryInterval interval,
  });
}
