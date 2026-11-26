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

1. [x] Einstellungen-Modell (global) anlegen und persistieren; Einstellungsbildschirm in der App
2. [x] Override-Feld im Watchlist-Eintrag + Auswahl auf der Detailseite
3. [x] Effektive Währung pro Eintrag ermitteln (Override > global > Original)
4. [x] Benötigte FX-Paare bestimmen und über den Provider holen
5. [x] Umrechnungsfunktion (rein, testbar) inkl. GBp→GBP-Normalisierung
6. [x] Umgerechnete Werte in den Widget-Payload schreiben, Währungssymbol mitgeben

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

- [x] `flutter test tests/` grün
- [x] Mit globaler Währung EUR erscheint NVDA im Widget in EUR (manuell belegt)

## Offene Fragen / Annahmen

- Annahme: Die absolute Tagesveränderung wird mit dem aktuellen FX-Kurs umgerechnet (nicht mit dem Vortages-FX). Kleine Abweichungen zur „echten“ EUR-Veränderung sind akzeptiert – im Zweifel Nutzer fragen.

## Notizen zu diesem Task

Taskspezifische Informationen während der Arbeit hier festhalten. Taskübergreifendes gehört in `Roadmap/README.md`.

## Abschluss-Checkliste

Reihenfolge und Details stehen in `AGENTS.md`, Abschnitt "Abschluss- und Archivierungs-Workflow".

- [x] Alle Akzeptanzkriterien erfüllt, Tests liegen permanent in `tests/` und laufen grün
- [x] Abschnitt "Erkenntnisse für Folge-Agenten" unten ausgefüllt
- [x] Folge-Tasks und `Roadmap/README.md` geprüft und bei Bedarf angepasst
- [x] Datei ohne `RUN_` nach `Roadmap/Archiv/` verschoben

## Erkenntnisse für Folge-Agenten

- **Umgesetzt (und Abweichungen vom Plan):** `lib/currency/currency.dart` (Pseudo-Währung `originalCurrency = 'ORIGINAL'`, `selectableCurrencies` EUR/USD/GBP/CHF, `effectiveTargetCurrency`, `normalizeQuoteCurrency` für GBp/GBX/ILA/ZAc, `fxSymbolsFor`, `convertQuote` → `ConvertedQuote` mit `converted`/`fxMissing`, `currencySymbol`, `currencyLabel`), `lib/settings/` (`AppSettings` mit `displayCurrency`, Standard Original; `SettingsRepository`), `WatchlistEntry.currency` (Override, `null` = global) + `copyWith` mit Sentinel für explizites `null`. `RefreshService` holt FX-Kurse in einem zweiten `fetchQuotes`-Aufruf nur für benötigte Paare (`USDEUR=X`, …) und schreibt `currency` (Symbol) in jede Zeile. App: `settings_page.dart` (globale Währung), Währungsauswahl auf der Detailseite, Zahnrad in der Watchlist. Live-Tests unter `tests/integration/` (standardmäßig übersprungen, `dart_test.yaml`).
- **Learnings & Stolpersteine:** Yahoo liefert Londoner Aktien in `GBp` (Pence), IWDA.L aber in `USD`. Beliebige FX-Paare `XXXYYY=X` funktionieren über den Chart-Endpunkt. Riverpod: eine eigene Methode `update` im `AsyncNotifier` kollidiert mit `AsyncNotifier.update` → `SettingsNotifier.change`. Dart erlaubt private benannte Parameter (`required this._quotes`), Lint `prefer_initializing_formals` verlangt sie.
- **Wichtige Entscheidungen und ihre Gründe:** Umrechnung mit aktuellem FX-Kurs (Annahme aus dem Task bestätigt, kein Vortages-FX). Fehlt ein FX-Kurs, bleibt die Originalwährung stehen (`fxMissing`), statt die Zeile zu verwerfen. `currency` ist in der Payload-Zeile optional (nur ausgegeben, wenn gesetzt).
- **Auswirkungen auf Folge-Tasks:** Task 06 baut die Zeilen-Formatierung aus (`formatSigned` ist bisher ohne Vorzeichen!) und sollte die Zeilenerzeugung aus `RefreshService` in einen reinen, testbaren Payload-Builder ziehen. `AppSettings` bekommt dort `changeMode`, `WatchlistEntry` ein `changeMode`-Override (gleiche Sentinel-Technik in `copyWith`). Task 07 kann das Währungssymbol im Widget anzeigen (`row.currency`).
- **Hinweise zu Tests und Befehlen:** `flutter test tests/currency/ tests/settings/ tests/widget_sync/`; live: `flutter test tests/integration --run-skipped --tags live`.
