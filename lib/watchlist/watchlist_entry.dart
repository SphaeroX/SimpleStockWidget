import '../quotes/quote.dart';

class WatchlistEntry {
  const WatchlistEntry({required this.symbol, required this.name, this.type = QuoteType.other});

  final String symbol;
  final String name;
  final QuoteType type;

  factory WatchlistEntry.fromJson(Map<String, dynamic> json) => WatchlistEntry(
    symbol: json['symbol'] as String,
    name: (json['name'] as String?) ?? json['symbol'] as String,
    type: QuoteType.values.asNameMap()[json['type']] ?? QuoteType.other,
  );

  Map<String, dynamic> toJson() => {'symbol': symbol, 'name': name, 'type': type.name};
}
