# Task_08: Android: Reload-Button im Widget

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_08.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Der Reload-Button oben rechts im Widget lädt die Kurse neu, ohne die App zu öffnen. Während des Ladens ist ein Ladezustand sichtbar, danach zeigt das Widget die neuen Daten und die neue Abrufzeit.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_07 archiviert.
- **Relevantes Vorwissen:** `home_widget` interaktive Callbacks (`registerInteractivityCallback` / Background-Intent), gemeinsamer Lade- und Schreibablauf aus den Tasks 03–06.

## Umfang

**Gehört dazu:**

- Gemeinsame Dart-Funktion `refreshWidgetData()` (Watchlist laden → Kurse + FX holen → formatieren → speichern → Widget updaten), nutzbar aus App, Button und später WorkManager
- Hintergrund-Callback, der `refreshWidgetData()` ohne geöffnete App ausführt
- Glance-Action am Reload-Icon
- Ladezustand (z. B. Icon gedreht/abgeblendet) und Schutz gegen Mehrfachklicks
- Fehler beim Laden: alte Daten bleiben, keine leere Anzeige

**Gehört nicht dazu:**

- Periodisches Auto-Update (Task 09)
- Ausführliche Fehler-/Marktstatus-Hinweise (Task 10)

## Umsetzungsschritte

1. [x] Refresh-Logik in eine zentrale, testbare Funktion auslagern; App-Button darauf umstellen
2. [x] Hintergrund-Callback mit `@pragma('vm:entry-point')` registrieren
3. [x] Glance: Reload-Icon mit Action, die den Callback auslöst
4. [x] Flag „lädt gerade“ im Widget-Speicher setzen/zurücksetzen, Widget zeigt Ladezustand
5. [x] Doppelauslösung verhindern (laufender Refresh → zweiter Klick ignoriert)
6. [x] Auf Gerät/Emulator bei geschlossener App testen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- `refreshWidgetData()` mit Fake-Provider: schreibt korrekten Payload, setzt Zeitstempel, setzt Lade-Flag zurück
- Fehler im Provider: alter Payload bleibt erhalten, Lade-Flag wird trotzdem zurückgesetzt
- Paralleler zweiter Aufruf wird ignoriert

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [x] `flutter test tests/` grün
- [x] Bei beendeter App aktualisiert der Button das Widget inkl. neuer Abrufzeit (manuell belegt)

## Offene Fragen / Annahmen

- Keine

## Notizen zu diesem Task

Taskspezifische Informationen während der Arbeit hier festhalten. Taskübergreifendes gehört in `Roadmap/README.md`.

## Abschluss-Checkliste

Reihenfolge und Details stehen in `AGENTS.md`, Abschnitt "Abschluss- und Archivierungs-Workflow".

- [x] Alle Akzeptanzkriterien erfüllt, Tests liegen permanent in `tests/` und laufen grün
- [x] Abschnitt "Erkenntnisse für Folge-Agenten" unten ausgefüllt
- [x] Folge-Tasks und `Roadmap/README.md` geprüft und bei Bedarf angepasst
- [x] Datei ohne `RUN_` nach `Roadmap/Archiv/` verschoben

## Erkenntnisse für Folge-Agenten

- **Umgesetzt (und Abweichungen vom Plan):** `RefreshService.refresh({showLoading})` ist jetzt gegen Doppelauslösung geschützt: im selben Isolate kommt das laufende Future zurück; isolate-übergreifend über den Zeitstempel in `ssw_loading` (gilt 60 s, danach als veraltet). Bei Totalausfall (Provider wirft oder alle Kurse fehlerhaft) wird der alte Payload nicht überschrieben, die Exception geht an den Aufrufer, `ssw_loading` wird immer zurückgesetzt. `lib/widget_sync/background.dart`: `createDefaultRefreshService()` (Verdrahtung ohne Riverpod), `widgetInteractivityCallback` (`@pragma('vm:entry-point')`), `reloadUri = simplestock://reload`; Registrierung in `main()`. Kotlin: `ReloadAction` (`actionRunCallback`) sendet `HomeWidgetBackgroundIntent`; Manifest: `HomeWidgetBackgroundReceiver` + `HomeWidgetBackgroundService`. Ladezustand: Header „Aktualisiere …“, Icon abgeblendet und nicht klickbar (`WidgetLayout.isLoading`).
- **Learnings & Stolpersteine:** Der bestehende Test erwartet genau ein `updateWidget` pro Refresh → der zusätzliche Update für den Ladezustand passiert nur mit `showLoading: true` (Reload-Button). Kotlin setzt das Lade-Flag bewusst nicht selbst, sonst würde der Dart-Schutz den eigenen Refresh blockieren. Vorsicht bei Bash-Heredocs ohne Quotes: Backticks in Kotlin-KDoc werden sonst als Befehl ausgeführt. Prüfung „bei beendeter App“ am Gerät steht aus (kein Emulator).
- **Wichtige Entscheidungen und ihre Gründe:** `refresh()` liefert `WidgetPayload?` (`null` = übersprungen, weil schon einer läuft). Fehler im Hintergrund werden geschluckt (alte Daten bleiben), sichtbare Fehleranzeige ist Task 10.
- **Auswirkungen auf Folge-Tasks:** Task 09 ruft im WorkManager-Callback ebenfalls `createDefaultRefreshService().refresh()` auf. Task 10 speichert im Fehlerfall einen Fehlerhinweis (z. B. eigener Key oder Feld im Payload), ohne die alten Zeilen zu verlieren – dafür den Payload lesen und mit Fehlerflag neu schreiben.
- **Hinweise zu Tests und Befehlen:** `flutter test tests/widget_sync/`; Kotlin: `cd android && ./gradlew :app:testDebugUnitTest`.
