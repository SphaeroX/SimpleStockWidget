import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simple_stock_widget/widget_sync/widget_keys.dart';
import 'package:simple_stock_widget/widget_sync/widget_storage.dart';
import 'package:simple_stock_widget/widget_sync/widget_payload.dart';
import 'package:simple_stock_widget/widget_sync/widget_sync.dart';

class MockStorage extends Mock implements WidgetStorage {}

void main() {
  test(
    'schreibt Payload als JSON unter ssw_payload und aktualisiert das Widget',
    () async {
      final storage = MockStorage();
      when(() => storage.saveString(any(), any())).thenAnswer((_) async {});
      when(() => storage.updateWidget()).thenAnswer((_) async {});

      final payload = WidgetPayload(
        updatedAt: DateTime.utc(2026, 11, 25, 21, 48),
        updatedLabel: '22:48 Mi.',
        rows: const [
          WidgetRow(
            name: 'NVDA',
            price: '149,30',
            change: '-6,08',
            direction: Direction.down,
          ),
        ],
      );
      await WidgetSync(storage).publish(payload);

      final captured =
          verify(() => storage.saveString(WidgetKeys.payload, captureAny()))
                  .captured
                  .single
              as String;
      final json = jsonDecode(captured) as Map<String, dynamic>;
      expect(json['updatedLabel'], '22:48 Mi.');
      expect((json['rows'] as List).single, {
        'name': 'NVDA',
        'price': '149,30',
        'change': '-6,08',
        'dir': 'down',
      });
      verify(() => storage.updateWidget()).called(1);
    },
  );
}
