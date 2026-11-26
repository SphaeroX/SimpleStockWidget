import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/settings/app_settings.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';

const base = WatchlistEntry(symbol: 'IWDA.L', name: 'iShares Core MSCI World', type: QuoteType.etf);

void main() {
  group('effectiveName', () {
    test('eigener Name hat Vorrang', () {
      expect(base.withDisplayName('msci world').effectiveName, 'msci world');
    });
    test('ohne eigenen Namen das Symbol', () {
      expect(base.effectiveName, 'IWDA.L');
    });
    test('leerer oder nur Leerzeichen-Name → Symbol', () {
      expect(base.withDisplayName('   ').effectiveName, 'IWDA.L');
      expect(base.withDisplayName('   ').displayName, isNull);
      expect(base.withDisplayName(null).displayName, isNull);
    });
    test('Name wird getrimmt und auf 20 Zeichen begrenzt', () {
      final e = base.withDisplayName('  Ein sehr sehr langer Anzeigename  ');
      expect(e.displayName, 'Ein sehr sehr langer');
      expect(e.displayName!.length, WatchlistEntry.maxDisplayNameLength);
    });
  });

  test('alte Daten ohne displayName werden geladen', () {
    final e = WatchlistEntry.fromJson({'symbol': 'NVDA', 'name': 'NVIDIA', 'type': 'equity'});
    expect(e.displayName, isNull);
    expect(e.effectiveName, 'NVDA');
  });

  test('JSON-Rundreise erhält displayName', () {
    final e = WatchlistEntry.fromJson(base.withDisplayName('msci world').toJson());
    expect(e.displayName, 'msci world');
  });

  test('Modus-Override: JSON-Rundreise und Zurücksetzen', () {
    final e = WatchlistEntry.fromJson(base.copyWith(changeMode: ChangeMode.amount).toJson());
    expect(e.changeMode, ChangeMode.amount);
    expect(e.copyWith(changeMode: null).changeMode, isNull);
    expect(e.withDisplayName('x').changeMode, ChangeMode.amount);
  });
}
