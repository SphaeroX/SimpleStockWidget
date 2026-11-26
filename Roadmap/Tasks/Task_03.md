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

1. [ ] Watchlist-Modell (`WatchlistEntry` mit Symbol, Name, Typ) und Repository mit Persistenz
2. [ ] Suchfunktion im Provider implementieren (falls in Task_02 nur vorbereitet)
3. [ ] Suchbildschirm mit Debounce, Lade- und Leerzustand
4. [ ] Watchlist-Bildschirm mit Hinzufügen/Entfernen/Sortieren
5. [ ] Duplikate verhindern
6. [ ] Nach jeder Änderung Kurse holen und alle Einträge in den Widget-Speicher schreiben (vorläufiges Format, als JSON-Liste)
7. [ ] Android-Widget aus Task_01 auf mehrere Zeilen erweitern (noch einfache Liste)

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

- [ ] `flutter test tests/` grün
- [ ] Nach App-Neustart ist die Watchlist unverändert
- [ ] Das Widget zeigt alle Watchlist-Werte in der gewählten Reihenfolge (manuell/Screenshot belegt)

## Offene Fragen / Annahmen

- Maximale Anzahl Werte: Annahme ca. 20; das Widget zeigt so viele, wie Platz ist (genaue Regel in Task 07).

## Notizen zu diesem Task

Taskspezifische Informationen während der Arbeit hier festhalten. Taskübergreifendes gehört in `Roadmap/README.md`.

## Abschluss-Checkliste

Reihenfolge und Details stehen in `AGENTS.md`, Abschnitt "Abschluss- und Archivierungs-Workflow".

- [ ] Alle Akzeptanzkriterien erfüllt, Tests liegen permanent in `tests/` und laufen grün
- [ ] Abschnitt "Erkenntnisse für Folge-Agenten" unten ausgefüllt
- [ ] Folge-Tasks und `Roadmap/README.md` geprüft und bei Bedarf angepasst
- [ ] Datei ohne `RUN_` nach `Roadmap/Archiv/` verschoben

## Erkenntnisse für Folge-Agenten

<!-- ERKENNTNISSE-OFFEN: Vor der Archivierung ausfüllen und diese Zeile löschen. -->

Vor der Archivierung vom Agenten auszufüllen. Schreibe so, dass ein Agent, der diesen Task nie gesehen hat, davon bei späteren Tasks profitiert:

- **Umgesetzt (und Abweichungen vom Plan):**
- **Learnings & Stolpersteine:**
- **Wichtige Entscheidungen und ihre Gründe:**
- **Auswirkungen auf Folge-Tasks:**
- **Hinweise zu Tests und Befehlen:**
