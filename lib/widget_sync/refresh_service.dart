import 'package:intl/intl.dart';

import '../currency/currency.dart';
import '../format/quote_format.dart';
import '../quotes/quote_provider.dart';
import '../settings/app_settings.dart';
import '../settings/settings_repository.dart';
import '../watchlist/watchlist_repository.dart';
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
  }) : _sync = WidgetSync(widgetStorage),
       _clock = clock ?? DateTime.now;

  final QuoteProvider _quotes;
  final WatchlistRepository _watchlist;
  final SettingsRepository? _settings;
  final WidgetSync _sync;
  final DateTime Function() _clock;

  Future<WidgetPayload> refresh() async {
    final entries = await _watchlist.load();
    final settings = await _settings?.load() ?? const AppSettings();
    final batch = await _quotes.fetchQuotes([for (final e in entries) e.symbol]);

    String targetOf(e) => effectiveTargetCurrency(override: e.currency, global: settings.displayCurrency);
    final pairs = <(String, String)>{
      for (final e in entries)
        if (batch.quotes[e.symbol] case final q?) (normalizedCurrencyCode(q.currency), targetOf(e)),
    };
    final fxSymbols = fxSymbolsFor(pairs).toList()..sort();
    final rates = <String, double>{};
    if (fxSymbols.isNotEmpty) {
      final fx = await _quotes.fetchQuotes(fxSymbols);
      fx.quotes.forEach((s, q) => rates[s] = q.price);
    }

    final now = _clock();
    final rows = <WidgetRow>[];
    for (final e in entries) {
      final q = batch.quotes[e.symbol];
      if (q == null) continue;
      final c = convertQuote(q, target: targetOf(e), rates: rates);
      rows.add(
        WidgetRow(
          name: e.effectiveName,
          price: formatPrice(c.price),
          change: formatSigned(c.change),
          currency: currencySymbol(c.currency),
          direction: c.change > 0 ? Direction.up : (c.change < 0 ? Direction.down : Direction.neutral),
        ),
      );
    }
    final payload = WidgetPayload(updatedAt: now, updatedLabel: DateFormat('HH:mm').format(now), rows: rows);
    await _sync.publish(payload);
    return payload;
  }
}
