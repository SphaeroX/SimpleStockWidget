# Namenskonventionen und Best Practices

> Wann lesen: bei Benennung, Dateiorganisation, Commits und beim Anlegen neuer Komponenten.

## Namenskonventionen

- **Dart-Dateien und Ordner:** `snake_case.dart`.
- **Dart-Typen:** `UpperCamelCase`; Funktionen/Variablen `lowerCamelCase`; Riverpod-Provider enden auf `Provider` (z. B. `watchlistProvider`).
- **Kotlin/Swift:** Klassen `UpperCamelCase`, Dateien nach der Hauptklasse benannt (z. B. `StockGlanceWidget.kt`).
- **Widget-Speicher-Keys (`home_widget`):** zentral als Konstanten in einer Dart-Datei definiert und in Kotlin/Swift exakt gespiegelt; Präfix `ssw_` (z. B. `ssw_payload`). Änderungen an Keys immer auf allen Plattformen gleichzeitig.
- **Symbole:** immer im Yahoo-Format speichern (`NVDA`, `EVK.DE`, `IWDA.L`, `^GDAXI`, `BTC-EUR`).
- **Tests:** siehe `docs/testing.md`.

## Struktur und Organisation

- Feature-Ordner unter `lib/` (z. B. `quotes/`, `watchlist/`, `settings/`, `widget_sync/`), nicht nach technischen Schichten.
- Yahoo-spezifischer Code nur im Provider-Ordner; der Rest der App kennt nur `QuoteProvider` und `Quote`.
- Der Widget-Payload hat genau ein Dart-Modell mit JSON-Serialisierung; das Format ist der Vertrag zu Kotlin und Swift.

## Best Practices (projektspezifisch)

- Netzwerk- und Parsing-Fehler als eigene Fehlertypen modellieren; letzte gültige Widget-Daten nie bei Fehlern überschreiben.
- Gespeicherte JSON-Daten abwärtskompatibel lesen (fehlende neue Felder → Default), da es keine Migrationen gibt.
- Keine API-Keys oder Secrets im Repo. Sollte später ein Provider mit Key dazukommen: über `--dart-define` bzw. `.env` (ignoriert), Beispiel in `.env.example`.
- Neue Abhängigkeiten nur, wenn sie in `docs/architecture.md` begründet werden.

## Git

- Release: `version` in `pubspec.yaml` erhöhen (`x.y.z+build`, Build-Nummer immer hochzählen), committen, Tag `vX.Y.Z` pushen → CI baut und veröffentlicht das GitHub-Release.

- Commit-Nachrichten: Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`, `refactor:`).
- Arbeit an Roadmap-Tasks: ein oder mehrere Commits pro Task, Task-Nummer im Text (z. B. `feat: yahoo quote provider (Task_02)`).

---
Pflege: Bei neuen Konventionen oder Komponenten diese Datei sofort aktualisieren.
