import 'package:home_widget/home_widget.dart';

/// Abstraktion über home_widget, damit Tests ohne Plattform-Kanal laufen.
abstract interface class WidgetStorage {
  Future<void> saveString(String key, String value);
  Future<String?> readString(String key);
  Future<void> updateWidget();
}

class HomeWidgetStorage implements WidgetStorage {
  const HomeWidgetStorage();

  static const androidWidgetName = 'StockWidgetReceiver';
  static const iOSWidgetName = 'StockWidget';

  @override
  Future<void> saveString(String key, String value) async {
    await HomeWidget.saveWidgetData<String>(key, value);
  }

  @override
  Future<String?> readString(String key) => HomeWidget.getWidgetData<String>(key);

  @override
  Future<void> updateWidget() async {
    await HomeWidget.updateWidget(
      qualifiedAndroidName: 'de.sphaerox.simple_stock_widget.widget.$androidWidgetName',
      iOSName: iOSWidgetName,
    );
  }
}
