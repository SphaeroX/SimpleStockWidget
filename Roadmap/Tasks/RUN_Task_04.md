# Task_04: Eigene Anzeigenamen

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_04.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Jeder Watchlist-Eintrag kann einen frei wählbaren Anzeigenamen bekommen (z. B. „msci world“ statt `IWDA.L`, „SpaceX“). Ohne eigenen Namen wird das Symbol angezeigt.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_03 archiviert.
- **Relevantes Vorwissen:** Watchlist-Modell und Persistenz aus Task_03.

## Umfang

**Gehört dazu:**

- Feld `displayName` (optional) im Watchlist-Eintrag inkl. Migration bestehender gespeicherter Daten
- Bearbeiten-Dialog/Detailseite pro Eintrag
- Anzeige in App und Widget: eigener Name, sonst Symbol

**Gehört nicht dazu:**

- Währung/Modus pro Wert (Tasks 05–06) – die Detailseite wird dort erweitert

## Umsetzungsschritte

1. [ ] Modell um `displayName` erweitern, Laden alter Daten ohne das Feld sicherstellen
2. [ ] Detailseite pro Eintrag anlegen (wird in 05/06 wiederverwendet)
3. [ ] Name setzen/löschen (leer = zurück zum Symbol), Längenbegrenzung (z. B. 20 Zeichen)
4. [ ] Widget-Payload nutzt den effektiven Namen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Effektiver Name: eigener Name vs. Fallback Symbol
- Leerer/whitespace Name → Fallback
- Alte gespeicherte Daten ohne `displayName` werden korrekt geladen
- Längenbegrenzung

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [ ] `flutter test tests/` grün
- [ ] Umbenannter Eintrag erscheint im Widget mit neuem Namen (manuell belegt)

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
