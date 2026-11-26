import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import 'app/chart_page.dart';
import 'app/deep_link.dart';
import 'app/providers.dart';
import 'app/watchlist_page.dart';
import 'watchlist/watchlist_entry.dart';
import 'widget_sync/background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerInteractivityCallback(widgetInteractivityCallback);
  await Workmanager().initialize(workmanagerDispatcher);
  applyUpdateSchedule().ignore();
  runApp(const ProviderScope(child: SimpleStockApp()));
}

/// [initialLink] und [links] liefern Widget-Klicks (Standard: home_widget); in Tests ersetzbar.
class SimpleStockApp extends ConsumerStatefulWidget {
  const SimpleStockApp({super.key, this.initialLink = HomeWidget.initiallyLaunchedFromHomeWidget, this.links});

  final Future<Uri?> Function() initialLink;
  final Stream<Uri?>? links;

  @override
  ConsumerState<SimpleStockApp> createState() => _SimpleStockAppState();
}

class _SimpleStockAppState extends ConsumerState<SimpleStockApp> {
  final _navigator = GlobalKey<NavigatorState>();
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    widget.initialLink().then(_open, onError: (_) {});
    _sub = (widget.links ?? HomeWidget.widgetClicked).listen(_open, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _open(Uri? uri) async {
    final symbol = chartSymbolFromUri(uri);
    if (symbol == null) return;
    final entries = await ref.read(watchlistProvider.future);
    final entry = entries.where((e) => e.symbol == symbol).firstOrNull ?? WatchlistEntry(symbol: symbol, name: symbol);
    _navigator.currentState?.push(MaterialPageRoute<void>(builder: (_) => ChartPage(entry: entry)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'SimpleStock',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: Colors.green, brightness: Brightness.dark, useMaterial3: true),
      home: const WatchlistPage(),
    );
  }
}
