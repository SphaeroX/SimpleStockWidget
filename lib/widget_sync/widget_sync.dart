import 'dart:convert';

import 'widget_keys.dart';
import 'widget_payload.dart';
import 'widget_storage.dart';

class WidgetSync {
  const WidgetSync(this._storage);
  final WidgetStorage _storage;

  Future<void> publish(WidgetPayload payload) async {
    await _storage.saveString(WidgetKeys.payload, jsonEncode(payload.toJson()));
    await _storage.updateWidget();
  }
}
