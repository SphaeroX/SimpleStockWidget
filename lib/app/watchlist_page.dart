import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../settings/app_settings.dart';
import '../watchlist/watchlist_entry.dart';
import 'providers.dart';
import 'chart_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);
    final sortOrder = ref.watch(settingsProvider).value?.sortOrder ?? SortOrder.manual;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          PopupMenuButton<SortOrder>(
            tooltip: 'Sortierung im Widget',
            icon: const Icon(Icons.sort),
            initialValue: sortOrder,
            onSelected: (o) => ref.read(settingsProvider.notifier).change((s) => s.copyWith(sortOrder: o)),
            itemBuilder: (_) => [
              for (final o in SortOrder.values)
                CheckedPopupMenuItem(value: o, checked: o == sortOrder, child: Text(sortOrderLabel(o))),
            ],
          ),
          IconButton(
            tooltip: 'Einstellungen',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
          ),
          IconButton(
            tooltip: 'Widget aktualisieren',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          if (sortOrder != SortOrder.manual)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.secondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Widget sortiert: ${sortOrderLabel(sortOrder)} – die Reihenfolge hier gilt nur bei „Manuell“.',
              ),
            ),
          Expanded(
            child: watchlist.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Fehler: $e')),
              data: (entries) => entries.isEmpty
                  ? const Center(child: Text('Noch keine Werte. Tippe auf + zum Hinzufügen.'))
                  : ReorderableListView.builder(
                      itemCount: entries.length,
                      onReorderItem: (o, n) => ref.read(watchlistProvider.notifier).reorder(o, n > o ? n + 1 : n),
                      itemBuilder: (context, i) => _EntryTile(key: ValueKey(entries[i].symbol), entry: entries[i]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Wert hinzufügen',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SearchPage())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final payload = await ref.read(refreshServiceProvider).refresh();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            payload == null ? 'Aktualisierung läuft bereits' : 'Widget aktualisiert (${payload.updatedLabel})',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Aktualisierung fehlgeschlagen: $e')));
    }
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({super.key, required this.entry});
  final WatchlistEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismiss-${entry.symbol}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete),
      ),
      onDismissed: (_) => ref.read(watchlistProvider.notifier).remove(entry.symbol),
      child: ListTile(
        title: Text(entry.displayName ?? entry.name),
        subtitle: Text(entry.displayName == null ? entry.symbol : '${entry.symbol} · ${entry.name}'),
        trailing: const Icon(Icons.drag_handle),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ChartPage(entry: entry))),
      ),
    );
  }
}
