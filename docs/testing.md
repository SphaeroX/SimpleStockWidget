# Testing-Strategie

> Wann lesen: bevor du Tests schreibst oder die Test-Konfiguration änderst.

## Testing-Suite

- **`flutter_test` + `mocktail`** für den gesamten Dart-Code (Unit- und Widget-Tests). Offizieller Flutter-Standard; `mocktail` braucht keine Codegenerierung.
- **Netzwerk:** `MockClient` aus `package:http/testing.dart` mit gespeicherten Yahoo-Antworten (Fixtures).
- **Native Logik:** Kotlin mit JUnit (Android), Swift mit XCTest (iOS) – nur für echte Logik wie Spaltenaufteilung oder Payload-Decoding, nicht für reines Layout.

## TDD-Ablauf (verbindlich)

1. Red: Test schreiben, ausführen, Fehlschlag prüfen.
2. Green: minimalen Code schreiben, bis der Test besteht.
3. Refactor: aufräumen, Tests bleiben grün.

## Befehle

```bash
export PATH=/opt/flutter/bin:$PATH          # nur Cloud-Umgebung
flutter test tests/                          # alle Dart-Tests
flutter test tests/quotes/yahoo_provider_test.dart        # eine Datei
flutter test tests/quotes/yahoo_provider_test.dart --plain-name "parst Kurs"   # ein Test
flutter test tests/ --coverage               # mit Coverage (coverage/lcov.info)
flutter analyze                              # statische Analyse
```

Wichtig: Immer `tests/` als Pfad angeben. Flutter sucht ohne Pfad nur in `test/`, das in diesem Projekt nicht verwendet wird.

## Welche Tests wann ausführen

- Änderung in `lib/<bereich>/` → zuerst `flutter test tests/<bereich>/`.
- Änderung an gemeinsam genutztem Code (Modelle, Formatierung, Refresh-Ablauf, Widget-Payload) → `flutter test tests/` komplett.
- Änderung an Kotlin-Widget-Logik → Kotlin-Unit-Tests (Befehl wird in Task 07 ergänzt).

## Fertig-Kriterien

Eine Aufgabe ist fertig, wenn mechanisch prüfbar gilt:

1. `flutter test tests/` läuft grün.
2. `flutter analyze` meldet keine Fehler oder Warnungen; `dart format --output=none --set-exit-if-changed lib tests` meldet keine Änderungen.
3. Kein bestehender Test wurde geändert, gelöscht oder abgeschwächt (außer ausdrücklich beauftragt).

## Harte Regeln

- Bei fehlschlagendem Test wird die Implementierung korrigiert, nicht der Test.
- Höchstens 3 Reparaturversuche pro fehlschlagendem Test; danach anhalten und berichten.
- Muss ein bestehender Test geändert werden: Grund nennen und Freigabe abwarten.
- Tests machen nie echte Netzwerkaufrufe. Ausnahme: Live-Tests gegen Yahoo unter `tests/integration/` mit `@Tags(['live'])`; `dart_test.yaml` überspringt sie im Standardlauf. Manuell: `flutter test tests/integration --run-skipped --tags live` (benötigt freigegebene Yahoo-Hosts).

## Teststruktur

- **Ablage:** `tests/` spiegelt `lib/`: `lib/quotes/yahoo_provider.dart` → `tests/quotes/yahoo_provider_test.dart`.
- **Dateinamen:** `<name>_test.dart`.
- **Fixtures:** `tests/fixtures/<quelle>_<fall>.json` (z. B. `yahoo_quote_nvda.json`), geladen per `File('tests/fixtures/...')`.
- **Native Tests:** `tests/android/` (Kotlin, im Gradle-Testsourceset eingebunden), `tests/ios/` (Swift, im Xcode-Testtarget eingebunden).
- **UI des Widgets:** visuelle Prüfung per Screenshot; Ergebnis in der Task-Datei notieren.

---
Pflege: Bei Änderungen an Testing-Suite oder -Strategie diese Datei sofort aktualisieren.
