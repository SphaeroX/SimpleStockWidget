# Task_03: Watchlist: Suche, Hinzufügen, Entfernen, Sortieren

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_03.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Der Nutzer kann in der App Werte per Name oder Ticker suchen, zur Watchlist hinzufügen, entfernen und per Drag & Drop sortieren. Die Liste wird dauerhaft gespeichert, und das Widget zeigt genau diese Werte in dieser Reihenfolge.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_02 archiviert.
- **Relevantes Vorwissen:** `QuoteProvider` aus Task_02. Yahoo-Suche (z. B. `v1/finance/search?q=`).

## Umfang

**Gehört dazu:**

- Suche (mit Debounce) über den Provider, Ergebnisliste mit Name, Symbol, Typ (Aktie/ETF/Index/Krypto) und Börse
- Watchlist-Bildschirm: Hinzufügen, Entfernen (Wisch/Button), Sortieren (ReorderableListView)
- Persistenz der Watchlist (z. B. `shared_preferences` als JSON oder kleine lokale DB – Entscheidung in README)
- Nach Änderung: Kurse laden und Widget aktualisieren
- Sinnvolle Start-Watchlist bei leerer Liste (z. B. DAX, S&P 500, MSCI World ETF)

**Gehört nicht dazu:**

- Eigene Anzeigenamen (Task 04)
- Währung/Modus (Tasks 05–06)
- Finales Widget-Layout (Task 07) – das Widget aus Task_01 wird nur auf mehrere Zeilen erweitert

## Umsetzungsschritte

1. [x] Watchlist-Modell (`WatchlistEntry` mit Symbol, Name, Typ) und Repository mit Persistenz
2. [x] Suchfunktion im Provider implementieren (falls in Task_02 nur vorbereitet)
3. [x] Suchbildschirm mit Debounce, Lade- und Leerzustand
4. [x] Watchlist-Bildschirm mit Hinzufügen/Entfernen/Sortieren
5. [x] Duplikate verhindern
6. [x] Nach jeder Änderung Kurse holen und alle Einträge in den Widget-Speicher schreiben (vorläufiges Format, als JSON-Liste)
7. [x] Android-Widget aus Task_01 auf mehrere Zeilen erweitern (noch einfache Liste)

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Repository: Hinzufügen, Entfernen, Umsortieren, Persistenz über Neustart (Speicher gemockt)
- Duplikat wird abgewiesen
- Suche: Parsing einer Fixture-Antwort, Typ-Zuordnung
- Widget-Payload enthält Einträge in Watchlist-Reihenfolge
- Widget-Test (Flutter) für Watchlist-Bildschirm: Eintrag entfernen und umsortieren

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [x] `flutter test tests/` grün
- [x] Nach App-Neustart ist die Watchlist unverändert
- [x] Das Widget zeigt alle Watchlist-Werte in der gewählten Reihenfolge (manuell/Screenshot belegt)

## Offene Fragen / Annahmen

- Maximale Anzahl Werte: Annahme ca. 20; das Widget zeigt so viele, wie Platz ist (genaue Regel in Task 07).

## Notizen zu diesem Task

Taskspezifische Informationen während der Arbeit hier festhalten. Taskübergreifendes gehört in `Roadmap/README.md`.

## Abschluss-Checkliste

Reihenfolge und Details stehen in `AGENTS.md`, Abschnitt "Abschluss- und Archivierungs-Workflow".

- [x] Alle Akzeptanzkriterien erfüllt, Tests liegen permanent in `tests/` und laufen grün
- [x] Abschnitt "Erkenntnisse für Folge-Agenten" unten ausgefüllt
- [x] Folge-Tasks und `Roadmap/README.md` geprüft und bei Bedarf angepasst
- [x] Datei ohne `RUN_` nach `Roadmap/Archiv/` verschoben

## Erkenntnisse für Folge-Agenten

- **Umgesetzt (und Abweichungen vom Plan):** `lib/storage/key_value_store.dart` (`KeyValueStore` + `SharedPreferencesStore` auf Basis von `SharedPreferencesAsync`), `lib/watchlist/` (`WatchlistEntry`, `WatchlistRepository` mit Start-Watchlist DAX / S&P 500 / EUNL.DE, `DuplicateEntryException`, `replace`), `YahooQuoteProvider.search`, `lib/widget_sync/refresh_service.dart` (zentraler Refresh-Ablauf, schon jetzt die Funktion, die Task 08 vorsieht), `lib/format/quote_format.dart` (vorläufig, Task 06 baut aus), App: `lib/app/providers.dart` (Riverpod-Provider + `WatchlistNotifier`), `watchlist_page.dart` (Wischen zum Löschen, Drag zum Sortieren, Refresh-Button), `search_page.dart` (Debounce 400 ms). Das Android-Widget zeigte schon mehrere Zeilen (Schleife aus Task 01), keine Kotlin-Änderung nötig.
- **Learnings & Stolpersteine:** `ReorderableListView.onReorder` ist ab Flutter 3.41 veraltet → `onReorderItem` (Index bereits bereinigt); das Repository nutzt weiterhin die alte Semantik, die Seite rechnet um. `dart format` nutzt jetzt Zeilenbreite 120 (`analysis_options.yaml`).
- **Wichtige Entscheidungen und ihre Gründe:** `SharedPreferencesAsync` statt `SharedPreferences`, weil Hintergrund-Isolates (Reload-Button, WorkManager) sonst veraltete Cache-Werte lesen. Start-Watchlist nur, wenn der Speicher-Key fehlt; eine bewusst geleerte Liste bleibt leer. Widget zeigt bis Task 04 das Symbol als Namen.
- **Auswirkungen auf Folge-Tasks:** Task 04 erweitert `WatchlistEntry` um `displayName` und nutzt `WatchlistNotifier.replace`; Task 05/06 fügen weitere optionale Felder hinzu (JSON abwärtskompatibel lesen!). Formatierung und Richtung werden in `RefreshService.refresh` gebaut – Task 06 zieht das in eine eigene, getestete Payload-Builder-Funktion.
- **Hinweise zu Tests und Befehlen:** Gemeinsame Fakes in `tests/helpers/fakes.dart` (`InMemoryStore`, `InMemoryWidgetStorage`, `FakeQuoteProvider`). Widget-Tests überschreiben `keyValueStoreProvider`, `widgetStorageProvider`, `quoteProviderProvider`.
