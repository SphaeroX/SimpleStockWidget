import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/chart/chart_range.dart';
import 'package:simple_stock_widget/chart/chart_settings.dart';
import 'package:simple_stock_widget/settings/app_settings.dart';
import 'package:simple_stock_widget/settings/settings_repository.dart';

import '../helpers/fakes.dart';

void main() {
  test('Standard: 90 Tage, MA20 + MA50 + Kreuzungen 20/50', () async {
    final s = await SettingsRepository(InMemoryStore()).load();
    expect(s.chart.range, ChartRange.d90);
    expect(s.chart.tools, {ChartTool.ma20, ChartTool.ma50, ChartTool.crosses});
    expect(s.chart.crossPair, CrossPair.ma20ma50);
  });

  test('Persistenz und alte Daten ohne Chart-Einstellungen', () async {
    final store = InMemoryStore();
    const chart = ChartSettings(
      range: ChartRange.y1,
      tools: {ChartTool.ma200, ChartTool.rsi},
      crossPair: CrossPair.ma50ma200,
    );
    await SettingsRepository(store).save(const AppSettings(chart: chart));
    final loaded = (await SettingsRepository(store).load()).chart;
    expect(loaded.range, ChartRange.y1);
    expect(loaded.tools, {ChartTool.ma200, ChartTool.rsi});
    expect(loaded.crossPair, CrossPair.ma50ma200);

    store.data[SettingsRepository.storageKey] = '{"displayCurrency":"EUR"}';
    expect((await SettingsRepository(store).load()).chart.range, ChartRange.d90);
  });

  test('Werkzeug umschalten', () {
    const c = ChartSettings();
    expect(c.toggle(ChartTool.rsi).tools, contains(ChartTool.rsi));
    expect(c.toggle(ChartTool.ma20).tools, isNot(contains(ChartTool.ma20)));
  });

  test('Beschriftungen', () {
    expect(chartToolLabel(ChartTool.crosses), 'Golden/Death Cross');
    expect(crossPairLabel(CrossPair.ma20ma50), 'MA20 / MA50');
  });
}
