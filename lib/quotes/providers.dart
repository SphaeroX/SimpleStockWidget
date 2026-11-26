import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../chart/price_history.dart';
import 'quote_provider.dart';
import 'yahoo/yahoo_quote_provider.dart';

final _yahoo = Provider<YahooQuoteProvider>((ref) => YahooQuoteProvider(http.Client()));

/// Zentrale Stelle für die Wahl der Kursquelle. In Tests per `overrideWithValue` ersetzbar.
final quoteProviderProvider = Provider<QuoteProvider>((ref) => ref.watch(_yahoo));

/// Quelle für Kursverläufe (Chart-Ansicht).
final priceHistoryProviderProvider = Provider<PriceHistoryProvider>((ref) => ref.watch(_yahoo));
