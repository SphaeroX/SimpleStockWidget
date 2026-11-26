# Task_01: Durchstich: App → Yahoo → Android-Widget

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_01.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Ein lauffähiges Flutter-Projekt mit Android-Homescreen-Widget, das einen fest eingestellten Wert (NVDA) über Yahoo Finance lädt und Kurs plus Tagesveränderung anzeigt. Der Durchstich klärt früh, ob Flutter, `home_widget`, Glance und die Yahoo-Anbindung zusammenspielen und wie Tests unter `tests/` laufen.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Keine (erster Task).
- **Relevantes Vorwissen:** `Roadmap/README.md` (Stack, Datenfluss). Repo ist leer; es gibt noch kein Flutter-Projekt.

## Umfang

**Gehört dazu:**

- Flutter-Projekt `simple_stock_widget` im Repo-Root anlegen (Android + iOS-Plattformordner, iOS wird erst ab Task 11 bearbeitet)
- Paket `home_widget` und HTTP-Client (`http` oder `dio`) einbinden
- Minimaler Yahoo-Abruf für **ein** Symbol (Kurs, Vortagesschluss, Währung) – noch ohne ausgefeilte Schnittstelle
- Android-Widget (Kotlin + Jetpack Glance) mit einer Zeile: Name, Kurs, Veränderung
- App-Startbildschirm mit Button „Aktualisieren“, der lädt und das Widget updated
- Testing-Setup: `flutter test tests/` lauffähig, `.gitignore` für Flutter

**Gehört nicht dazu:**

- Watchlist, Suche, Einstellungen (Tasks 03–06)
- Finales Layout (Task 07)
- Reload-Button im Widget und Hintergrund-Updates (Tasks 08–09)
- iOS-Widget (Task 11)

## Umsetzungsschritte

1. [ ] Flutter-Projekt anlegen, Flutter-Version in `Roadmap/README.md` festhalten
2. [ ] `.gitignore` für Flutter/Android/iOS ergänzen
3. [ ] Yahoo-Endpunkt recherchieren und testen (z. B. `query1.finance.yahoo.com/v8/finance/chart/<SYMBOL>` bzw. `v7/finance/quote`); Ergebnis inkl. evtl. Cookie/Crumb-Bedarf dokumentieren
4. [ ] Dart-Funktion: Symbol → Kurs, Vortagesschluss, Veränderung, Währung; JSON-Parsing in eigener, testbarer Funktion
5. [ ] `home_widget` einrichten: Daten speichern, `updateWidget` auslösen
6. [ ] Glance-Widget anlegen (`GlanceAppWidget` + Receiver, Manifest, Widget-Info-XML), liest Werte aus dem home_widget-Speicher
7. [ ] Test-Setup so einrichten, dass `flutter test tests/` die Tests findet
8. [ ] APK bauen (`flutter build apk --debug`) und – falls Gerät/Emulator verfügbar – Widget prüfen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- JSON-Parsing einer gespeicherten Yahoo-Beispielantwort (Fixture unter `tests/fixtures/`) → korrekte Werte für Kurs, Vortagesschluss, Veränderung
- Fehlerfall: kaputtes/leeres JSON führt zu definiertem Fehler, nicht zu Absturz
- Schreiben in den Widget-Speicher (home_widget gemockt): richtige Keys/Werte

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [ ] `flutter test tests/` läuft grün mit mindestens den drei oben genannten Tests
- [ ] `flutter analyze` ohne Fehler
- [ ] `flutter build apk --debug` erfolgreich
- [ ] Widget zeigt nach Tippen auf „Aktualisieren“ in der App NVDA mit Kurs und Veränderung (Screenshot oder manuelle Prüfung in den Notizen belegt; ohne Gerät: als offen vermerken)

## Offene Fragen / Annahmen

- Exakter Yahoo-Endpunkt und ob Cookie/Crumb nötig ist – in diesem Task klären und in README festhalten.
- Annahme: Ein Android-Emulator ist in der Cloud-Umgebung evtl. nicht verfügbar; dann wird die visuelle Prüfung vom Nutzer nachgeholt.

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
