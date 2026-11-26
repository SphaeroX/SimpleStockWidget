import 'package:flutter_test/flutter_test.dart';
import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/watchlist/watchlist_entry.dart';
import 'package:simple_stock_widget/watchlist/watchlist_repository.dart';

import '../helpers/fakes.dart';

const nvda = WatchlistEntry(symbol: 'NVDA', name: 'NVIDIA Corporation', type: QuoteType.equity);
const tsla = WatchlistEntry(symbol: 'TSLA', name: 'Tesla', type: QuoteType.equity);
const btc = WatchlistEntry(symbol: 'BTC-EUR', name: 'Bitcoin EUR', type: QuoteType.crypto);

void main() {
  late InMemoryStore store;
  late WatchlistRepository repo;

  setUp(() {
    store = InMemoryStore();
    repo = WatchlistRepository(store);
  });

  test('erster Start liefert die Start-Watchlist', () async {
    final list = await repo.load();
    expect(list.map((e) => e.symbol), defaultWatchlist.map((e) => e.symbol));
  });

  test('geleerte Liste bleibt leer (keine erneute Start-Watchlist)', () async {
    await repo.save([]);
    expect(await repo.load(), isEmpty);
  });

  test('hinzufügen, entfernen, umsortieren und Persistenz über Neustart', () async {
    await repo.save([]);
    await repo.add(nvda);
    await repo.add(tsla);
    await repo.add(btc);
    await repo.reorder(0, 3); // NVDA ans Ende (ReorderableListView-Semantik)
    await repo.remove('TSLA');

    final reloaded = await WatchlistRepository(store).load();
    expect(reloaded.map((e) => e.symbol), ['BTC-EUR', 'NVDA']);
    expect(reloaded.last.name, 'NVIDIA Corporation');
    expect(reloaded.first.type, QuoteType.crypto);
  });

  test('Duplikat wird abgewiesen', () async {
    await repo.save([nvda]);
    expect(() => repo.add(nvda), throwsA(isA<DuplicateEntryException>()));
    expect((await repo.load()).length, 1);
  });

  test('kaputte gespeicherte Daten führen zur leeren Liste statt Absturz', () async {
    store.data[WatchlistRepository.storageKey] = '{kaputt';
    expect(await repo.load(), isEmpty);
  });
}
