import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/format/quote_format.dart';
import 'package:simple_stock_widget/settings/app_settings.dart';
import 'package:simple_stock_widget/widget_sync/widget_payload.dart';

void main() {
  group('formatPrice', () {
    test('Tausenderpunkt und Dezimalkomma', () => expect(formatPrice(50182.95), '50.182,95'));
    test('zwei Nachkommastellen', () => expect(formatPrice(18.5), '18,50'));
    test('kleine Kurse bekommen mehr Nachkommastellen', () {
      expect(formatPrice(0.4567), '0,4567');
      expect(formatPrice(0.000012345), '0,00001235');
    });
  });

  group('Veränderung', () {
    test('Betrag mit Vorzeichen', () {
      expect(formatAmount(-6.08), '-6,08');
      expect(formatAmount(164.25), '+164,25');
      expect(formatAmount(-315.68), '-315,68');
      expect(formatAmount(1634.5), '+1.634,50');
    });
    test('Prozent mit Vorzeichen und %', () {
      expect(formatPercent(-3.913), '-3,91 %');
      expect(formatPercent(1.29), '+1,29 %');
    });
    test('Null ist neutral ohne Vorzeichen', () {
      expect(formatAmount(0), '0,00');
      expect(formatPercent(0.001), '0,00 %');
    });
    test('Modus Prozent, Betrag, beides', () {
      expect(formatChange(ChangeMode.percent, change: -6.08, percent: -3.913), '-3,91 %');
      expect(formatChange(ChangeMode.amount, change: -6.08, percent: -3.913), '-6,08');
      expect(formatChange(ChangeMode.both, change: 1.63, percent: 1.29), '+1,63 (+1,29 %)');
    });
    test('kleine Beträge bei kleinen Kursen', () {
      expect(formatAmount(-0.0123, reference: 0.4567), '-0,0123');
    });
  });

  group('Richtung', () {
    test('hoch, runter, neutral', () {
      expect(directionOf(1.07), Direction.up);
      expect(directionOf(-0.5), Direction.down);
      expect(directionOf(0), Direction.neutral);
    });
    test('Rundung auf null ist neutral', () => expect(directionOf(0.001), Direction.neutral));
  });

  group('effectiveChangeMode', () {
    test('Override schlägt global', () {
      expect(effectiveChangeMode(override: ChangeMode.both, global: ChangeMode.percent), ChangeMode.both);
    });
    test('ohne Override gilt global', () {
      expect(effectiveChangeMode(override: null, global: ChangeMode.amount), ChangeMode.amount);
    });
  });
}
