import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import '../settings/app_settings.dart';

/// Abstraktion über WorkManager, damit die Planungslogik ohne Plattform testbar ist.
abstract interface class BackgroundScheduler {
  Future<void> schedulePeriodic(String uniqueName, Duration frequency);
  Future<void> cancel(String uniqueName);
}

class WorkmanagerScheduler implements BackgroundScheduler {
  const WorkmanagerScheduler();

  @override
  Future<void> schedulePeriodic(String uniqueName, Duration frequency) => Workmanager().registerPeriodicTask(
    uniqueName,
    uniqueName,
    frequency: frequency,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );

  @override
  Future<void> cancel(String uniqueName) => Workmanager().cancelByUniqueName(uniqueName);
}

Future<bool> hasInstalledHomeWidgets() async {
  try {
    return (await HomeWidget.getInstalledWidgets()).isNotEmpty;
  } catch (_) {
    return true; // Im Zweifel planen; ohne Widget läuft der Job folgenlos.
  }
}

/// Plant das periodische Hintergrund-Update passend zu den Einstellungen.
class UpdateScheduler {
  UpdateScheduler(this._scheduler, {required this._hasWidget});

  /// Eindeutiger Name des Jobs; in Kotlin (`StockWidgetReceiver.onDisabled`) gespiegelt.
  static const uniqueName = 'ssw_periodic_refresh';

  final BackgroundScheduler _scheduler;
  final Future<bool> Function() _hasWidget;

  Future<void> apply(AppSettings settings) async {
    if (await _hasWidget()) {
      await _scheduler.schedulePeriodic(uniqueName, settings.updateInterval.duration);
    } else {
      await _scheduler.cancel(uniqueName);
    }
  }
}
