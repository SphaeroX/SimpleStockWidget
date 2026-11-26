import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/watchlist_page.dart';

void main() {
  runApp(const ProviderScope(child: SimpleStockApp()));
}

class SimpleStockApp extends StatelessWidget {
  const SimpleStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleStock',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: Colors.green, brightness: Brightness.dark, useMaterial3: true),
      home: const WatchlistPage(),
    );
  }
}
