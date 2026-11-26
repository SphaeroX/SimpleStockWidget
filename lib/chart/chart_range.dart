import 'price_history.dart';

enum ChartRange { d7, d30, d90, y1, max }

String chartRangeLabel(ChartRange r) => switch (r) {
  ChartRange.d7 => '7 T',
  ChartRange.d30 => '30 T',
  ChartRange.d90 => '90 T',
  ChartRange.y1 => '1 J',
  ChartRange.max => 'Max',
};

/// Was geladen und was angezeigt wird. Geladen wird mit Vorlauf, damit Durchschnitte (bis MA200)
/// schon am linken Rand gültig sind.
class HistoryRequest {
  const HistoryRequest({required this.fetchFrom, required this.visibleFrom, required this.to, required this.interval});

  final DateTime? fetchFrom;
  final DateTime? visibleFrom;
  final DateTime to;
  final HistoryInterval interval;

  static Duration lookback(HistoryInterval i) => switch (i) {
    HistoryInterval.hour => const Duration(days: 45),
    HistoryInterval.day => const Duration(days: 300),
    HistoryInterval.week => const Duration(days: 1500),
  };

  factory HistoryRequest.forRange(ChartRange range, {required DateTime now}) {
    if (range == ChartRange.max) {
      return HistoryRequest(fetchFrom: null, visibleFrom: null, to: now, interval: HistoryInterval.week);
    }
    final days = switch (range) {
      ChartRange.d7 => 7,
      ChartRange.d30 => 30,
      ChartRange.d90 => 90,
      _ => 365,
    };
    final interval = range == ChartRange.d7 ? HistoryInterval.hour : HistoryInterval.day;
    final from = now.subtract(Duration(days: days));
    return HistoryRequest(fetchFrom: from.subtract(lookback(interval)), visibleFrom: from, to: now, interval: interval);
  }

  factory HistoryRequest.custom(DateTime from, DateTime to) {
    final days = to.difference(from).inDays;
    final interval = days <= 10
        ? HistoryInterval.hour
        : days <= 5 * 365
        ? HistoryInterval.day
        : HistoryInterval.week;
    return HistoryRequest(fetchFrom: from.subtract(lookback(interval)), visibleFrom: from, to: to, interval: interval);
  }
}
