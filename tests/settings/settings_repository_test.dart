import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/currency/currency.dart';
import 'package:simple_stock_widget/settings/app_settings.dart';
import 'package:simple_stock_widget/settings/settings_repository.dart';

import '../helpers/fakes.dart';

void main() {
  test('Standard: Originalwährung', () async {
    final s = await SettingsRepository(InMemoryStore()).load();
    expect(s.displayCurrency, originalCurrency);
  });

  test('Persistenz der Anzeigewährung', () async {
    final store = InMemoryStore();
    await SettingsRepository(store).save(const AppSettings(displayCurrency: 'EUR'));
    expect((await SettingsRepository(store).load()).displayCurrency, 'EUR');
  });

  test('kaputte Daten → Standard', () async {
    final store = InMemoryStore()..data[SettingsRepository.storageKey] = 'x';
    expect((await SettingsRepository(store).load()).displayCurrency, originalCurrency);
  });

  test('Anzeigemodus: Standard Prozent, Persistenz', () async {
    final store = InMemoryStore();
    expect((await SettingsRepository(store).load()).changeMode, ChangeMode.percent);
    await SettingsRepository(store).save(const AppSettings(changeMode: ChangeMode.both));
    expect((await SettingsRepository(store).load()).changeMode, ChangeMode.both);
  });

  test('alte Einstellungen ohne changeMode werden geladen', () async {
    final store = InMemoryStore()..data[SettingsRepository.storageKey] = '{"displayCurrency":"EUR"}';
    final s = await SettingsRepository(store).load();
    expect(s.displayCurrency, 'EUR');
    expect(s.changeMode, ChangeMode.percent);
  });

  test('Update-Intervall: Standard 30 Min, Persistenz', () async {
    final store = InMemoryStore();
    expect((await SettingsRepository(store).load()).updateInterval, UpdateInterval.min30);
    await SettingsRepository(store).save(const AppSettings(updateInterval: UpdateInterval.min15));
    final loaded = await SettingsRepository(store).load();
    expect(loaded.updateInterval, UpdateInterval.min15);
    expect(loaded.updateInterval.duration, const Duration(minutes: 15));
  });
}
