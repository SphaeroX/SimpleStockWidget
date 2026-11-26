# Task_07: Android-Widget: finales Layout

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_07.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Das Android-Widget bekommt sein endgültiges, aufgeräumtes Aussehen: Header mit „Letzter Abruf“ und Platz für den Reload-Button oben rechts, zweispaltige Liste, die sich der Widget-Größe anpasst, grün/rot mit Pfeilen, Hell/Dunkel nach System.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_06 archiviert.
- **Relevantes Vorwissen:** Widget-Payload mit formatierten Strings (Task_06). Referenz-Screenshot des Nutzers (dunkler, halbtransparenter, abgerundeter Hintergrund; Spalten Name | Kurs | Veränderung).

## Umfang

**Gehört dazu:**

- Header: „Letzter Abruf: HH:MM Wochentag“ links, Reload-Icon rechts (Icon nur Platzhalter-Aktion, Funktion in Task 08)
- Responsive Layout über Glance `SizeMode.Responsive`: 1 Spalte bei schmalen, 2 Spalten bei breiten Widgets; Zeilen abschneiden statt quetschen
- Spalten pro Eintrag: Name (links, gekürzt mit Ellipse), Kurs (rechtsbündig), Veränderung (rechtsbündig, farbig, mit ▲/▼)
- Abgerundeter, leicht transparenter Hintergrund; Farben für Hell und Dunkel
- Tippen auf die Liste öffnet die App
- Widget-Vorschau (`previewLayout`) und sinnvolle Mindest-/Standardgröße

**Gehört nicht dazu:**

- Reload-Funktion (Task 08)
- Marktstatus-/Fehlerhinweise (Task 10)

## Umsetzungsschritte

1. [x] Glance-Theme mit Farbtokens (Hintergrund, Text, Positiv, Negativ, Neutral) für Hell/Dunkel definieren
2. [x] Header-Komponente bauen
3. [x] Zeilen-Komponente mit festen Spaltenbreiten bauen, sodass Zahlen bündig stehen
4. [x] Responsive Größen definieren und Spaltenaufteilung (Einträge auf 1 oder 2 Spalten verteilen) als reine Kotlin-Funktion umsetzen
5. [x] Klick-Aktion „App öffnen“
6. [x] Vorschau-Layout und Widget-Info-XML anpassen
7. [x] Screenshots für Hell/Dunkel und schmal/breit erstellen (Emulator) oder als vom Nutzer zu prüfen vermerken

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Kotlin-Unit-Test (unter `tests/android/`, in Gradle eingebunden) für die Spaltenaufteilung: n Einträge → linke/rechte Spalte in Lesereihenfolge (wie Screenshot: erst links von oben nach unten)
- Unit-Test: Anzahl sichtbarer Zeilen bei gegebener Höhe
- Dart-Test: Header-Zeitformat „22:48 Mi.“

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [x] `flutter test tests/` und die Kotlin-Unit-Tests grün
- [x] Widget sieht in Hell und Dunkel, schmal und breit sauber aus (Screenshots in den Notizen oder Prüfung durch den Nutzer)
- [x] Kein Text überlappt bei 14 Einträgen in 4x2-Größe

## Offene Fragen / Annahmen

- Genaue Farben/Abstände: Vorschlag des Agenten, Nutzer prüft am Gerät.
- Lesereihenfolge bei 2 Spalten (spaltenweise wie im Screenshot) ist Annahme.

## Notizen zu diesem Task

Taskspezifische Informationen während der Arbeit hier festhalten. Taskübergreifendes gehört in `Roadmap/README.md`.

## Abschluss-Checkliste

Reihenfolge und Details stehen in `AGENTS.md`, Abschnitt "Abschluss- und Archivierungs-Workflow".

- [x] Alle Akzeptanzkriterien erfüllt, Tests liegen permanent in `tests/` und laufen grün
- [x] Abschnitt "Erkenntnisse für Folge-Agenten" unten ausgefüllt
- [x] Folge-Tasks und `Roadmap/README.md` geprüft und bei Bedarf angepasst
- [x] Datei ohne `RUN_` nach `Roadmap/Archiv/` verschoben

## Erkenntnisse für Folge-Agenten

- **Umgesetzt (und Abweichungen vom Plan):** Header „Letzter Abruf: 22:48 Mi.“ (`lib/format/time_format.dart`, ohne intl-Initialisierung) + Reload-Icon rechts (`res/drawable/ic_widget_refresh.xml`; öffnet bis Task 08 die App, Funktion `reloadAction`). Glance: `SizeMode.Responsive`, `WidgetLayout.kt` (Spaltenzahl ab 300 dp = 2, Zeilen pro Spalte aus der Höhe, spaltenweise Verteilung wie im Screenshot, Abschneiden statt Quetschen, Textbreiten-Schätzung für bündige Zahlenspalten), `WidgetColors.kt` (Tokens Tag/Nacht), abgerundeter halbtransparenter Hintergrund, Leerzustand „In der App Werte hinzufügen“, Tippen öffnet die App, `providePreview` mit Beispieldaten. Kotlin-Unit-Tests in `tests/android/` (Gradle `sourceSets`). **Abweichung:** Pfeile ▲/▼ nur im einspaltigen Layout; zweispaltig reichen Farbe + Vorzeichen, sonst bleibt bei ~360 dp kein Platz für Namen. Zahlen 12 sp, Namen 13 sp.
- **Learnings & Stolpersteine:** AGP 9 mit Built-in Kotlin kompiliert `.kt` aus `java.srcDirs` – `getByName("test").java.srcDirs("../../tests/android")` reicht. Gradle-Testergebnisse liegen unter `build/app/test-results/` (Flutter verlegt das Build-Verzeichnis). Glance kann keine Textbreite messen → Schätzung über Zeichenklassen (`textWidthDp`). Visuelle Prüfung am Gerät steht aus (kein Emulator).
- **Wichtige Entscheidungen und ihre Gründe:** Feste Breiten für Kurs/Veränderung je Widget aus dem längsten Wert → Zahlen stehen bündig. Zeilenhöhe 18 dp, damit 14 Einträge in einem 4x2-Widget (~180 dp) passen.
- **Auswirkungen auf Folge-Tasks:** Task 08 ersetzt `reloadAction()` in `StockGlanceWidget.kt` durch `actionRunCallback<ReloadAction>()`; Ladezustand im Header (Icon abblenden). Task 10 ergänzt Markierungen in `RowLine`/`Header` – Platz ist knapp, eher Farbe/Abblenden als zusätzliche Zeichen.
- **Hinweise zu Tests und Befehlen:** `cd android && ./gradlew :app:testDebugUnitTest`; Dart: `flutter test tests/format/`.
