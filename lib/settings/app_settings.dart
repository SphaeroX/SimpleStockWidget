import '../currency/currency.dart';

/// Darstellung der Tagesveränderung.
enum ChangeMode { percent, amount, both }

ChangeMode effectiveChangeMode({required ChangeMode? override, required ChangeMode global}) => override ?? global;

String changeModeLabel(ChangeMode m) => switch (m) {
  ChangeMode.percent => 'Prozent',
  ChangeMode.amount => 'Betrag',
  ChangeMode.both => 'Betrag und Prozent',
};

class AppSettings {
  const AppSettings({this.displayCurrency = originalCurrency, this.changeMode = ChangeMode.percent});

  /// Globale Anzeigewährung (ISO-Code) oder [originalCurrency].
  final String displayCurrency;

  /// Globale Darstellung der Tagesveränderung.
  final ChangeMode changeMode;

  AppSettings copyWith({String? displayCurrency, ChangeMode? changeMode}) =>
      AppSettings(displayCurrency: displayCurrency ?? this.displayCurrency, changeMode: changeMode ?? this.changeMode);

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    displayCurrency: (json['displayCurrency'] as String?) ?? originalCurrency,
    changeMode: ChangeMode.values.asNameMap()[json['changeMode']] ?? ChangeMode.percent,
  );

  Map<String, dynamic> toJson() => {'displayCurrency': displayCurrency, 'changeMode': changeMode.name};
}
