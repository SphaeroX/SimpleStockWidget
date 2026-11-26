import '../currency/currency.dart';

/// Darstellung der Tagesveränderung.
enum ChangeMode { percent, amount, both }

ChangeMode effectiveChangeMode({required ChangeMode? override, required ChangeMode global}) => override ?? global;

String changeModeLabel(ChangeMode m) => switch (m) {
  ChangeMode.percent => 'Prozent',
  ChangeMode.amount => 'Betrag',
  ChangeMode.both => 'Betrag und Prozent',
};

/// Intervall des automatischen Hintergrund-Updates (Android-Minimum: 15 Minuten).
enum UpdateInterval {
  min15(15),
  min30(30),
  min60(60);

  const UpdateInterval(this.minutes);
  final int minutes;
  Duration get duration => Duration(minutes: minutes);
}

/// Reihenfolge der Werte im Widget.
enum SortOrder { manual, nameAsc, gainersFirst, losersFirst }

String sortOrderLabel(SortOrder o) => switch (o) {
  SortOrder.manual => 'Manuell',
  SortOrder.nameAsc => 'Name A–Z',
  SortOrder.gainersFirst => 'Gewinner zuerst',
  SortOrder.losersFirst => 'Verlierer zuerst',
};

class AppSettings {
  const AppSettings({
    this.displayCurrency = originalCurrency,
    this.changeMode = ChangeMode.percent,
    this.updateInterval = UpdateInterval.min30,
    this.sortOrder = SortOrder.manual,
  });

  /// Globale Anzeigewährung (ISO-Code) oder [originalCurrency].
  final String displayCurrency;

  /// Globale Darstellung der Tagesveränderung.
  final ChangeMode changeMode;

  /// Intervall des automatischen Updates.
  final UpdateInterval updateInterval;

  /// Sortierung der Werte im Widget; `manual` = Reihenfolge der Watchlist.
  final SortOrder sortOrder;

  AppSettings copyWith({
    String? displayCurrency,
    ChangeMode? changeMode,
    UpdateInterval? updateInterval,
    SortOrder? sortOrder,
  }) => AppSettings(
    displayCurrency: displayCurrency ?? this.displayCurrency,
    changeMode: changeMode ?? this.changeMode,
    updateInterval: updateInterval ?? this.updateInterval,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    displayCurrency: (json['displayCurrency'] as String?) ?? originalCurrency,
    changeMode: ChangeMode.values.asNameMap()[json['changeMode']] ?? ChangeMode.percent,
    updateInterval: UpdateInterval.values.asNameMap()[json['updateInterval']] ?? UpdateInterval.min30,
    sortOrder: SortOrder.values.asNameMap()[json['sortOrder']] ?? SortOrder.manual,
  );

  Map<String, dynamic> toJson() => {
    'displayCurrency': displayCurrency,
    'changeMode': changeMode.name,
    'updateInterval': updateInterval.name,
    'sortOrder': sortOrder.name,
  };
}
