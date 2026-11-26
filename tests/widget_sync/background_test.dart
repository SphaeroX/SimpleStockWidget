import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/widget_sync/background.dart';

void main() {
  test('Reload-URI passt zur Kotlin-Seite', () {
    expect(reloadUri.toString(), 'simplestock://reload');
  });
}
