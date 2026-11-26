import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'quote_provider.dart';
import 'yahoo/yahoo_quote_provider.dart';

/// Zentrale Stelle für die Wahl der Kursquelle. In Tests per `overrideWithValue` ersetzbar.
final quoteProviderProvider = Provider<QuoteProvider>((ref) => YahooQuoteProvider(http.Client()));
