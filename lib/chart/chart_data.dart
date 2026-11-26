import 'chart_range.dart';
import 'chart_settings.dart';
import 'indicators.dart';
import 'indicators.dart' as ind;
import 'price_history.dart';

class Overlay {
  const Overlay(this.tool, this.values);
  final ChartTool tool;
  final List<double?> values;
}

/// Alles, was die Chart-Ansicht zeichnet – berechnet aus der ganzen Historie, zugeschnitten auf den sichtbaren Bereich.
class ChartData {
  const ChartData({
    required this.points,
    required this.currency,
    this.overlays = const [],
    this.bollinger,
    this.crosses = const [],
    this.rsi,
  });

  final List<PricePoint> points;
  final String currency;
  final List<Overlay> overlays;
  final BollingerBands? bollinger;
  final List<Cross> crosses;
  final List<double?>? rsi;

  double? get firstClose => points.isEmpty ? null : points.first.close;
  double? get lastClose => points.isEmpty ? null : points.last.close;
  double? get changePercent => (firstClose == null || firstClose == 0) ? null : (lastClose! / firstClose! - 1) * 100;

  factory ChartData.build(PriceHistory history, HistoryRequest request, ChartSettings settings) {
    final all = history.points;
    final from = request.visibleFrom;
    var offset = from == null ? 0 : all.indexWhere((p) => !p.time.isBefore(from));
    if (offset < 0) offset = all.length;
    final closes = [for (final p in all) p.close];
    List<T> cut<T>(List<T> v) => v.sublist(offset);
    final tools = settings.tools;

    final overlays = <Overlay>[
      if (tools.contains(ChartTool.ma20)) Overlay(ChartTool.ma20, cut(sma(closes, 20))),
      if (tools.contains(ChartTool.ma50)) Overlay(ChartTool.ma50, cut(sma(closes, 50))),
      if (tools.contains(ChartTool.ma200)) Overlay(ChartTool.ma200, cut(sma(closes, 200))),
      if (tools.contains(ChartTool.ema20)) Overlay(ChartTool.ema20, cut(ema(closes, 20))),
    ];

    BollingerBands? bands;
    if (tools.contains(ChartTool.bollinger)) {
      final b = ind.bollinger(closes);
      bands = BollingerBands(cut(b.middle), cut(b.upper), cut(b.lower));
    }

    var crossList = const <Cross>[];
    if (tools.contains(ChartTool.crosses)) {
      final (fast, slow) = switch (settings.crossPair) {
        CrossPair.ma20ma50 => (20, 50),
        CrossPair.ma50ma200 => (50, 200),
      };
      crossList = [
        for (final c in ind.crosses(sma(closes, fast), sma(closes, slow)))
          if (c.index >= offset) Cross(c.index - offset, c.type),
      ];
    }

    return ChartData(
      points: cut(all),
      currency: history.currency,
      overlays: overlays,
      bollinger: bands,
      crosses: crossList,
      rsi: tools.contains(ChartTool.rsi) ? cut(ind.rsi(closes)) : null,
    );
  }
}
