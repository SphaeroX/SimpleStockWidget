import 'dart:math' as math;

/// Einfacher gleitender Durchschnitt; `null`, solange weniger als [period] Werte vorliegen.
List<double?> sma(List<double> values, int period) {
  final out = List<double?>.filled(values.length, null);
  var sum = 0.0;
  for (var i = 0; i < values.length; i++) {
    sum += values[i];
    if (i >= period) sum -= values[i - period];
    if (i >= period - 1) out[i] = sum / period;
  }
  return out;
}

/// Exponentieller Durchschnitt (k = 2/(n+1)), Startwert = SMA der ersten [period] Werte.
List<double?> ema(List<double> values, int period) {
  final out = List<double?>.filled(values.length, null);
  if (values.length < period) return out;
  final k = 2 / (period + 1);
  var prev = values.take(period).reduce((a, b) => a + b) / period;
  out[period - 1] = prev;
  for (var i = period; i < values.length; i++) {
    prev = values[i] * k + prev * (1 - k);
    out[i] = prev;
  }
  return out;
}

class BollingerBands {
  const BollingerBands(this.middle, this.upper, this.lower);
  final List<double?> middle;
  final List<double?> upper;
  final List<double?> lower;
}

/// Bollinger-Bänder: SMA ± k · Standardabweichung (Grundgesamtheit) über [period] Werte.
BollingerBands bollinger(List<double> values, {int period = 20, double k = 2}) {
  final mid = sma(values, period);
  final upper = List<double?>.filled(values.length, null);
  final lower = List<double?>.filled(values.length, null);
  for (var i = period - 1; i < values.length; i++) {
    final m = mid[i]!;
    var sq = 0.0;
    for (var j = i - period + 1; j <= i; j++) {
      sq += (values[j] - m) * (values[j] - m);
    }
    final sd = math.sqrt(sq / period);
    upper[i] = m + k * sd;
    lower[i] = m - k * sd;
  }
  return BollingerBands(mid, upper, lower);
}

/// Relative Stärke nach Wilder (0–100); erster Wert bei Index [period].
List<double?> rsi(List<double> values, {int period = 14}) {
  final out = List<double?>.filled(values.length, null);
  if (values.length <= period) return out;
  var gain = 0.0, loss = 0.0;
  for (var i = 1; i <= period; i++) {
    final d = values[i] - values[i - 1];
    if (d > 0) {
      gain += d;
    } else {
      loss -= d;
    }
  }
  gain /= period;
  loss /= period;
  double value(double g, double l) => l == 0 ? (g == 0 ? 50 : 100) : 100 - 100 / (1 + g / l);
  out[period] = value(gain, loss);
  for (var i = period + 1; i < values.length; i++) {
    final d = values[i] - values[i - 1];
    gain = (gain * (period - 1) + (d > 0 ? d : 0)) / period;
    loss = (loss * (period - 1) + (d < 0 ? -d : 0)) / period;
    out[i] = value(gain, loss);
  }
  return out;
}

enum CrossType { golden, death }

class Cross {
  const Cross(this.index, this.type);
  final int index;
  final CrossType type;

  @override
  bool operator ==(Object other) => other is Cross && other.index == index && other.type == type;
  @override
  int get hashCode => Object.hash(index, type);
  @override
  String toString() => 'Cross($index, ${type.name})';
}

/// Kreuzungen der schnellen über/unter die langsame Linie. Berühren ohne Seitenwechsel zählt nicht.
List<Cross> crosses(List<double?> fast, List<double?> slow) {
  final out = <Cross>[];
  int? lastSign;
  for (var i = 0; i < fast.length && i < slow.length; i++) {
    final f = fast[i], s = slow[i];
    if (f == null || s == null) continue;
    final sign = (f - s).sign.toInt();
    if (sign == 0) continue;
    if (lastSign != null && sign != lastSign) out.add(Cross(i, sign > 0 ? CrossType.golden : CrossType.death));
    lastSign = sign;
  }
  return out;
}
