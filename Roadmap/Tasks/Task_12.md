# Task_12: iOS: Reload-Button und Refresh

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_12.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Auf iOS lädt der Reload-Button im Widget die Kurse neu (AppIntent, iOS 17+), und das Widget fordert im eingestellten Intervall neue Daten an. Damit sind beide Plattformen funktional gleich.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_11 archiviert.
- **Relevantes Vorwissen:** Ergebnis der offenen Frage aus Task_11 (Dart im Hintergrund vs. nativer Swift-Abruf). `refreshWidgetData()` aus Task_08.

## Umfang

**Gehört dazu:**

- Reload-Button als `Button(intent:)` mit AppIntent
- Ausführung des Refresh: über `home_widget`-Interaktivität (Dart) oder nativen Swift-Abruf – je nach Ergebnis aus Task_11
- Timeline-Policy `.after(Intervall)` passend zur Einstellung (15/30/60 Min), mit dem Hinweis, dass iOS selbst budgetiert
- Ladezustand und Fehlerverhalten wie Android
- Mindestversion iOS 17 dokumentieren

**Gehört nicht dazu:**

- Garantierte Aktualisierungsintervalle (iOS entscheidet selbst)

## Umsetzungsschritte

1. [ ] AppIntent für Reload anlegen und am Icon einbinden
2. [ ] Refresh-Weg gemäß Task_11 umsetzen; bei nativem Weg Provider-Logik minimal in Swift spiegeln und das Payload-Format exakt einhalten
3. [ ] Timeline-Reload nach erfolgreichem Refresh (`WidgetCenter.shared.reloadAllTimelines()`)
4. [ ] Intervall-Einstellung aus der App Group lesen und Timeline-Policy setzen
5. [ ] Im Simulator und – falls möglich – auf Gerät testen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Swift-Unit-Test: Berechnung des nächsten Timeline-Zeitpunkts aus Intervall
- Bei nativem Weg: Swift-Tests für Parsing/Formatierung mit denselben Fixtures wie in Dart, Ergebnis-Strings identisch
- `flutter test tests/` bleibt grün

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [ ] Reload-Button aktualisiert das iOS-Widget bei geschlossener App (Simulator-Beleg)
- [ ] Alle Tests grün, iOS-Build erfolgreich
- [ ] README-Status: Roadmap abgeschlossen

## Offene Fragen / Annahmen

- Abhängig von der Klärung in Task_11 – diesen Task beim Archivieren von Task_11 konkretisieren.

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
