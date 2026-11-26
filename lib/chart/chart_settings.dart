import 'chart_range.dart';

enum ChartTool { ma20, ma50, ma200, ema20, bollinger, crosses, rsi }

enum CrossPair { ma20ma50, ma50ma200 }

String chartToolLabel(ChartTool t) => switch (t) {
  ChartTool.ma20 => 'MA20',
  ChartTool.ma50 => 'MA50',
  ChartTool.ma200 => 'MA200',
  ChartTool.ema20 => 'EMA20',
  ChartTool.bollinger => 'Bollinger',
  ChartTool.crosses => 'Golden/Death Cross',
  ChartTool.rsi => 'RSI 14',
};

String crossPairLabel(CrossPair p) => switch (p) {
  CrossPair.ma20ma50 => 'MA20 / MA50',
  CrossPair.ma50ma200 => 'MA50 / MA200',
};

/// Zuletzt gewählter Zeitraum und eingeblendete Werkzeuge der Chart-Ansicht.
class ChartSettings {
  const ChartSettings({
    this.range = ChartRange.d90,
    this.tools = const {ChartTool.ma20, ChartTool.ma50, ChartTool.crosses},
    this.crossPair = CrossPair.ma20ma50,
  });

  final ChartRange range;
  final Set<ChartTool> tools;
  final CrossPair crossPair;

  ChartSettings copyWith({ChartRange? range, Set<ChartTool>? tools, CrossPair? crossPair}) =>
      ChartSettings(range: range ?? this.range, tools: tools ?? this.tools, crossPair: crossPair ?? this.crossPair);

  ChartSettings toggle(ChartTool t) => copyWith(tools: tools.contains(t) ? ({...tools}..remove(t)) : {...tools, t});

  factory ChartSettings.fromJson(Map<String, dynamic> json) {
    const d = ChartSettings();
    final tools = json['tools'];
    return ChartSettings(
      range: ChartRange.values.asNameMap()[json['range']] ?? d.range,
      tools: tools is List ? {for (final t in tools) ?ChartTool.values.asNameMap()[t]} : d.tools,
      crossPair: CrossPair.values.asNameMap()[json['crossPair']] ?? d.crossPair,
    );
  }

  Map<String, dynamic> toJson() => {
    'range': range.name,
    'tools': [
      for (final t in ChartTool.values)
        if (tools.contains(t)) t.name,
    ],
    'crossPair': crossPair.name,
  };
}
