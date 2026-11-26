import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/chart/indicators.dart';

void main() {
  final v = <double>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  test('SMA: null bis genug Werte, dann gleitender Durchschnitt', () {
    final s = sma(v, 3);
    expect(s.take(2), [null, null]);
    expect(s[2], 2);
    expect(s[9], 9);
  });

  test('EMA: Start mit SMA, dann exponentiell (k = 2/(n+1))', () {
    final e = ema(v, 3);
    expect(e[1], isNull);
    expect(e[2], 2);
    expect(e[3], closeTo(3, 1e-12)); // 4*0.5 + 2*0.5
    expect(e[9], closeTo(9, 1e-12));
  });

  test('Bollinger: Mitte = SMA, Bänder ± k·Standardabweichung', () {
    final b = bollinger([2, 4, 4, 4, 5, 5, 7, 9], period: 8, k: 2);
    expect(b.middle.last, 5);
    expect(b.upper.last, closeTo(9, 1e-12)); // σ = 2
    expect(b.lower.last, closeTo(1, 1e-12));
    expect(b.upper.first, isNull);
  });

  group('RSI (Wilder)', () {
    test('nur steigend → 100', () => expect(rsi(v, period: 3).last, 100));
    test('nur fallend → 0', () => expect(rsi(v.reversed.toList(), period: 3).last, 0));
    test('gleich viele Gewinne und Verluste → 50', () {
      expect(rsi([10, 11, 10, 11, 10], period: 4).last, closeTo(50, 1e-9));
    });
    test('zu wenige Werte → null', () => expect(rsi([1, 2], period: 14).every((x) => x == null), isTrue));
  });

  test('Kreuzungen: Golden Cross (schnell kreuzt nach oben), Death Cross (nach unten)', () {
    final fast = <double?>[null, 1, 2, 4, 3, 1];
    final slow = <double?>[null, 2, 2.5, 3, 3.5, 2];
    final c = crosses(fast, slow);
    expect(c, [const Cross(3, CrossType.golden), const Cross(4, CrossType.death)]);
  });

  test('Berührung ohne Durchkreuzen zählt nicht', () {
    expect(crosses(<double?>[1, 2, 1], <double?>[2, 2, 2]), isEmpty);
  });
}
