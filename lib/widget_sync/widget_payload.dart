enum Direction { up, down, neutral }

class WidgetRow {
  const WidgetRow({
    required this.name,
    required this.price,
    required this.change,
    required this.direction,
    this.currency = '',
  });

  final String name;
  final String price;
  final String change;
  final Direction direction;

  /// Währungssymbol (z. B. „€“), leer wenn nicht angegeben.
  final String currency;

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'change': change,
    'dir': direction.name,
    if (currency.isNotEmpty) 'currency': currency,
  };
}

/// Vertrag zwischen Dart und den nativen Widgets. Enthält nur fertig formatierte Werte.
class WidgetPayload {
  const WidgetPayload({required this.updatedAt, required this.updatedLabel, required this.rows});

  final DateTime updatedAt;
  final String updatedLabel;
  final List<WidgetRow> rows;

  Map<String, dynamic> toJson() => {
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'updatedLabel': updatedLabel,
    'rows': [for (final r in rows) r.toJson()],
  };
}
