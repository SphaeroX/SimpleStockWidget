import '../quotes/quote.dart';
import '../settings/app_settings.dart';

const _unset = Object();

class WatchlistEntry {
  const WatchlistEntry({
    required this.symbol,
    required this.name,
    this.type = QuoteType.other,
    this.displayName,
    this.currency,
    this.changeMode,
  });

  static const maxDisplayNameLength = 20;

  final String symbol;

  /// Name laut Kursquelle (z. B. „NVIDIA Corporation“).
  final String name;
  final QuoteType type;

  /// Vom Nutzer vergebener Anzeigename; `null` = Symbol anzeigen.
  final String? displayName;

  /// Währungs-Override: `null` = globale Einstellung, sonst ISO-Code oder `originalCurrency`.
  final String? currency;

  /// Anzeigemodus-Override: `null` = globale Einstellung.
  final ChangeMode? changeMode;

  String get effectiveName => displayName ?? symbol;

  WatchlistEntry copyWith({Object? displayName = _unset, Object? currency = _unset, Object? changeMode = _unset}) =>
      WatchlistEntry(
        symbol: symbol,
        name: name,
        type: type,
        displayName: identical(displayName, _unset) ? this.displayName : displayName as String?,
        currency: identical(currency, _unset) ? this.currency : currency as String?,
        changeMode: identical(changeMode, _unset) ? this.changeMode : changeMode as ChangeMode?,
      );

  WatchlistEntry withDisplayName(String? value) {
    var v = value?.trim();
    if (v != null && v.length > maxDisplayNameLength) v = v.substring(0, maxDisplayNameLength).trim();
    return copyWith(displayName: (v == null || v.isEmpty) ? null : v);
  }

  factory WatchlistEntry.fromJson(Map<String, dynamic> json) => WatchlistEntry(
    symbol: json['symbol'] as String,
    name: (json['name'] as String?) ?? json['symbol'] as String,
    type: QuoteType.values.asNameMap()[json['type']] ?? QuoteType.other,
    displayName: json['displayName'] as String?,
    currency: json['currency'] as String?,
    changeMode: ChangeMode.values.asNameMap()[json['changeMode']],
  );

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'type': type.name,
    if (displayName != null) 'displayName': displayName,
    if (currency != null) 'currency': currency,
    if (changeMode != null) 'changeMode': changeMode!.name,
  };
}
