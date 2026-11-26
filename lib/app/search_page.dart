import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../quotes/providers.dart';
import '../quotes/quote.dart';
import '../quotes/quote_provider.dart';
import '../watchlist/watchlist_entry.dart';
import '../watchlist/watchlist_repository.dart';
import 'providers.dart';

String quoteTypeLabel(QuoteType t) => switch (t) {
  QuoteType.equity => 'Aktie',
  QuoteType.etf => 'ETF',
  QuoteType.marketIndex => 'Index',
  QuoteType.crypto => 'Krypto',
  QuoteType.currency => 'Währung',
  QuoteType.fund => 'Fonds',
  QuoteType.other => 'Sonstiges',
};

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  Timer? _debounce;
  bool _loading = false;
  String? _error;
  List<SymbolSearchResult> _results = const [];
  int _requestId = 0;

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(text));
  }

  Future<void> _search(String text) async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await ref.read(quoteProviderProvider).search(text);
      if (!mounted || id != _requestId) return;
      setState(() => _results = results);
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() => _error = 'Suche fehlgeschlagen: $e');
    } finally {
      if (mounted && id == _requestId) setState(() => _loading = false);
    }
  }

  Future<void> _add(SymbolSearchResult r) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(watchlistProvider.notifier).add(WatchlistEntry(symbol: r.symbol, name: r.name, type: r.type));
      messenger.showSnackBar(SnackBar(content: Text('${r.symbol} hinzugefügt')));
    } on DuplicateEntryException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name oder Ticker, z. B. „msci world“', border: InputBorder.none),
          onChanged: _onChanged,
          onSubmitted: _search,
        ),
      ),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) Padding(padding: const EdgeInsets.all(16), child: Text(_error!)),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(
                  title: Text(r.name),
                  subtitle: Text([r.symbol, quoteTypeLabel(r.type), if (r.exchange != null) r.exchange!].join(' · ')),
                  trailing: const Icon(Icons.add),
                  onTap: () => _add(r),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
