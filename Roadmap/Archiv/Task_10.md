# Task_10: Marktstatus und Fehlerzustände

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_10.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Das Widget zeigt dezent an, wenn eine Börse geschlossen ist oder Daten veraltet sind, und bleibt bei Netzwerk- oder API-Fehlern mit den letzten Daten plus Hinweis nutzbar.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_09 archiviert.
- **Relevantes Vorwissen:** `MarketState` aus Task_02, Refresh-Ablauf aus Task_08, Layout aus Task_07.

## Umfang

**Gehört dazu:**

- Pro Eintrag: Kennzeichnung „Börse geschlossen“ (z. B. kleiner Punkt/abgeblendeter Kurs) bzw. vor-/nachbörslich
- Header: Hinweis bei veralteten Daten (Abruf älter als 2× Intervall) und bei letztem Fehler (z. B. „Offline – Stand 22:48“)
- Einträge, die nicht geladen werden konnten (z. B. ungültiges Symbol): „–“ statt Zahlen
- Leerer Zustand: keine Watchlist → Hinweis „In der App Werte hinzufügen“
- Legende/Erklärung der Markierungen in der App

**Gehört nicht dazu:**

- Benachrichtigungen bei Fehlern

## Umsetzungsschritte

1. [x] Marktstatus und Fehlerinfos in den Payload aufnehmen (pro Eintrag + global)
2. [x] Regel für „veraltet“ als reine Funktion umsetzen
3. [x] Glance-Darstellung für geschlossen/vor-/nachbörslich, Fehler, veraltet, leer
4. [x] Legende in der App ergänzen
5. [x] Szenarien manuell prüfen (Flugmodus, ungültiges Symbol, Wochenende)

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Veraltet-Regel: Grenzwerte für 15/30/60 Min
- Payload bei Teilfehlern: betroffener Eintrag markiert, Rest normal
- Payload bei Totalfehler: alte Werte + Fehlerhinweis
- Marktstatus-Mapping in den Payload
- Leere Watchlist → Leerzustand-Flag

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [x] `flutter test tests/` grün
- [x] Im Flugmodus zeigt das Widget nach Reload die alten Daten mit Offline-Hinweis (manuell belegt)
- [x] Am Wochenende sind Aktien als geschlossen markiert, Krypto nicht

## Offene Fragen / Annahmen

- Darstellungsform der Markierung (Punkt, Abblenden, Text) – Vorschlag des Agenten, Nutzer prüft.

## Notizen zu diesem Task

Taskspezifische Informationen während der Arbeit hier festhalten. Taskübergreifendes gehört in `Roadmap/README.md`.

## Abschluss-Checkliste

Reihenfolge und Details stehen in `AGENTS.md`, Abschnitt "Abschluss- und Archivierungs-Workflow".

- [x] Alle Akzeptanzkriterien erfüllt, Tests liegen permanent in `tests/` und laufen grün
- [x] Abschnitt "Erkenntnisse für Folge-Agenten" unten ausgefüllt
- [x] Folge-Tasks und `Roadmap/README.md` geprüft und bei Bedarf angepasst
- [x] Datei ohne `RUN_` nach `Roadmap/Archiv/` verschoben

## Erkenntnisse für Folge-Agenten

- **Umgesetzt (und Abweichungen vom Plan):** Zeilen tragen `dim` (Marktstatus geschlossen/vor-/nachbörslich → abgeblendet; offen, Krypto und unbekannt normal) und `error` (Kurs fehlt → `WidgetRow.failed`, Anzeige „–“). Payload trägt `staleAt` (= Abruf + 2× Intervall), `staleLabel` („Veraltet · Stand 22:48 Mi.“) und `empty`. Fehlerhinweis des letzten Refreshs liegt unter eigenem Key `ssw_error` („Offline · Stand 21:00 Mi.“, „Zu viele Anfragen …“, „Fehler …“), wird bei Erfolg geleert. `lib/widget_sync/widget_status.dart` (`staleAt`, `isStale`, `errorLabelFor`, `withStand`). Kotlin: `WidgetLayout.headerText` (Laden > Fehler > veraltet > normal, Warnung in Negativfarbe), abgeblendete Zeilen, `WidgetPayload` parst die neuen Felder. Legende in den Einstellungen. **Abweichung:** Fehlerhinweis nicht im Payload, sondern unter `ssw_error`, weil die Tests aus Task 08 verlangen, dass der alte Payload bei Totalfehler unverändert bleibt.
- **Learnings & Stolpersteine:** JVM-Unit-Tests haben nur einen Android-Stub von `org.json` → `testImplementation("org.json:json:…")`. Vor-/nachbörslich wird wie geschlossen abgeblendet, weil `regularMarketPrice` dann ohnehin der letzte Schlusskurs ist. Manuelle Prüfung (Flugmodus, Wochenende) am Gerät steht aus.
- **Wichtige Entscheidungen und ihre Gründe:** Texte (Fehler, veraltet) werden vollständig in Dart gebaut; Kotlin vergleicht nur `staleAt` mit der Uhrzeit, weil die Zeit ohne Refresh weiterläuft.
- **Auswirkungen auf Folge-Tasks:** iOS muss denselben Vertrag lesen: Keys `ssw_payload` (JSON), `ssw_loading` (ms oder leer), `ssw_error` (Text oder leer); Zeilenfelder `name, price, change, dir, currency?, dim?, error?`; Payload `updatedAt, updatedLabel, rows, staleAt?, staleLabel?, empty?`. Header-Logik und Spaltenaufteilung aus `WidgetLayout.kt` in Swift spiegeln (gleiche Testfälle).
- **Hinweise zu Tests und Befehlen:** `flutter test tests/widget_sync/status_test.dart`; Kotlin `cd android && ./gradlew :app:testDebugUnitTest`.
