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
  - `fl_chart` – Linien-Charts der Chart-Ansicht (reines Dart, keine Plattform-Abhängigkeit, unterstützt Lücken, Bänder und Marker).

## Architektur

- **Dart ist die einzige Logik-Schicht.** Abruf, Währungsumrechnung, Modus-Auswahl und Formatierung passieren in Dart. Das Ergebnis wird als fertig formatierter Payload (Strings + Richtung hoch/runter/neutral + Status-Flags) über `home_widget` gespeichert. Native Widgets rendern nur und rechnen nicht – so bleibt die Logik einmal vorhanden und mit `flutter_test` testbar.
- **Yahoo-Endpunkt:** `v8/finance/chart/<SYMBOL>?range=1d&interval=1d` (ohne Crumb), Suche `v1/finance/search`.
- **Datenquelle austauschbar:** Alle Kursdaten laufen über die Schnittstelle `QuoteProvider`. Standard-Implementierung ist Yahoo Finance (inoffiziell, kein API-Key). Yahoo-spezifische Felder verlassen den Provider nie.
- **Ein Refresh-Ablauf:** Eine zentrale Funktion (Watchlist laden → Kurse + FX holen → formatieren → speichern → Widget aktualisieren) wird von App, Reload-Button (Hintergrund-Callback) und WorkManager gleichermaßen aufgerufen.
- **Einstellungen:** Anzeigewährung und Anzeigemodus global, pro Watchlist-Eintrag überschreibbar (Override > global > Original). Sortierung im Widget (`SortOrder`) nur global; sortiert wird in Dart (`sortEntries` in `lib/widget_sync/payload_builder.dart`) vor dem Formatieren, Gewinner/Verlierer nach Prozent, Einträge ohne Kurs ans Ende.
- **Chart-Ansicht:** Antippen eines Werts (App-Liste oder Widget-Zeile über Deep-Link `simplestock://chart?symbol=…`) öffnet `lib/app/chart_page.dart`. Verlauf über `PriceHistoryProvider` (Yahoo `v8/finance/chart` mit `period1/period2` bzw. `range=max`, Intervalle 1h/1d/1wk). `HistoryRequest` lädt mit Vorlauf (Stunden 45 Tage, Tage 300 Tage, Wochen 1500 Tage), damit MA200 & Co. am linken Rand gültig sind. Indikatoren (`lib/chart/indicators.dart`: SMA, EMA, Bollinger, RSI nach Wilder, Kreuzungen) und Zuschnitt (`ChartData`) sind reines Dart. Zeitraum/Werkzeuge in `AppSettings.chart`. Kurse im Chart in Originalwährung (Pence → Pfund normalisiert).
- **Fehlerverhalten:** Ein fehlgeschlagener Abruf überschreibt nie die letzten gültigen Daten; das Widget zeigt dann einen Hinweis.

## Umgebung

- Flutter-SDK liegt in der Cloud-Umgebung unter `/opt/flutter` (`export PATH=/opt/flutter/bin:$PATH`). Lokal: Flutter stable im PATH.
- Paketverwaltung ausschließlich mit `flutter pub` (`flutter pub add <paket>`), keine manuellen Versionsänderungen ohne `flutter pub get`.
- **Android-SDK:** In der Cloud-Umgebung „SimpleStockWidget“ unter `/opt/android-sdk` (Platform 36, Build-Tools 36.0.0), installiert per Setup-Skript der Umgebung; Java 21 ist vorhanden. `dl.google.com` ist dort freigegeben. Ein Emulator ist nicht verfügbar – visuelle Prüfungen am Gerät macht der Nutzer.
- **iOS:** Build nur auf macOS mit Xcode oder über macOS-CI.
- **CI/Release (GitHub Actions, `.github/workflows/android.yml`):** Bei Push auf `main`, Pull Requests und Tags `v*`: Format, Analyse, Dart- und Kotlin-Tests, Release-APKs (arm64, armv7, universal) als Artefakt. GitHub-Release mit den APKs bei Tag `v*` oder bei Push auf `main`, wenn für die Version aus `pubspec.yaml` noch kein Tag existiert.
- **Signierung:** `android/app/build.gradle.kts` nutzt einen Release-Schlüssel, wenn `SSW_KEYSTORE_PATH` (+ `SSW_KEYSTORE_PASSWORD`, `SSW_KEY_ALIAS`, `SSW_KEY_PASSWORD`) gesetzt ist; in CI aus den Secrets `SSW_KEYSTORE_BASE64`, `SSW_KEYSTORE_PASSWORD`, `SSW_KEY_ALIAS`, `SSW_KEY_PASSWORD`. Ohne sie: Debug-Schlüssel (jeder CI-Lauf anders → Updates über alte Versionen schlagen fehl).

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
