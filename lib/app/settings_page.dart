import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../currency/currency.dart';
import 'providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownMenu<String>(
              key: const Key('global-currency'),
              label: const Text('Anzeigewährung'),
              expandedInsets: EdgeInsets.zero,
              initialSelection: s.displayCurrency,
              onSelected: (v) => v == null ? null : notifier.change((x) => x.copyWith(displayCurrency: v)),
              dropdownMenuEntries: [
                for (final c in [originalCurrency, ...selectableCurrencies])
                  DropdownMenuEntry(value: c, label: currencyLabel(c)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Kurs und Betragsveränderung werden mit dem aktuellen Wechselkurs umgerechnet.'),
          ],
        ),
      ),
    );
  }
}
