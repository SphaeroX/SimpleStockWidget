import '../currency/currency.dart';
import '../format/quote_format.dart';
import '../quotes/quote.dart';
import '../settings/app_settings.dart';
import '../watchlist/watchlist_entry.dart';
import 'widget_payload.dart';

String targetCurrencyOf(WatchlistEntry e, AppSettings s) =>
    effectiveTargetCurrency(override: e.currency, global: s.displayCurrency);

/// Baut eine Widget-Zeile aus Eintrag, Kurs und Einstellungen (rein, ohne Seiteneffekte).
WidgetRow buildRow(WatchlistEntry e, Quote q, AppSettings settings, Map<String, double> rates) {
  final c = convertQuote(q, target: targetCurrencyOf(e, settings), rates: rates);
  final mode = effectiveChangeMode(override: e.changeMode, global: settings.changeMode);
  final direction = mode == ChangeMode.percent
      ? directionOf(c.changePercent)
      : directionOf(c.change, reference: c.price);
  return WidgetRow(
    name: e.effectiveName,
    price: formatPrice(c.price),
    change: formatChange(mode, change: c.change, percent: c.changePercent, reference: c.price),
    currency: currencySymbol(c.currency),
    direction: direction,
  );
}
