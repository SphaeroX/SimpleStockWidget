import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/widget_sync/background.dart';
import 'package:simple_stock_widget/widget_sync/update_scheduler.dart';

void main() {
  test('Reload-URI passt zur Kotlin-Seite', () {
    expect(reloadUri.toString(), 'simplestock://reload');
  });

  test('Schedule-URI und Job-Name passen zur Kotlin-Seite', () {
    expect(scheduleUri.toString(), 'simplestock://schedule');
    expect(UpdateScheduler.uniqueName, 'ssw_periodic_refresh');
  });
}
