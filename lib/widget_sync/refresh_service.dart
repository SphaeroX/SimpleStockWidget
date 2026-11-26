import '../currency/currency.dart';
import '../format/time_format.dart';
import '../quotes/quote_provider.dart';
import '../settings/app_settings.dart';
import '../settings/settings_repository.dart';
import '../watchlist/watchlist_repository.dart';
import 'payload_builder.dart';
import 'widget_keys.dart';
import 'widget_payload.dart';
import 'widget_storage.dart';
import 'widget_sync.dart';

/// Der eine Refresh-Ablauf: Watchlist laden → Kurse + FX holen → umrechnen → formatieren → speichern → Widget aktualisieren.
class RefreshService {
  RefreshService({
    required this._quotes,
    required this._watchlist,
    required WidgetStorage widgetStorage,
    this._settings,
    DateTime Function()? clock,
  }) : _storage = widgetStorage,
       _sync = WidgetSync(widgetStorage),
       _clock = clock ?? DateTime.now;

  final QuoteProvider _quotes;
  final WatchlistRepository _watchlist;
  final SettingsRepository? _settings;
  final WidgetStorage _storage;
  final WidgetSync _sync;
  Future<WidgetPayload?>? _running;

  /// Ein Refresh eines anderen Isolates gilt so lange als laufend.
  static const staleAfter = Duration(seconds: 60);
  final DateTime Function() _clock;

  /// Führt den Refresh aus. Läuft bereits einer (in diesem oder einem anderen Isolate), wird nichts getan:
  /// im selben Isolate kommt das laufende Ergebnis zurück, sonst `null`.
  /// [showLoading] aktualisiert das Widget zusätzlich sofort mit dem Ladezustand (Reload-Button).
  Future<WidgetPayload?> refresh({bool showLoading = false}) {
    return _running ??= _guarded(showLoading).whenComplete(() => _running = null);
  }

  Future<WidgetPayload?> _guarded(bool showLoading) async {
    final now = _clock();
    final other = int.tryParse(await _storage.readString(WidgetKeys.loading) ?? '');
    if (other != null && now.difference(DateTime.fromMillisecondsSinceEpoch(other)) < staleAfter) return null;
    await _storage.saveString(WidgetKeys.loading, now.millisecondsSinceEpoch.toString());
    if (showLoading) await _storage.updateWidget();
    try {
      return await _refresh();
    } finally {
      await _storage.saveString(WidgetKeys.loading, '');
    }
  }

  Future<WidgetPayload> _refresh() async {
    final entries = await _watchlist.load();
    final settings = await _settings?.load() ?? const AppSettings();
    final batch = await _quotes.fetchQuotes([for (final e in entries) e.symbol]);
    if (batch.quotes.isEmpty && batch.errors.isNotEmpty) throw batch.errors.values.first;

    final pairs = <(String, String)>{
      for (final e in entries)
        if (batch.quotes[e.symbol] case final q?) (normalizedCurrencyCode(q.currency), targetCurrencyOf(e, settings)),
    };
    final fxSymbols = fxSymbolsFor(pairs).toList()..sort();
    final rates = <String, double>{};
    if (fxSymbols.isNotEmpty) {
      final fx = await _quotes.fetchQuotes(fxSymbols);
      fx.quotes.forEach((s, q) => rates[s] = q.price);
    }

    final now = _clock();
    final rows = [
      for (final e in entries)
        if (batch.quotes[e.symbol] case final q?) buildRow(e, q, settings, rates),
    ];
    final payload = WidgetPayload(updatedAt: now, updatedLabel: formatUpdatedLabel(now), rows: rows);
    await _sync.publish(payload);
    return payload;
  }
}
