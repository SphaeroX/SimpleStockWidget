# Task_06: Anzeigemodus %, Betrag oder beides

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_06.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Der Nutzer legt fest, ob die Tagesveränderung als Prozent, als Betrag oder beides angezeigt wird – global und pro Wert überschreibbar. Alle Zahlen werden im deutschen Format ausgegeben.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_05 archiviert.
- **Relevantes Vorwissen:** Einstellungen-Modell (Task_05), Detailseite (Task_04).

## Umfang

**Gehört dazu:**

- Globale Einstellung Anzeigemodus (Prozent / Betrag / beides), Default: Prozent
- Override pro Eintrag (Erben / Prozent / Betrag / beides)
- Zentrale Formatierungsfunktion: deutsches Zahlenformat, Vorzeichen, Nachkommastellen, Währungssymbol
- Widget-Payload enthält fertig formatierte Strings und die Richtung (hoch/runter/neutral)

**Gehört nicht dazu:**

- Layout und Farben im Widget (Task 07)

## Umsetzungsschritte

1. [ ] Modus-Enum und globale Einstellung + Override ergänzen
2. [ ] Effektiven Modus pro Eintrag ermitteln
3. [ ] Formatter mit `intl` (Locale `de_DE`): Kurs (2 Nachkommastellen, bei Krypto < 1 mehr), Betrag mit Vorzeichen, Prozent mit Vorzeichen und `%`
4. [ ] Beides: Format z. B. `+1,63 (+1,29 %)` – endgültige Darstellung in Task 07 abstimmen
5. [ ] Payload auf formatierte Strings + Richtung umstellen; native Seite muss nichts mehr rechnen

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Formatierung: `50182.95` → `50.182,95`; `-6.08` → `−6,08` bzw. `-6,08`; `0.0` → neutral
- Prozent-, Betrag- und Beides-Format
- Effektiver Modus für alle Kombinationen
- Richtung hoch/runter/neutral korrekt
- Sehr kleine Krypto-Kurse bekommen genügend Nachkommastellen

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [ ] `flutter test tests/` grün
- [ ] Umschalten des Modus in der App ändert die Anzeige im Widget nach dem nächsten Update (manuell belegt)

## Offene Fragen / Annahmen

- Echtes Minuszeichen (−) oder Bindestrich: Annahme Bindestrich wie im Screenshot.

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
