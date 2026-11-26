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
}
