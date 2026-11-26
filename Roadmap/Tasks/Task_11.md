# Task_11: iOS: Widget-Grundgerüst

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_11.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Das iOS-Widget (SwiftUI + WidgetKit) zeigt dieselben Daten im gleichen Layout wie das Android-Widget, gespeist über eine App Group aus der Flutter-App.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_10 archiviert. Mac mit Xcode oder macOS-CI (z. B. GitHub Actions) verfügbar – sonst Task anhalten und Nutzer fragen.
- **Relevantes Vorwissen:** Payload-Format und Layoutregeln aus Tasks 06, 07, 10 (siehe README). `home_widget`-Doku für iOS (App Group, `HomeWidget.setAppGroupId`).

## Umfang

**Gehört dazu:**

- Widget-Extension im Xcode-Projekt, App Group für App und Extension
- SwiftUI-Layout analog zu Android: Header, Zeilen, Farben, Hell/Dunkel, Markierungen, Leer-/Fehlerzustand
- Unterstützte Größen: systemMedium und systemLarge (systemSmall einspaltig, optional)
- Klick öffnet die App
- TimelineProvider, der gespeicherte Daten liest

**Gehört nicht dazu:**

- Reload-Button und Hintergrund-Refresh (Task 12)
- Lock-Screen-Widgets

## Umsetzungsschritte

1. [ ] Bundle-IDs und App Group festlegen, in README dokumentieren
2. [ ] Widget-Extension anlegen, App Group in beiden Targets aktivieren
3. [ ] `HomeWidget.setAppGroupId` in Dart setzen; Payload in der App Group verfügbar machen
4. [ ] Payload in Swift decodieren (Codable) und Views bauen
5. [ ] Spaltenaufteilung wie Android (Logik spiegeln oder gemeinsam spezifizieren)
6. [ ] Build auf Mac/CI, Prüfung im Simulator mit Screenshots

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Swift-Unit-Test (unter `tests/ios/`, im Xcode-Testtarget eingebunden): Decoding des Payloads inkl. fehlender optionaler Felder
- Swift-Unit-Test: Spaltenaufteilung identisch zu Android-Testfällen
- `flutter test tests/` bleibt grün

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [ ] iOS-Build erfolgreich (Mac oder CI-Log)
- [ ] Swift-Tests grün
- [ ] Widget zeigt im Simulator dieselben Daten wie die App (Screenshot)

## Offene Fragen / Annahmen

- **Klären:** Kann der iOS-Timeline-Refresh Dart-Code (über `home_widget`-Interaktivität, iOS 17) im Hintergrund ausführen, oder braucht es einen kleinen nativen Swift-Abruf? Ergebnis bestimmt Task 12; in README festhalten.
- Build-Umgebung (eigener Mac vs. CI) beim Nutzer erfragen, falls nicht in README vermerkt.

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
