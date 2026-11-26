import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../chart/chart_data.dart';
import '../chart/chart_range.dart';
import '../chart/chart_settings.dart';
import '../chart/indicators.dart';
import '../chart/price_history.dart';
import '../currency/currency.dart';
import '../format/quote_format.dart';
import '../quotes/providers.dart';
import '../watchlist/watchlist_entry.dart';
import 'entry_detail_page.dart';
import 'providers.dart';

const _toolColors = {
  ChartTool.ma20: Color(0xFFFF9800),
  ChartTool.ma50: Color(0xFF2196F3),
  ChartTool.ma200: Color(0xFF9C27B0),
  ChartTool.ema20: Color(0xFF009688),
};
const _golden = Color(0xFF2E7D32);
const _death = Color(0xFFC62828);

/// Kursverlauf eines Werts mit wählbarem Zeitraum und einblendbaren Werkzeugen.
class ChartPage extends ConsumerStatefulWidget {
  const ChartPage({super.key, required this.entry});
  final WatchlistEntry entry;

  @override
  ConsumerState<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends ConsumerState<ChartPage> {
  DateTimeRange? _custom;
  HistoryRequest? _request;
  Future<PriceHistory>? _history;

  void _load(ChartSettings chart) {
    final request = _custom == null
        ? HistoryRequest.forRange(chart.range, now: DateTime.now())
        : HistoryRequest.custom(_custom!.start, _custom!.end.add(const Duration(days: 1)));
    _request = request;
    _history = ref
        .read(priceHistoryProviderProvider)
        .fetchHistory(widget.entry.symbol, from: request.fetchFrom, to: request.to, interval: request.interval);
  }

  Future<void> _changeChart(ChartSettings Function(ChartSettings) change, {bool reload = false}) async {
    final current = ref.read(settingsProvider).value?.chart ?? const ChartSettings();
    final next = change(current);
    if (reload) setState(() => _load(next));
    await ref.read(settingsProvider.notifier).change((s) => s.copyWith(chart: next));
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: now,
      initialDateRange: _custom ?? DateTimeRange(start: now.subtract(const Duration(days: 180)), end: now),
    );
    if (picked == null) return;
    setState(() {
      _custom = picked;
      _load(ref.read(settingsProvider).value?.chart ?? const ChartSettings());
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final chart = settings.value?.chart;
    if (chart == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.entry.displayName ?? widget.entry.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_history == null) _load(chart);
    final inWatchlist = ref.watch(watchlistProvider).value?.any((e) => e.symbol == widget.entry.symbol) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.entry.displayName ?? widget.entry.name),
            Text(widget.entry.symbol, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          if (inWatchlist)
            IconButton(
              tooltip: 'Eintrag bearbeiten',
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => EntryDetailPage(entry: widget.entry))),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final r in ChartRange.values)
                ChoiceChip(
                  label: Text(chartRangeLabel(r)),
                  selected: _custom == null && chart.range == r,
                  onSelected: (_) {
                    _custom = null;
                    _changeChart((c) => c.copyWith(range: r), reload: true);
                  },
                ),
              ChoiceChip(
                avatar: const Icon(Icons.date_range, size: 18),
                label: Text(
                  _custom == null
                      ? 'Eigener'
                      : '${DateFormat('dd.MM.yy').format(_custom!.start)}–${DateFormat('dd.MM.yy').format(_custom!.end)}',
                ),
                selected: _custom != null,
                onSelected: (_) => _pickCustom(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<PriceHistory>(
            future: _history,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(height: 320, child: Center(child: CircularProgressIndicator()));
              }
              if (snap.hasError) {
                return SizedBox(
                  height: 320,
                  child: Center(child: Text('Verlauf konnte nicht geladen werden:\n${snap.error}')),
                );
              }
              final data = ChartData.build(snap.data!, _request!, chart);
              if (data.points.length < 2) {
                return const SizedBox(height: 320, child: Center(child: Text('Keine Daten für diesen Zeitraum')));
              }
              return _ChartView(data: data, interval: _request!.interval, settings: chart);
            },
          ),
          const SizedBox(height: 16),
          Text('Werkzeuge', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in ChartTool.values)
                FilterChip(
                  label: Text(chartToolLabel(t)),
                  avatar: _toolColors[t] == null ? null : CircleAvatar(backgroundColor: _toolColors[t], radius: 6),
                  selected: chart.tools.contains(t),
                  onSelected: (_) => _changeChart((c) => c.toggle(t)),
                ),
            ],
          ),
          if (chart.tools.contains(ChartTool.crosses)) ...[
            const SizedBox(height: 12),
            SegmentedButton<CrossPair>(
              segments: [for (final p in CrossPair.values) ButtonSegment(value: p, label: Text(crossPairLabel(p)))],
              selected: {chart.crossPair},
              onSelectionChanged: (v) => _changeChart((c) => c.copyWith(crossPair: v.single)),
            ),
            const SizedBox(height: 4),
            const Text('▲ grün: Golden Cross (kurzer Schnitt kreuzt nach oben) · ▼ rot: Death Cross'),
          ],
        ],
      ),
    );
  }
}

