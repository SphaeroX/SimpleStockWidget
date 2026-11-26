import 'package:intl/intl.dart';

import '../format/quote_format.dart';
import '../quotes/quote_provider.dart';
import '../watchlist/watchlist_repository.dart';
import 'widget_payload.dart';
import 'widget_storage.dart';
import 'widget_sync.dart';

/// Der eine Refresh-Ablauf: Watchlist laden → Kurse holen → formatieren → speichern → Widget aktualisieren.
class RefreshService {
  RefreshService({
    required this._quotes,
    required this._watchlist,
    required WidgetStorage widgetStorage,
    DateTime Function()? clock,
  }) : _sync = WidgetSync(widgetStorage),
       _clock = clock ?? DateTime.now;

  final QuoteProvider _quotes;
  final WatchlistRepository _watchlist;
  final WidgetSync _sync;
  final DateTime Function() _clock;

  Future<WidgetPayload> refresh() async {
    final entries = await _watchlist.load();
    final batch = await _quotes.fetchQuotes([for (final e in entries) e.symbol]);
    final now = _clock();
    final rows = <WidgetRow>[];
    for (final e in entries) {
      final q = batch.quotes[e.symbol];
      if (q == null) continue;
      rows.add(
        WidgetRow(
          name: e.effectiveName,
          price: formatPrice(q.price),
          change: formatSigned(q.change),
          direction: q.change > 0 ? Direction.up : (q.change < 0 ? Direction.down : Direction.neutral),
        ),
      );
    }
    final payload = WidgetPayload(updatedAt: now, updatedLabel: DateFormat('HH:mm').format(now), rows: rows);
    await _sync.publish(payload);
    return payload;
  }
}
