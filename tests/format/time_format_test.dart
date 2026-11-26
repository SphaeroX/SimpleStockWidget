import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/format/time_format.dart';

void main() {
  test('Header-Zeitformat „22:48 Mi.“', () {
    expect(formatUpdatedLabel(DateTime(2026, 11, 25, 22, 48)), '22:48 Mi.');
  });
  test('alle Wochentage, führende Null bei Stunde', () {
    final labels = [for (var d = 23; d <= 29; d++) formatUpdatedLabel(DateTime(2026, 11, d, 7, 5))];
    expect(labels, ['07:05 Mo.', '07:05 Di.', '07:05 Mi.', '07:05 Do.', '07:05 Fr.', '07:05 Sa.', '07:05 So.']);
  });
}
