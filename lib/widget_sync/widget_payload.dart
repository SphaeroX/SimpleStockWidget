enum Direction { up, down, neutral }

class WidgetRow {
  const WidgetRow({
    required this.name,
    required this.price,
    required this.change,
    required this.direction,
    this.currency = '',
    this.dim = false,
    this.error = false,
    this.symbol = '',
  });

  /// Zeile für einen Wert, dessen Kurs nicht geladen werden konnte.
  const WidgetRow.failed(this.name)
    : price = '–',
      change = '–',
      direction = Direction.neutral,
      currency = '',
      dim = false,
      error = true,
      symbol = '';

  final String name;
  final String price;
  final String change;
  final Direction direction;

  /// Währungssymbol (z. B. „€“), leer wenn nicht angegeben.
  final String currency;

  /// Börse nicht im regulären Handel (geschlossen, vor-/nachbörslich) → abgeblendet anzeigen.
  final bool dim;

  /// Kurs konnte nicht geladen werden.
  final bool error;

  /// Symbol für den Chart-Link beim Antippen; leer = kein Chart (z. B. fehlgeschlagene Zeile).
  final String symbol;

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'change': change,
    'dir': direction.name,
    if (currency.isNotEmpty) 'currency': currency,
    if (dim) 'dim': true,
    if (error) 'error': true,
    if (symbol.isNotEmpty) 'symbol': symbol,
  };
}

/// Vertrag zwischen Dart und den nativen Widgets. Enthält nur fertig formatierte Werte.
class WidgetPayload {
  const WidgetPayload({
    required this.updatedAt,
    required this.updatedLabel,
    required this.rows,
    this.staleAt,
    this.staleLabel,
    this.empty = false,
  });

  final DateTime updatedAt;
  final String updatedLabel;
  final List<WidgetRow> rows;

  /// Ab diesem Zeitpunkt zeigt das Widget [staleLabel] statt „Letzter Abruf“.
  final DateTime? staleAt;
  final String? staleLabel;

  /// Watchlist ist leer → Hinweis „In der App Werte hinzufügen“.
  final bool empty;

  Map<String, dynamic> toJson() => {
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'updatedLabel': updatedLabel,
    'rows': [for (final r in rows) r.toJson()],
    if (staleAt != null) 'staleAt': staleAt!.millisecondsSinceEpoch,
    if (staleLabel != null) 'staleLabel': staleLabel,
    if (empty) 'empty': true,
  };
}
