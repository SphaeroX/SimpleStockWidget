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

1. [x] Modell um `displayName` erweitern, Laden alter Daten ohne das Feld sicherstellen
2. [x] Detailseite pro Eintrag anlegen (wird in 05/06 wiederverwendet)
3. [x] Name setzen/löschen (leer = zurück zum Symbol), Längenbegrenzung (z. B. 20 Zeichen)
4. [x] Widget-Payload nutzt den effektiven Namen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Effektiver Name: eigener Name vs. Fallback Symbol
- Leerer/whitespace Name → Fallback
- Alte gespeicherte Daten ohne `displayName` werden korrekt geladen
- Längenbegrenzung

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [x] `flutter test tests/` grün
- [x] Umbenannter Eintrag erscheint im Widget mit neuem Namen (manuell belegt)

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

- **Umgesetzt (und Abweichungen vom Plan):** `WatchlistEntry.displayName` (optional, JSON abwärtskompatibel), `effectiveName` (eigener Name sonst Symbol), `withDisplayName` (trimmt, leer → null, max. 20 Zeichen), `lib/app/entry_detail_page.dart` (Detailseite, Tippen auf Eintrag öffnet sie, „Speichern“ → `WatchlistNotifier.replace`). Widget-Payload nutzt `effectiveName`. In der App-Liste steht der eigene Name, sonst der Quellname.
- **Learnings & Stolpersteine:** Keine besonderen.
- **Wichtige Entscheidungen und ihre Gründe:** Zu lange Namen werden abgeschnitten statt abgewiesen (einfachere UI, Eingabefeld begrenzt zusätzlich).
- **Auswirkungen auf Folge-Tasks:** Detailseite hat `_extraSettings()` als Platzhalter für Währungs- und Modus-Auswahl (Tasks 05/06); dort `_draft` zu einer veränderlichen Variable machen und `withDisplayName` auf den Entwurf anwenden. `WatchlistEntry`-Konstruktor um neue Felder erweitern und `withDisplayName` muss sie mitkopieren (am besten `copyWith` einführen).
- **Hinweise zu Tests und Befehlen:** `flutter test tests/watchlist/ tests/app/`.
