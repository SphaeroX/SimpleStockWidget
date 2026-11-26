import '../currency/currency.dart';

class AppSettings {
  const AppSettings({this.displayCurrency = originalCurrency});

  /// Globale Anzeigewährung (ISO-Code) oder [originalCurrency].
  final String displayCurrency;

  AppSettings copyWith({String? displayCurrency}) =>
      AppSettings(displayCurrency: displayCurrency ?? this.displayCurrency);

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      AppSettings(displayCurrency: (json['displayCurrency'] as String?) ?? originalCurrency);

  Map<String, dynamic> toJson() => {'displayCurrency': displayCurrency};
}
