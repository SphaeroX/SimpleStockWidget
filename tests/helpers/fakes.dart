import 'package:simple_stock_widget/quotes/quote.dart';
import 'package:simple_stock_widget/quotes/quote_provider.dart';
import 'package:simple_stock_widget/storage/key_value_store.dart';
import 'package:simple_stock_widget/widget_sync/widget_storage.dart';

class InMemoryStore implements KeyValueStore {
  final Map<String, String> data = {};
  @override
  Future<String?> getString(String key) async => data[key];
  @override
  Future<void> setString(String key, String value) async => data[key] = value;
}

class InMemoryWidgetStorage implements WidgetStorage {
  final Map<String, String> data = {};
  int updates = 0;
  @override
  Future<String?> readString(String key) async => data[key];
  @override
  Future<void> saveString(String key, String value) async => data[key] = value;
  @override
  Future<void> updateWidget() async => updates++;
}

class FakeQuoteProvider implements QuoteProvider {
  FakeQuoteProvider(this.quotes, {this.errors = const {}, this.searchResults = const []});
  final Map<String, Quote> quotes;
  final Map<String, QuoteException> errors;
  final List<SymbolSearchResult> searchResults;
  final List<List<String>> fetchCalls = [];

  @override
  Future<QuoteBatch> fetchQuotes(List<String> symbols) async {
    fetchCalls.add(symbols);
    return QuoteBatch(
      quotes: {
        for (final s in symbols)
          if (quotes[s] != null) s: quotes[s]!,
      },
      errors: {
        for (final s in symbols)
          if (errors[s] != null) s: errors[s]!,
      },
    );
  }

  @override
  Future<List<SymbolSearchResult>> search(String query) async => searchResults;
}
