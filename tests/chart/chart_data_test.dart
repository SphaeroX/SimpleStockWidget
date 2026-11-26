import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/chart/chart_data.dart';
import 'package:simple_stock_widget/chart/chart_range.dart';
import 'package:simple_stock_widget/chart/chart_settings.dart';
import 'package:simple_stock_widget/chart/indicators.dart';
import 'package:simple_stock_widget/chart/price_history.dart';

void main() {
  final start = DateTime.utc(2026, 1, 1);
  // 100 Tage: 1..50 steigend, dann fallend → MA20 kreuzt MA50 nach unten (Death Cross).
  final closes = [for (var i = 0; i < 100; i++) i < 50 ? 100.0 + i : 150.0 - (i - 50) * 2];
  final history = PriceHistory(
    symbol: 'X',
    currency: 'USD',
    points: [for (var i = 0; i < closes.length; i++) PricePoint(start.add(Duration(days: i)), closes[i])],
  );
  final request = HistoryRequest(
    fetchFrom: start,
    visibleFrom: start.add(const Duration(days: 60)),
    to: start.add(const Duration(days: 100)),
    interval: HistoryInterval.day,
  );

  test('nur sichtbarer Bereich, Indikatoren aus der ganzen Historie', () {
    final d = ChartData.build(history, request, const ChartSettings(tools: {ChartTool.ma20, ChartTool.ma50}));
    expect(d.points.length, 40);
    expect(d.points.first.time, start.add(const Duration(days: 60)));
    final ma50 = d.overlays.firstWhere((o) => o.tool == ChartTool.ma50);
    expect(ma50.values.length, 40);
    expect(ma50.values.every((v) => v != null), isTrue); // dank Vorlauf schon am linken Rand gültig
    expect(d.rsi, isNull);
  });

  test('Veränderung über den sichtbaren Zeitraum', () {
    final d = ChartData.build(history, request, const ChartSettings(tools: {}));
    expect(d.firstClose, closes[60]);
    expect(d.lastClose, closes[99]);
    expect(d.changePercent, closeTo((closes[99] / closes[60] - 1) * 100, 1e-9));
  });

  test('Kreuzungen im sichtbaren Bereich mit Index relativ zur Anzeige', () {
    final all = ChartData.build(
      history,
      HistoryRequest(fetchFrom: start, visibleFrom: start, to: request.to, interval: HistoryInterval.day),
      const ChartSettings(tools: {ChartTool.crosses}),
    );
    expect(all.crosses.map((c) => c.type), contains(CrossType.death));
    final visible = ChartData.build(history, request, const ChartSettings(tools: {ChartTool.crosses}));
    for (final c in visible.crosses) {
      expect(c.index, inInclusiveRange(0, visible.points.length - 1));
    }
  });

  test('Bollinger und RSI', () {
    final d = ChartData.build(history, request, const ChartSettings(tools: {ChartTool.bollinger, ChartTool.rsi}));
    expect(d.bollinger, isNotNull);
    expect(d.bollinger!.upper.length, 40);
    expect(d.rsi!.length, 40);
    expect(d.rsi!.last, lessThan(30)); // stark fallend
  });

  test('leere Historie', () {
    final d = ChartData.build(
      const PriceHistory(symbol: 'X', currency: 'USD', points: []),
      request,
      const ChartSettings(),
    );
    expect(d.points, isEmpty);
    expect(d.changePercent, isNull);
  });
}
