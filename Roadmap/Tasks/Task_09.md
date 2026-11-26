# Task_09: Android: einstellbares Auto-Update

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_09.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Das Widget aktualisiert sich automatisch im Hintergrund im vom Nutzer gewählten Intervall (15, 30 oder 60 Minuten).

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_08 archiviert.
- **Relevantes Vorwissen:** `refreshWidgetData()` aus Task_08. Paket `workmanager` (oder nativer WorkManager, der den Dart-Callback startet). Android-Minimum 15 Minuten.

## Umfang

**Gehört dazu:**

- Einstellung Update-Intervall (15/30/60 Min, Default 30) im Einstellungsbildschirm
- Periodischer Job mit Netzwerk-Constraint, der `refreshWidgetData()` ausführt
- Job neu planen, wenn sich das Intervall ändert; Job beim Hinzufügen des Widgets starten, beim Entfernen des letzten Widgets stoppen
- Verhalten nach Geräteneustart sicherstellen

**Gehört nicht dazu:**

- iOS-Refresh (Task 12)
- Ruhezeiten/Börsenzeiten-abhängiges Intervall

## Umsetzungsschritte

1. [ ] Intervall-Einstellung ergänzen und persistieren
2. [ ] WorkManager einbinden, eindeutigen periodischen Job registrieren (`ExistingPeriodicWorkPolicy.UPDATE`/REPLACE)
3. [ ] Constraint „Netzwerk verbunden“ setzen
4. [ ] Lebenszyklus an Widget-Receiver (`onEnabled`/`onDisabled`) koppeln
5. [ ] Logging der letzten Hintergrundausführung (für Debugging, z. B. im Widget-Speicher)
6. [ ] Mit verkürztem Test-Trigger oder `adb shell cmd jobscheduler run` prüfen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Intervall-Einstellung: Persistenz und Default
- Planungslogik: Intervalländerung führt zu Neuplanung mit richtigem Intervall (Scheduler gemockt)
- Kein Widget vorhanden → kein Job geplant

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [ ] `flutter test tests/` grün
- [ ] Per `adb`-Trigger ausgelöster Job aktualisiert das Widget bei beendeter App (manuell belegt)
- [ ] Intervallwechsel ist in `adb shell dumpsys jobscheduler` sichtbar oder anderweitig belegt

## Offene Fragen / Annahmen

- Akkuoptimierung einzelner Hersteller kann Jobs verzögern – nur dokumentieren, nicht umgehen.

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
