import 'package:intl/intl.dart';

import '../settings/app_settings.dart';
import '../widget_sync/widget_payload.dart';

final _formats = <int, NumberFormat>{};

NumberFormat _format(int decimals) =>
    _formats.putIfAbsent(decimals, () => NumberFormat('#,##0.${'0' * decimals}', 'de_DE'));

/// Nachkommastellen abhängig von der Größe des Kurses (kleine Krypto-Kurse brauchen mehr).
int decimalsFor(double reference) {
  final a = reference.abs();
  if (a >= 1) return 2;
  if (a >= 0.01) return 4;
  return 8;
}

String formatPrice(double value) => _format(decimalsFor(value)).format(value);

String _signed(double value, int decimals, [String suffix = '']) {
  final text = _format(decimals).format(value.abs());
  final isZero = double.parse(value.abs().toStringAsFixed(decimals)) == 0;
  if (isZero) return '$text$suffix';
  return '${value > 0 ? '+' : '-'}$text$suffix';
}

/// Absolute Veränderung mit Vorzeichen; Genauigkeit richtet sich nach [reference] (Kurs), sonst 2 Stellen.
String formatAmount(double value, {double? reference}) =>
    _signed(value, reference == null ? 2 : decimalsFor(reference));

String formatPercent(double value) => _signed(value, 2, ' %');

String formatChange(ChangeMode mode, {required double change, required double percent, double? reference}) =>
    switch (mode) {
      ChangeMode.percent => formatPercent(percent),
      ChangeMode.amount => formatAmount(change, reference: reference),
      ChangeMode.both => '${formatAmount(change, reference: reference)} (${formatPercent(percent)})',
    };

Direction directionOf(double change, {double? reference}) {
  final decimals = reference == null ? 2 : decimalsFor(reference);
  final rounded = double.parse(change.toStringAsFixed(decimals));
  if (rounded > 0) return Direction.up;
  if (rounded < 0) return Direction.down;
  return Direction.neutral;
}
