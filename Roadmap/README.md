# SimpleStockWidget – Roadmap

Projektübergreifendes Gedächtnis. Agenten lesen diese Datei vor jedem Task und aktualisieren sie, wenn sich etwas ergibt, das über einen einzelnen Task hinausgeht. Regeln für die Arbeit: [AGENTS.md](AGENTS.md).

## Projektziel

Ein schlankes Homescreen-Widget für Android (zuerst) und iOS (später), das eine selbst gewählte Liste von Aktien, ETFs, Indizes und Kryptowerten mit aktuellem Kurs und Tagesveränderung anzeigt – im Stil des Referenz-Screenshots (zweispaltige Liste, grün/rot), aber aufgeräumter und mit Reload-Button oben rechts.

**Was die Software tut:** In einer Flutter-Begleit-App sucht der Nutzer Werte (per Name oder Ticker) aus, vergibt optional eigene Anzeigenamen, sortiert sie und legt Anzeigewährung sowie Anzeigemodus der Tagesveränderung fest (Prozent, Betrag oder beides) – global und pro Wert überschreibbar. Die App lädt Kurse über eine austauschbare Provider-Schnittstelle (Standard: Yahoo Finance, inoffiziell) und schreibt fertig aufbereitete Daten in den gemeinsamen Widget-Speicher. Das native Widget zeigt Header mit „Letzter Abruf“, Reload-Button, die Liste und einen Hinweis bei geschlossener Börse oder veralteten Daten. Aktualisierung manuell per Button und automatisch im einstellbaren Intervall (15/30/60 Min).

**Zielgruppe:** Nur der Projektinhaber selbst (private Nutzung, Sideload). Keine Store-Veröffentlichung.

**Nicht-Ziele:** Store-Veröffentlichung, Charts/Kursverläufe, Portfolio/Stückzahlen, Kursalarme, Konten/Cloud-Sync, mehrere Widget-Instanzen mit unterschiedlichen Listen.

## Aktueller Status

Stand: 2026-11-26 – in Arbeit.

| Task | Titel | Status |
|---|---|---|
| 01 | Durchstich: App → Yahoo → Android-Widget | erledigt |
| 02 | Provider-Schnittstelle + Yahoo-Provider | erledigt |
| 03 | Watchlist: Suche, Hinzufügen, Entfernen, Sortieren | erledigt |
| 04 | Eigene Anzeigenamen | erledigt |
| 05 | Währungsumrechnung | erledigt |
| 06 | Anzeigemodus %, Betrag oder beides | erledigt |
| 07 | Android-Widget: finales Layout | erledigt |
| 08 | Android: Reload-Button im Widget | erledigt |
| 09 | Android: einstellbares Auto-Update | erledigt |
| 10 | Marktstatus und Fehlerzustände | offen |
| 11 | iOS: Widget-Grundgerüst | offen |
| 12 | iOS: Reload-Button und Refresh | offen |

Status ist `offen`, `läuft` (Datei trägt das Präfix `RUN_`) oder `erledigt` (Datei liegt in `Archiv/`). Die Tabelle wird beim Archivieren eines Tasks aktualisiert.

## Taskübergreifende Entwicklungsinfos

Globale Informationen, Architekturentscheidungen und Wissen, das für das gesamte Projekt gilt. Wird laufend ergänzt; jeden Eintrag mit dem Task kennzeichnen, aus dem er stammt.

- **Stack (Interview):** Flutter/Dart für App, Datenabruf und Aufbereitung; Widgets nativ: Android mit Kotlin + Jetpack Glance, iOS mit SwiftUI + WidgetKit. Brücke über das Paket `home_widget` (gemeinsamer Key-Value-Speicher, Widget-Update, interaktive Callbacks).
- **Datenfluss (Interview):** Kurse werden im Dart-Code geholt und fertig formatiert (Strings, Farbrichtung) in den Widget-Speicher geschrieben. Das native Widget rendert nur, es rechnet nicht. Reload und Auto-Update starten den Dart-Code im Hintergrund.
- **Datenquelle (Interview):** Austauschbar hinter einer `QuoteProvider`-Schnittstelle; Standard-Implementierung Yahoo Finance (inoffiziell, kein API-Key). Symbole im Yahoo-Format (`NVDA`, `EVK.DE`, `IWDA.L`, `^GDAXI`, `BTC-EUR`).
- **Einstellungen (Interview):** Anzeigewährung und Anzeigemodus (Prozent / Betrag / beides) global, pro Wert überschreibbar. Update-Intervall 15/30/60 Min einstellbar.
- **Plattform-Reihenfolge (Interview):** Android vollständig zuerst (Tasks 01–10), iOS danach (Tasks 11–12). In der Cloud-Umgebung kann nur Android gebaut werden; iOS braucht später Mac/Xcode oder CI.
- **Projekt-Setup (Init):** `AGENTS.md` + `docs/` im Root sind angelegt (Riverpod, `shared_preferences`, `http`, `flutter_lints`, `mocktail`). Cloud-Umgebung „SimpleStockWidget“ installiert Flutter 3.50.1 unter `/opt/flutter` und Android-SDK 36 unter `/opt/android-sdk` per Setup-Skript.
- **Yahoo-Endpunkt (Task_01):** `https://query1.finance.yahoo.com/v8/finance/chart/<SYMBOL>?range=1d&interval=1d` mit Browser-User-Agent, kein Crumb nötig. `v7/finance/quote` ist ohne Crumb gesperrt. Suche: `v1/finance/search?q=...&quotesCount=..&newsCount=0`. Kein `marketState` im Chart → aus `currentTradingPeriod` berechnen.
- **Widget-Vertrag (Task_01):** ein JSON-String unter Key `ssw_payload` (Modell `lib/widget_sync/widget_payload.dart`, gespiegelt in `android/.../widget/WidgetPayload.kt`).
- **Tests:** verbindlich unter `tests/`, Aufruf `flutter test tests/` (siehe `AGENTS.md`).

## Auffälligkeiten & Details

Dinge, die global noch zu beachten sind: Besonderheiten, bekannte Einschränkungen, kleinere Details. Wird laufend ergänzt.

- Yahoo Finance ist eine inoffizielle Schnittstelle (Endpunkte, ggf. Cookie/Crumb, Rate-Limits können sich ändern). Fehler müssen das Widget nie leer machen – letzte Daten bleiben stehen.
- Android erlaubt periodische Hintergrund-Jobs (WorkManager) frühestens alle 15 Minuten.
- Zahlenformat deutsch: Tausenderpunkt, Dezimalkomma (`50.182,95`).
- Erster Gradle-Build lädt viel aus Maven Central; bei HTTP 429 einfach erneut bauen.
- Glance-Widget visuell nur am echten Gerät prüfbar (kein Emulator in der Cloud).
- Laufend ergänzen.
