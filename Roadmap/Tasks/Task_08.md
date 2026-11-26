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

1. [ ] Refresh-Logik in eine zentrale, testbare Funktion auslagern; App-Button darauf umstellen
2. [ ] Hintergrund-Callback mit `@pragma('vm:entry-point')` registrieren
3. [ ] Glance: Reload-Icon mit Action, die den Callback auslöst
4. [ ] Flag „lädt gerade“ im Widget-Speicher setzen/zurücksetzen, Widget zeigt Ladezustand
5. [ ] Doppelauslösung verhindern (laufender Refresh → zweiter Klick ignoriert)
6. [ ] Auf Gerät/Emulator bei geschlossener App testen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- `refreshWidgetData()` mit Fake-Provider: schreibt korrekten Payload, setzt Zeitstempel, setzt Lade-Flag zurück
- Fehler im Provider: alter Payload bleibt erhalten, Lade-Flag wird trotzdem zurückgesetzt
- Paralleler zweiter Aufruf wird ignoriert

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [ ] `flutter test tests/` grün
- [ ] Bei beendeter App aktualisiert der Button das Widget inkl. neuer Abrufzeit (manuell belegt)

## Offene Fragen / Annahmen

- Keine

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
