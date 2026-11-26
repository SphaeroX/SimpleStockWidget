import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/settings/app_settings.dart';
import 'package:simple_stock_widget/widget_sync/update_scheduler.dart';

class FakeScheduler implements BackgroundScheduler {
  final calls = <String>[];
  @override
  Future<void> schedulePeriodic(String uniqueName, Duration frequency) async =>
      calls.add('schedule $uniqueName ${frequency.inMinutes}');
  @override
  Future<void> cancel(String uniqueName) async => calls.add('cancel $uniqueName');
}

void main() {
  late FakeScheduler scheduler;
  setUp(() => scheduler = FakeScheduler());

  test('mit Widget: Job im eingestellten Intervall', () async {
    await UpdateScheduler(scheduler, hasWidget: () async => true).apply(const AppSettings());
    expect(scheduler.calls, ['schedule ${UpdateScheduler.uniqueName} 30']);
  });

  test('Intervallwechsel plant mit neuem Intervall neu', () async {
    final s = UpdateScheduler(scheduler, hasWidget: () async => true);
    await s.apply(const AppSettings(updateInterval: UpdateInterval.min15));
    await s.apply(const AppSettings(updateInterval: UpdateInterval.min60));
    expect(scheduler.calls.last, 'schedule ${UpdateScheduler.uniqueName} 60');
  });

  test('ohne Widget: kein Job, bestehender wird entfernt', () async {
    await UpdateScheduler(scheduler, hasWidget: () async => false).apply(const AppSettings());
    expect(scheduler.calls, ['cancel ${UpdateScheduler.uniqueName}']);
  });
}
