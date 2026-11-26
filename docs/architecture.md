# Tech-Stack und Architektur

> Wann lesen: vor Strukturänderungen, neuen Komponenten, neuen Abhängigkeiten oder Arbeit an nativem Widget-Code.

## Tech-Stack

- **Sprache/Runtime:** Dart mit Flutter stable (eingerichtet: Flutter 3.50.1 / Dart 3.14.0). SDK-Untergrenze siehe `pubspec.yaml`. UI-Import: `package:material_ui/material_ui.dart` (neue entkoppelte Material-Bibliothek).
- **Android-Widget:** Kotlin + Jetpack Glance.
- **iOS-Widget (später):** SwiftUI + WidgetKit, Mindestversion iOS 17 (für interaktive Buttons via AppIntent).
- **Tragende Pakete:**
  - `home_widget` – Brücke App ↔ natives Widget (gemeinsamer Speicher, Widget-Update, interaktive Callbacks).
  - `flutter_riverpod` – State-Management und Dependency-Injection; erlaubt in Tests das Überschreiben von Providern mit Fakes.
  - `http` – HTTP-Client; in Tests `MockClient` aus `package:http/testing.dart`.
  - `shared_preferences` – Persistenz von Watchlist und Einstellungen als JSON. Reicht für ~20 Einträge, kein Schema-Aufwand.
  - `workmanager` – periodisches Hintergrund-Update auf Android.
  - `intl` – deutsche Zahlen- und Datumsformatierung.

## Architektur

- **Dart ist die einzige Logik-Schicht.** Abruf, Währungsumrechnung, Modus-Auswahl und Formatierung passieren in Dart. Das Ergebnis wird als fertig formatierter Payload (Strings + Richtung hoch/runter/neutral + Status-Flags) über `home_widget` gespeichert. Native Widgets rendern nur und rechnen nicht – so bleibt die Logik einmal vorhanden und mit `flutter_test` testbar.
- **Yahoo-Endpunkt:** `v8/finance/chart/<SYMBOL>?range=1d&interval=1d` (ohne Crumb), Suche `v1/finance/search`.
- **Datenquelle austauschbar:** Alle Kursdaten laufen über die Schnittstelle `QuoteProvider`. Standard-Implementierung ist Yahoo Finance (inoffiziell, kein API-Key). Yahoo-spezifische Felder verlassen den Provider nie.
- **Ein Refresh-Ablauf:** Eine zentrale Funktion (Watchlist laden → Kurse + FX holen → formatieren → speichern → Widget aktualisieren) wird von App, Reload-Button (Hintergrund-Callback) und WorkManager gleichermaßen aufgerufen.
- **Einstellungen:** Anzeigewährung und Anzeigemodus global, pro Watchlist-Eintrag überschreibbar (Override > global > Original).
- **Fehlerverhalten:** Ein fehlgeschlagener Abruf überschreibt nie die letzten gültigen Daten; das Widget zeigt dann einen Hinweis.

## Umgebung

- Flutter-SDK liegt in der Cloud-Umgebung unter `/opt/flutter` (`export PATH=/opt/flutter/bin:$PATH`). Lokal: Flutter stable im PATH.
- Paketverwaltung ausschließlich mit `flutter pub` (`flutter pub add <paket>`), keine manuellen Versionsänderungen ohne `flutter pub get`.
- **Android-SDK:** In der Cloud-Umgebung „SimpleStockWidget“ unter `/opt/android-sdk` (Platform 36, Build-Tools 36.0.0), installiert per Setup-Skript der Umgebung; Java 21 ist vorhanden. `dl.google.com` ist dort freigegeben. Ein Emulator ist nicht verfügbar – visuelle Prüfungen am Gerät macht der Nutzer.
- **iOS:** Build nur auf macOS mit Xcode oder über macOS-CI.

## Projekt-Erzeugung

Ausgeführt in Task 01:

```bash
flutter create --org de.sphaerox --project-name simple_stock_widget --platforms android,ios .
```

Danach die von `flutter create` erzeugte Datei `test/widget_test.dart` entfernen und Tests ausschließlich unter `tests/` anlegen (siehe `docs/testing.md`).

## Offene Entscheidungen

- iOS-Hintergrund-Refresh: Dart über `home_widget`-Interaktivität oder nativer Swift-Abruf – Klärung in Task 11.

---
Pflege: Bei Änderungen an Stack oder Architektur diese Datei sofort aktualisieren.
