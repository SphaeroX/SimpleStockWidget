import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/currency/currency.dart';
import 'package:simple_stock_widget/quotes/quote.dart';

const nvda = Quote(symbol: 'NVDA', price: 149.3, previousClose: 155.38, currency: 'USD');
const vod = Quote(symbol: 'VOD.L', price: 101.9, previousClose: 102.9, currency: 'GBp');

void main() {
  group('effectiveCurrency', () {
    test('Override schlägt global', () {
      expect(effectiveTargetCurrency(override: 'USD', global: 'EUR'), 'USD');
    });
    test('ohne Override gilt global', () {
      expect(effectiveTargetCurrency(override: null, global: 'EUR'), 'EUR');
    });
    test('Override „Original“ schlägt globale Währung', () {
      expect(effectiveTargetCurrency(override: originalCurrency, global: 'EUR'), originalCurrency);
    });
    test('global Original ohne Override bleibt Original', () {
      expect(effectiveTargetCurrency(override: null, global: originalCurrency), originalCurrency);
    });
  });

  group('normalize', () {
    test('GBp wird in GBP umgerechnet', () {
      final n = normalizeQuoteCurrency(vod);
      expect(n.currency, 'GBP');
      expect(n.price, closeTo(1.019, 1e-9));
      expect(n.previousClose, closeTo(1.029, 1e-9));
    });
    test('USD bleibt unverändert', () => expect(identical(normalizeQuoteCurrency(nvda), nvda), isTrue));
  });

  group('fxPairs', () {
    test('nur benötigte, eindeutige Paare; gleiche Währung ohne Paar', () {
      final pairs = [('USD', 'EUR'), ('GBP', 'EUR'), ('EUR', 'EUR'), ('USD', 'EUR')];
      expect(fxSymbolsFor(Set.of(pairs)), {'USDEUR=X', 'GBPEUR=X'});
    });
  });

  group('convert', () {
    test('USD→EUR: Kurs und Veränderung umgerechnet, Prozent unverändert', () {
      final c = convertQuote(nvda, target: 'EUR', rates: {'USDEUR=X': 0.9});
      expect(c.currency, 'EUR');
      expect(c.price, closeTo(134.37, 1e-9));
      expect(c.change, closeTo(-6.08 * 0.9, 1e-9));
      expect(c.changePercent, closeTo(nvda.changePercent, 1e-12));
      expect(c.converted, isTrue);
    });
    test('GBp→EUR über GBP', () {
      final c = convertQuote(vod, target: 'EUR', rates: {'GBPEUR=X': 1.2});
      expect(c.price, closeTo(1.019 * 1.2, 1e-9));
      expect(c.currency, 'EUR');
    });
    test('gleiche Quell- und Zielwährung: keine Umrechnung', () {
      final c = convertQuote(nvda, target: 'USD', rates: const {});
      expect(c.price, 149.3);
      expect(c.converted, isFalse);
      expect(c.fxMissing, isFalse);
    });
    test('Original: normalisiert, keine Umrechnung', () {
      final c = convertQuote(vod, target: originalCurrency, rates: const {});
      expect(c.currency, 'GBP');
      expect(c.price, closeTo(1.019, 1e-9));
    });
    test('fehlender FX-Kurs → Originalwährung mit Kennzeichnung', () {
      final c = convertQuote(nvda, target: 'EUR', rates: const {});
      expect(c.currency, 'USD');
      expect(c.price, 149.3);
      expect(c.fxMissing, isTrue);
    });
  });

  test('Währungssymbole', () {
    expect(currencySymbol('EUR'), '€');
    expect(currencySymbol('USD'), r'$');
    expect(currencySymbol('GBP'), '£');
    expect(currencySymbol('CHF'), 'CHF');
    expect(currencySymbol('JPY'), 'JPY');
  });
}