class _ChartView extends StatelessWidget {
  const _ChartView({required this.data, required this.interval, required this.settings});
  final ChartData data;
  final HistoryInterval interval;
  final ChartSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final change = data.changePercent ?? 0;
    final changeColor = change > 0 ? _golden : (change < 0 ? _death : scheme.onSurfaceVariant);
    final dateFormat = switch (interval) {
      HistoryInterval.hour => DateFormat('dd.MM. HH:mm'),
      HistoryInterval.day => DateFormat('dd.MM.yy'),
      HistoryInterval.week => DateFormat('MM/yyyy'),
    };
    final axisFormat = switch (interval) {
      HistoryInterval.hour => DateFormat('dd.MM.'),
      HistoryInterval.day => DateFormat('dd.MM.'),
      HistoryInterval.week => DateFormat('yyyy'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${formatPrice(data.lastClose!)} ${currencySymbol(data.currency)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 12),
            Text(formatPercent(change), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: changeColor)),
            const SizedBox(width: 6),
            Text('im Zeitraum', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          key: const Key('price-chart'),
          height: 300,
          child: LineChart(_priceChart(scheme, dateFormat, axisFormat)),
        ),
        if (data.overlays.isNotEmpty || data.bollinger != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 12,
              children: [
                for (final o in data.overlays) _Legend(color: _toolColors[o.tool]!, label: chartToolLabel(o.tool)),
                if (data.bollinger != null) _Legend(color: scheme.outline, label: 'Bollinger 20/2'),
              ],
            ),
          ),
        if (data.rsi != null) ...[
          const SizedBox(height: 16),
          Text('RSI 14', style: Theme.of(context).textTheme.labelMedium),
          SizedBox(key: const Key('rsi-chart'), height: 110, child: LineChart(_rsiChart(scheme))),
        ],
      ],
    );
  }

  List<FlSpot> _spots(List<double?> values) => [
    for (var i = 0; i < values.length; i++) values[i] == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), values[i]!),
  ];

  FlTitlesData _titles(DateFormat axisFormat, {bool showBottom = true}) {
    final n = data.points.length;
    final step = (n / 4).ceilToDouble().clamp(1, double.infinity);
    return FlTitlesData(
      topTitles: const AxisTitles(),
      leftTitles: const AxisTitles(),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 56,
          getTitlesWidget: (v, meta) => v == meta.max || v == meta.min
              ? const SizedBox.shrink()
              : Text(formatPrice(v), style: const TextStyle(fontSize: 10)),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showBottom,
          reservedSize: 22,
          interval: step.toDouble(),
          getTitlesWidget: (v, meta) {
            final i = v.round();
            if (i < 0 || i >= n || v != i.toDouble()) return const SizedBox.shrink();
            return Text(axisFormat.format(data.points[i].time.toLocal()), style: const TextStyle(fontSize: 10));
          },
        ),
      ),
    );
  }

  LineChartData _priceChart(ColorScheme scheme, DateFormat dateFormat, DateFormat axisFormat) {
    final closes = [for (final p in data.points) p.close];
    final up = (data.changePercent ?? 0) >= 0;
    final mainColor = up ? _golden : _death;
    final bars = <LineChartBarData>[
      LineChartBarData(
        spots: _spots(closes),
        color: mainColor,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: true, color: mainColor.withValues(alpha: 0.08)),
      ),
    ];
    final betweens = <BetweenBarsData>[];
    final b = data.bollinger;
    if (b != null) {
      for (final band in [b.upper, b.lower]) {
        bars.add(
          LineChartBarData(
            spots: _spots(band),
            color: scheme.outline,
            barWidth: 1,
            dashArray: [4, 3],
            dotData: const FlDotData(show: false),
          ),
        );
      }
      betweens.add(
        BetweenBarsData(
          fromIndex: bars.length - 2,
          toIndex: bars.length - 1,
          color: scheme.outline.withValues(alpha: 0.08),
        ),
      );
    }
    for (final o in data.overlays) {
      bars.add(
        LineChartBarData(
          spots: _spots(o.values),
          color: _toolColors[o.tool],
          barWidth: 1.5,
          dotData: const FlDotData(show: false),
        ),
      );
    }
    if (data.crosses.isNotEmpty) {
      final types = {for (final c in data.crosses) c.index: c.type};
      bars.add(
        LineChartBarData(
          spots: [for (final c in data.crosses) FlSpot(c.index.toDouble(), closes[c.index])],
          color: Colors.transparent,
          barWidth: 0,
          dotData: FlDotData(
            getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
              radius: 5,
              color: types[spot.x.round()] == CrossType.golden ? _golden : _death,
              strokeWidth: 2,
              strokeColor: scheme.surface,
            ),
          ),
        ),
      );
    }

    return LineChartData(
      lineBarsData: bars,
      betweenBarsData: betweens,
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: _titles(axisFormat),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => scheme.inverseSurface,
          getTooltipItems: (spots) => [
            for (final s in spots)
              s.barIndex == 0
                  ? LineTooltipItem(
                      '${dateFormat.format(data.points[s.x.round()].time.toLocal())}\n${formatPrice(s.y)}',
                      TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                    )
                  : null,
          ],
        ),
      ),
    );
  }

  LineChartData _rsiChart(ColorScheme scheme) => LineChartData(
    minY: 0,
    maxY: 100,
    lineBarsData: [
      LineChartBarData(
        spots: _spots(data.rsi!),
        color: scheme.primary,
        barWidth: 1.5,
        dotData: const FlDotData(show: false),
      ),
    ],
    extraLinesData: ExtraLinesData(
      horizontalLines: [
        for (final y in [30.0, 70.0])
          HorizontalLine(y: y, color: (y == 70 ? _death : _golden).withValues(alpha: 0.6), dashArray: [4, 3]),
      ],
    ),
    gridData: const FlGridData(show: false),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      topTitles: const AxisTitles(),
      leftTitles: const AxisTitles(),
      bottomTitles: const AxisTitles(),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 56,
          interval: 35,
          getTitlesWidget: (v, _) =>
              v == 30 || v == 70 ? Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)) : const SizedBox(),
        ),
      ),
    ),
    lineTouchData: const LineTouchData(enabled: false),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 14, height: 3, color: color),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
