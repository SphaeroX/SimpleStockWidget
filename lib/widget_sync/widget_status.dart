import '../quotes/quote_provider.dart';
import '../settings/app_settings.dart';

/// Zeitpunkt, ab dem Daten als veraltet gelten: älter als 2× Update-Intervall.
DateTime staleAt(DateTime updatedAt, UpdateInterval interval) => updatedAt.add(interval.duration * 2);

bool isStale({required DateTime updatedAt, required DateTime now, required UpdateInterval interval}) =>
    now.isAfter(staleAt(updatedAt, interval));

String errorLabelFor(Object error) => switch (error) {
  NetworkQuoteException() => 'Offline',
  RateLimitException() => 'Zu viele Anfragen',
  _ => 'Fehler',
};

String withStand(String prefix, String? updatedLabel) =>
    updatedLabel == null || updatedLabel.isEmpty ? prefix : '$prefix · Stand $updatedLabel';
