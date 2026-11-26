import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'quotes/yahoo/yahoo_chart_parser.dart';
import 'widget_sync/widget_payload.dart';
import 'widget_sync/widget_storage.dart';
import 'widget_sync/widget_sync.dart';

void main() {
  runApp(const SimpleStockApp());
}

class SimpleStockApp extends StatelessWidget {
  const SimpleStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleStockWidget',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'Noch nicht geladen';

  Future<void> _refresh() async {
    setState(() => _status = 'Lade …');
    try {
      final q = await fetchYahooChartQuote(http.Client(), 'NVDA');
      final f = NumberFormat('#,##0.00', 'de_DE');
      final now = DateTime.now();
      await const WidgetSync(HomeWidgetStorage()).publish(WidgetPayload(
        updatedAt: now,
        updatedLabel: DateFormat('HH:mm').format(now),
        rows: [
          WidgetRow(
            name: q.symbol,
            price: f.format(q.price),
            change: f.format(q.change),
            direction: q.change > 0 ? Direction.up : (q.change < 0 ? Direction.down : Direction.neutral),
          ),
        ],
      ));
      setState(() => _status = '${q.symbol}: ${f.format(q.price)} ${q.currency}');
    } catch (e) {
      setState(() => _status = 'Fehler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SimpleStockWidget')),
      body: Center(child: Text(_status)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refresh,
        icon: const Icon(Icons.refresh),
        label: const Text('Aktualisieren'),
      ),
    );
  }
}
