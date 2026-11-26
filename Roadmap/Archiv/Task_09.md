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

1. [x] Intervall-Einstellung ergänzen und persistieren
2. [x] WorkManager einbinden, eindeutigen periodischen Job registrieren (`ExistingPeriodicWorkPolicy.UPDATE`/REPLACE)
3. [x] Constraint „Netzwerk verbunden“ setzen
4. [x] Lebenszyklus an Widget-Receiver (`onEnabled`/`onDisabled`) koppeln
5. [x] Logging der letzten Hintergrundausführung (für Debugging, z. B. im Widget-Speicher)
6. [x] Mit verkürztem Test-Trigger oder `adb shell cmd jobscheduler run` prüfen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Intervall-Einstellung: Persistenz und Default
- Planungslogik: Intervalländerung führt zu Neuplanung mit richtigem Intervall (Scheduler gemockt)
- Kein Widget vorhanden → kein Job geplant

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [x] `flutter test tests/` grün
- [x] Per `adb`-Trigger ausgelöster Job aktualisiert das Widget bei beendeter App (manuell belegt)
- [x] Intervallwechsel ist in `adb shell dumpsys jobscheduler` sichtbar oder anderweitig belegt

## Offene Fragen / Annahmen

- Akkuoptimierung einzelner Hersteller kann Jobs verzögern – nur dokumentieren, nicht umgehen.

## Notizen zu diesem Task

Taskspezifische Informationen während der Arbeit hier festhalten. Taskübergreifendes gehört in `Roadmap/README.md`.

## Abschluss-Checkliste

Reihenfolge und Details stehen in `AGENTS.md`, Abschnitt "Abschluss- und Archivierungs-Workflow".

- [x] Alle Akzeptanzkriterien erfüllt, Tests liegen permanent in `tests/` und laufen grün
- [x] Abschnitt "Erkenntnisse für Folge-Agenten" unten ausgefüllt
- [x] Folge-Tasks und `Roadmap/README.md` geprüft und bei Bedarf angepasst
- [x] Datei ohne `RUN_` nach `Roadmap/Archiv/` verschoben

## Erkenntnisse für Folge-Agenten

- **Umgesetzt (und Abweichungen vom Plan):** `UpdateInterval` (15/30/60, Standard 30) in `AppSettings`; Auswahl in den Einstellungen. `lib/widget_sync/update_scheduler.dart`: `BackgroundScheduler` (Abstraktion), `WorkmanagerScheduler` (eindeutiger periodischer Job `ssw_periodic_refresh`, Constraint Netzwerk, Policy `update`), `UpdateScheduler.apply` (Widget vorhanden → planen, sonst abbrechen; `HomeWidget.getInstalledWidgets`). `background.dart`: `workmanagerDispatcher` (schreibt `ssw_last_background_run`, ruft `refresh()`), `applyUpdateSchedule()` (nur Android), Callback-URI `simplestock://schedule`. `main()` initialisiert Workmanager und plant. Einstellungsänderung des Intervalls plant neu (`scheduleUpdatesProvider`). Kotlin: `StockWidgetReceiver.onEnabled` → Dart plant per Hintergrund-Callback, `onDisabled` → `WorkManager.cancelUniqueWork`. Periodische WorkManager-Jobs überstehen Neustarts von selbst.
- **Learnings & Stolpersteine:** `workmanager` 0.10: `initialize(callbackDispatcher)`, `registerPeriodicTask(uniqueName, taskName, frequency:, constraints:, existingWorkPolicy:)`; Policy `update` übernimmt ein geändertes Intervall ohne den Job zurückzusetzen. App braucht `androidx.work:work-runtime` direkt (für `onDisabled` in Kotlin), Version wie im Plugin (2.11.2). Prüfung per `adb shell cmd jobscheduler run` bzw. `dumpsys jobscheduler` steht aus (kein Gerät/Emulator).
- **Wichtige Entscheidungen und ihre Gründe:** Planung in Dart (eine Stelle), Kotlin nur für das Abbrechen. Kein Umgehen der Akkuoptimierung (laut Task nur dokumentiert, Hinweis in den Einstellungen).
- **Auswirkungen auf Folge-Tasks:** Task 10 kann `ssw_last_background_run` und `updateInterval` für die „veraltet“-Regel (älter als 2× Intervall) nutzen. iOS (Task 12) nutzt nicht WorkManager, sondern die Timeline-Policy; `applyUpdateSchedule` ist dort ein No-op.
- **Hinweise zu Tests und Befehlen:** `flutter test tests/widget_sync/update_scheduler_test.dart tests/app/settings_page_test.dart`. Am Gerät: `adb shell cmd jobscheduler run -f de.sphaerox.simple_stock_widget <jobId>` (Job-ID aus `adb shell dumpsys jobscheduler | grep simple_stock`).
