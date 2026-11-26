import '../quotes/quote.dart';

class WatchlistEntry {
  const WatchlistEntry({required this.symbol, required this.name, this.type = QuoteType.other, this.displayName});

  static const maxDisplayNameLength = 20;

  final String symbol;

  /// Name laut Kursquelle (z. B. „NVIDIA Corporation“).
  final String name;
  final QuoteType type;

  /// Vom Nutzer vergebener Anzeigename; `null` = Symbol anzeigen.
  final String? displayName;

  String get effectiveName => displayName ?? symbol;

  WatchlistEntry withDisplayName(String? value) {
    var v = value?.trim();
    if (v != null && v.length > maxDisplayNameLength) v = v.substring(0, maxDisplayNameLength).trim();
    return WatchlistEntry(symbol: symbol, name: name, type: type, displayName: (v == null || v.isEmpty) ? null : v);
  }

  factory WatchlistEntry.fromJson(Map<String, dynamic> json) => WatchlistEntry(
    symbol: json['symbol'] as String,
    name: (json['name'] as String?) ?? json['symbol'] as String,
    type: QuoteType.values.asNameMap()[json['type']] ?? QuoteType.other,
    displayName: json['displayName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'type': type.name,
    if (displayName != null) 'displayName': displayName,
  };
}
