import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../watchlist/watchlist_entry.dart';
import 'providers.dart';

/// Einstellungen eines einzelnen Watchlist-Eintrags.
class EntryDetailPage extends ConsumerStatefulWidget {
  const EntryDetailPage({super.key, required this.entry});
  final WatchlistEntry entry;

  @override
  ConsumerState<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends ConsumerState<EntryDetailPage> {
  late final TextEditingController _name = TextEditingController(text: widget.entry.displayName ?? '');
  late final WatchlistEntry _draft = widget.entry;

  Future<void> _save() async {
    final updated = _draft.withDisplayName(_name.text);
    await ref.read(watchlistProvider.notifier).replace(updated);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.symbol),
        actions: [TextButton(onPressed: _save, child: const Text('Speichern'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.entry.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            maxLength: WatchlistEntry.maxDisplayNameLength,
            inputFormatters: [LengthLimitingTextInputFormatter(WatchlistEntry.maxDisplayNameLength)],
            decoration: InputDecoration(
              labelText: 'Anzeigename im Widget',
              hintText: widget.entry.symbol,
              helperText: 'Leer lassen, um das Symbol anzuzeigen',
              border: const OutlineInputBorder(),
            ),
          ),
          ..._extraSettings(),
        ],
      ),
    );
  }

  /// Platz für Einstellungen weiterer Tasks (Währung, Anzeigemodus).
  List<Widget> _extraSettings() => [if (_draft.symbol.isEmpty) const SizedBox.shrink()];
}
