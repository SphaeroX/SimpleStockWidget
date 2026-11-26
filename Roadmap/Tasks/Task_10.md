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

1. [ ] Marktstatus und Fehlerinfos in den Payload aufnehmen (pro Eintrag + global)
2. [ ] Regel für „veraltet“ als reine Funktion umsetzen
3. [ ] Glance-Darstellung für geschlossen/vor-/nachbörslich, Fehler, veraltet, leer
4. [ ] Legende in der App ergänzen
5. [ ] Szenarien manuell prüfen (Flugmodus, ungültiges Symbol, Wochenende)

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

- [ ] `flutter test tests/` grün
- [ ] Im Flugmodus zeigt das Widget nach Reload die alten Daten mit Offline-Hinweis (manuell belegt)
- [ ] Am Wochenende sind Aktien als geschlossen markiert, Krypto nicht

## Offene Fragen / Annahmen

- Darstellungsform der Markierung (Punkt, Abblenden, Text) – Vorschlag des Agenten, Nutzer prüft.

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
