import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/chart/chart_range.dart';
import 'package:simple_stock_widget/chart/price_history.dart';

void main() {
  final now = DateTime.utc(2026, 11, 26, 12);

  test('7 Tage: Stundenkerzen, Vorlauf für Durchschnitte', () {
    final r = HistoryRequest.forRange(ChartRange.d7, now: now);
    expect(r.interval, HistoryInterval.hour);
    expect(r.visibleFrom, now.subtract(const Duration(days: 7)));
    expect(r.fetchFrom!.isBefore(r.visibleFrom!), isTrue);
    expect(r.to, now);
  });

  test('30/90 Tage und 1 Jahr: Tageskerzen mit ~300 Tagen Vorlauf (MA200)', () {
    for (final (range, days) in [(ChartRange.d30, 30), (ChartRange.d90, 90), (ChartRange.y1, 365)]) {
      final r = HistoryRequest.forRange(range, now: now);
      expect(r.interval, HistoryInterval.day);
      expect(r.visibleFrom, now.subtract(Duration(days: days)));
      expect(r.visibleFrom!.difference(r.fetchFrom!).inDays, 300);
    }
  });

  test('Max: Wochenkerzen, gesamte Historie', () {
    final r = HistoryRequest.forRange(ChartRange.max, now: now);
    expect(r.interval, HistoryInterval.week);
    expect(r.fetchFrom, isNull);
    expect(r.visibleFrom, isNull);
  });

  test('Eigener Zeitraum: Intervall nach Länge', () {
    HistoryInterval iv(int days) => HistoryRequest.custom(now.subtract(Duration(days: days)), now).interval;
    expect(iv(5), HistoryInterval.hour);
    expect(iv(200), HistoryInterval.day);
    expect(iv(3000), HistoryInterval.week);
  });

  test('Beschriftungen', () {
    expect(ChartRange.values.map(chartRangeLabel), ['7 T', '30 T', '90 T', '1 J', 'Max']);
  });
}
