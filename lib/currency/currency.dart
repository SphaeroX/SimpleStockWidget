import '../quotes/quote.dart';

/// Pseudo-Währung „Originalwährung der Quelle beibehalten“.
const originalCurrency = 'ORIGINAL';

/// Auswählbare Anzeigewährungen (erweiterbar).
const selectableCurrencies = ['EUR', 'USD', 'GBP', 'CHF'];

String effectiveTargetCurrency({required String? override, required String global}) => override ?? global;

/// Unterwährungen (Pence, Agorot, Cent), die Yahoo für einige Börsen liefert.
const _subunits = {'GBp': 'GBP', 'GBX': 'GBP', 'ILA': 'ILS', 'ZAc': 'ZAR'};

/// Rechnet Kurse in Unterwährungen (z. B. GBp) in die Hauptwährung um.
Quote normalizeQuoteCurrency(Quote q) {
  final main = _subunits[q.currency];
  if (main == null) return q;
  return Quote(
    symbol: q.symbol,
    price: q.price / 100,
    previousClose: q.previousClose / 100,
    currency: main,
    name: q.name,
    type: q.type,
    marketState: q.marketState,
    marketTime: q.marketTime,
  );
}

String normalizedCurrencyCode(String code) => _subunits[code] ?? code;

String fxSymbol(String from, String to) => '$from$to=X';

/// Yahoo-FX-Symbole für die benötigten (von, nach)-Paare; gleiche Währungen entfallen.
Set<String> fxSymbolsFor(Set<(String, String)> pairs) => {
  for (final (from, to) in pairs)
    if (from != to && to != originalCurrency) fxSymbol(from, to),
};

class ConvertedQuote {
  const ConvertedQuote({
    required this.price,
    required this.change,
    required this.changePercent,
    required this.currency,
    this.converted = false,
    this.fxMissing = false,
  });

  final double price;
  final double change;
  final double changePercent;
  final String currency;
  final bool converted;
  final bool fxMissing;
}

/// Rechnet Kurs und absolute Veränderung mit dem aktuellen FX-Kurs um; Prozent bleibt unverändert.
ConvertedQuote convertQuote(Quote quote, {required String target, required Map<String, double> rates}) {
  final q = normalizeQuoteCurrency(quote);
  ConvertedQuote unchanged({bool fxMissing = false}) => ConvertedQuote(
    price: q.price,
    change: q.change,
    changePercent: q.changePercent,
    currency: q.currency,
    fxMissing: fxMissing,
  );
  if (target == originalCurrency || target == q.currency) return unchanged();
  final rate = rates[fxSymbol(q.currency, target)];
  if (rate == null) return unchanged(fxMissing: true);
  return ConvertedQuote(
    price: q.price * rate,
    change: q.change * rate,
    changePercent: q.changePercent,
    currency: target,
    converted: true,
  );
}

String currencySymbol(String code) => switch (code) {
  'EUR' => '€',
  'USD' => r'$',
  'GBP' => '£',
  _ => code,
};

String currencyLabel(String code) => switch (code) {
  originalCurrency => 'Originalwährung',
  'EUR' => 'Euro (€)',
  'USD' => r'US-Dollar ($)',
  'GBP' => 'Britisches Pfund (£)',
  'CHF' => 'Schweizer Franken (CHF)',
  _ => code,
};
