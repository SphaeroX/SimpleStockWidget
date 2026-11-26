# Code-Styling und Formatierung

> Wann lesen: vor dem Schreiben, Ändern oder Formatieren von Code.

## Werkzeuge

- **Formatter Dart:** `dart format lib tests`
- **Linter Dart:** `flutter analyze` mit `flutter_lints`. Konfiguration in `analysis_options.yaml`; die Regeln dort sind maßgeblich. Zeilenbreite 120 (`formatter: page_width: 120`).
- **Kotlin:** Android-Studio-Standardformat (offizieller Kotlin-Style). Kein zusätzlicher Linter.
- **Swift:** Xcode-Standardformat. Kein zusätzlicher Linter.

## Verbindlich

- Vor jedem Commit: `dart format lib tests` und `flutter analyze` ohne Befund.
- Zahlen und Datumsangaben für die Anzeige nur über die zentrale Formatierungsfunktion (Locale `de_DE`) erzeugen, nie per String-Verkettung oder `toStringAsFixed` im UI-Code.
- Natives Widget-Code (Kotlin/Swift) enthält keine Rechen- oder Formatierungslogik für Kurse; es zeigt nur die Strings aus dem Payload an.
- Farben des Widgets als benannte Tokens (Hintergrund, Text, Positiv, Negativ, Neutral) jeweils für Hell und Dunkel definieren, nicht als verstreute Hex-Werte.

## Empfehlung

- Unveränderliche Modelle (`final`-Felder, `const`-Konstruktoren, `copyWith`).
- Kleine, reine Funktionen für Umrechnung und Formatierung – leicht testbar.

---
Pflege: Bei Änderungen an Stil- oder Tool-Regeln diese Datei sofort aktualisieren.
