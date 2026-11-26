# Task_05: Währungsumrechnung

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_05.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Kurse und absolute Veränderungen können in einer gewünschten Anzeigewährung dargestellt werden. Es gibt eine globale Zielwährung, die pro Wert überschrieben werden kann (inkl. „Originalwährung“).

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_02 und Task_03 archiviert (Task_04 ebenfalls, wegen strikter Reihenfolge).
- **Relevantes Vorwissen:** `QuoteProvider` (Task_02), Detailseite pro Eintrag (Task_04). FX-Kurse über Yahoo (z. B. `EURUSD=X`).

## Umfang

**Gehört dazu:**

- Globale Einstellung Anzeigewährung (Auswahl: Original, EUR, USD, GBP, CHF – erweiterbar)
- Override pro Watchlist-Eintrag (Erben / Original / bestimmte Währung)
- FX-Kurse über den Provider holen (gebündelt, nur benötigte Paare)
- Umrechnung von Kurs und absoluter Veränderung; Prozentwert bleibt unverändert
- Sonderfall GBp/GBX (Pence) bei Londoner Werten

**Gehört nicht dazu:**

- Anzeigemodus %/Betrag (Task 06)
- Historische FX-Korrektur der Tagesveränderung (siehe Offene Fragen)

## Umsetzungsschritte

1. [ ] Einstellungen-Modell (global) anlegen und persistieren; Einstellungsbildschirm in der App
2. [ ] Override-Feld im Watchlist-Eintrag + Auswahl auf der Detailseite
3. [ ] Effektive Währung pro Eintrag ermitteln (Override > global > Original)
4. [ ] Benötigte FX-Paare bestimmen und über den Provider holen
5. [ ] Umrechnungsfunktion (rein, testbar) inkl. GBp→GBP-Normalisierung
6. [ ] Umgerechnete Werte in den Widget-Payload schreiben, Währungssymbol mitgeben

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Effektive Währung für alle Kombinationen (global/Override/Original)
- Umrechnung USD→EUR mit festem FX-Kurs: Kurs und Veränderung korrekt, Prozent unverändert
- GBp-Wert wird korrekt in GBP und weiter in EUR umgerechnet
- Gleiche Quell- und Zielwährung → keine Umrechnung, kein FX-Abruf
- FX-Kurs fehlt → Fallback auf Originalwährung mit Kennzeichnung

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [ ] `flutter test tests/` grün
- [ ] Mit globaler Währung EUR erscheint NVDA im Widget in EUR (manuell belegt)

## Offene Fragen / Annahmen

- Annahme: Die absolute Tagesveränderung wird mit dem aktuellen FX-Kurs umgerechnet (nicht mit dem Vortages-FX). Kleine Abweichungen zur „echten“ EUR-Veränderung sind akzeptiert – im Zweifel Nutzer fragen.

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
