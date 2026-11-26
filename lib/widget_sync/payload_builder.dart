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
    dim: const {MarketState.closed, MarketState.pre, MarketState.post}.contains(q.marketState),
  );
}

/// Sortiert Einträge samt Kurs für das Widget. Stabil (Gleichstand behält die Watchlist-Reihenfolge);
/// Einträge ohne Kurs stehen bei Gewinner/Verlierer immer am Ende.
List<(WatchlistEntry, Quote?)> sortEntries(List<(WatchlistEntry, Quote?)> items, SortOrder order) {
  if (order == SortOrder.manual) return List.of(items);
  final indexed = [for (var i = 0; i < items.length; i++) (i, items[i])];
  int compare((int, (WatchlistEntry, Quote?)) a, (int, (WatchlistEntry, Quote?)) b) {
    final (ia, (ea, qa)) = a;
    final (ib, (eb, qb)) = b;
    final int c;
    switch (order) {
      case SortOrder.nameAsc:
        c = ea.effectiveName.toLowerCase().compareTo(eb.effectiveName.toLowerCase());
      case SortOrder.gainersFirst || SortOrder.losersFirst:
        if (qa == null || qb == null) {
          c = (qa == null ? 1 : 0) - (qb == null ? 1 : 0);
        } else {
          final diff = qa.changePercent.compareTo(qb.changePercent);
          c = order == SortOrder.gainersFirst ? -diff : diff;
        }
      case SortOrder.manual:
        c = 0;
    }
    return c != 0 ? c : ia.compareTo(ib);
  }

  indexed.sort(compare);
  return [for (final (_, item) in indexed) item];
}
