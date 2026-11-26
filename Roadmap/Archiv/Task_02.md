# Task_02: Provider-Schnittstelle + Yahoo-Provider

> ## ⚠️ PFLICHT – BEVOR DU IRGENDETWAS ANDERES TUST
>
> 1. **Lies als Allererstes die Datei `AGENTS.md` im übergeordneten Ordner `Roadmap/`** (von hier: `../AGENTS.md`) und befolge sie strikt.
> 2. **Deine allererste Aktion** ist, diese Datei in `RUN_Task_02.md` umzubenennen, um den Task als laufend zu markieren. Das passiert **noch bevor irgendein Code geschrieben** wird.

## Ziel

Der Kursabruf wird hinter eine austauschbare Schnittstelle `QuoteProvider` gelegt und der Yahoo-Provider robust ausgebaut: mehrere Symbole pro Abruf, Marktstatus, saubere Fehlerbehandlung. Damit kann später eine offizielle API eingesteckt werden, ohne App und Widget anzufassen.

## Kontext & Abhängigkeiten

- **Voraussetzung:** Task_01 archiviert.
- **Relevantes Vorwissen:** Erkenntnisse aus Task_01 (Yahoo-Endpunkt, Cookie/Crumb). README-Abschnitt Datenquelle.

## Umfang

**Gehört dazu:**

- Domänenmodell `Quote` (Symbol, Kurs, Vortagesschluss, absolute und prozentuale Veränderung, Währung, Marktstatus, Zeitstempel)
- Interface `QuoteProvider` mit `fetchQuotes(List<String> symbols)` und (für Task 03 vorbereitet) `search(String query)`
- `YahooQuoteProvider` als Implementierung, Batch-Abruf mehrerer Symbole
- Fehlertypen (Netzwerk, unbekanntes Symbol, Parsing, Rate-Limit) und Timeout
- Austausch des Ad-hoc-Abrufs aus Task_01 durch den Provider

**Gehört nicht dazu:**

- Suche-UI (Task 03)
- Währungsumrechnung (Task 05) – Provider liefert nur Rohwährung
- Darstellung von Marktstatus im Widget (Task 10)

## Umsetzungsschritte

1. [x] `Quote`-Modell und `MarketState` (z. B. offen, geschlossen, vorbörslich, nachbörslich, unbekannt) definieren
2. [x] `QuoteProvider`-Interface anlegen; Provider per einfacher Dependency-Injection (Konstruktor/Provider-Paket) bereitstellen
3. [x] `YahooQuoteProvider` implementieren: Batch-Abruf, Mapping der Yahoo-Felder (inkl. `marketState`), Timeout
4. [x] Teilerfolge behandeln: Unbekanntes Symbol darf die anderen Ergebnisse nicht verhindern
5. [x] Fehlertypen definieren und im Provider werfen/zurückgeben
6. [x] Code aus Task_01 auf den Provider umstellen
7. [x] Fixtures für mehrere Symboltypen anlegen (Aktie `NVDA`, deutscher Wert `EVK.DE`, ETF `IWDA.L`, Index `^GDAXI`, Krypto `BTC-EUR`)

## Tests

Alle Tests dieses Tasks werden permanent in `tests/` im Hauptverzeichnis des Projekts abgelegt (siehe `AGENTS.md`).

Zu belegendes Verhalten:

- Mapping aller fünf Symboltypen aus Fixtures
- Marktstatus-Mapping inkl. unbekannter Werte → `unbekannt`
- Batch mit einem ungültigen Symbol: gültige Quotes kommen, ungültiges ist als Fehler markiert
- Netzwerkfehler/Timeout/HTTP 429 → passender Fehlertyp (HTTP-Client gemockt)
- Austauschbarkeit: App-Logik läuft mit einem Fake-Provider

## Akzeptanzkriterien

Der Task gilt erst als fertig, wenn alle Punkte erfüllt und durch Tests oder einen konkreten Befehl belegt sind:

- [x] `flutter test tests/` grün inkl. der oben genannten Fälle
- [x] Kein Code außerhalb des Providers kennt Yahoo-spezifische Felder (per Code-Review/Grep belegt)
- [x] `flutter analyze` ohne Fehler

## Offene Fragen / Annahmen

- Ob `search` über denselben Provider oder eine eigene Schnittstelle läuft, darf hier entschieden werden – in README festhalten.

## Notizen zu diesem Task

Taskspezifische Informationen während der Arbeit hier festhalten. Taskübergreifendes gehört in `Roadmap/README.md`.

## Abschluss-Checkliste

Reihenfolge und Details stehen in `AGENTS.md`, Abschnitt "Abschluss- und Archivierungs-Workflow".

- [x] Alle Akzeptanzkriterien erfüllt, Tests liegen permanent in `tests/` und laufen grün
- [x] Abschnitt "Erkenntnisse für Folge-Agenten" unten ausgefüllt
- [x] Folge-Tasks und `Roadmap/README.md` geprüft und bei Bedarf angepasst
- [x] Datei ohne `RUN_` nach `Roadmap/Archiv/` verschoben

## Erkenntnisse für Folge-Agenten

- **Umgesetzt (und Abweichungen vom Plan):** `lib/quotes/quote.dart` (`Quote` mit `type`, `marketState`, `marketTime`; Enums `QuoteType`, `MarketState`), `lib/quotes/quote_provider.dart` (Interface `QuoteProvider` mit `fetchQuotes` + `search`, `QuoteBatch`, `SymbolSearchResult`, sealed `QuoteException` mit `NetworkQuoteException`, `UnknownSymbolException`, `RateLimitException`, `ParseQuoteException`), `lib/quotes/yahoo/yahoo_quote_provider.dart` (parallele Einzelabrufe des Chart-Endpunkts, Timeout 10 s, injizierbare `clock`), `lib/quotes/providers.dart` (`quoteProviderProvider` für Riverpod). `search` liefert in Yahoo noch `[]` → Task 03.
- **Learnings & Stolpersteine:** Enum-Wert `index` ist in Dart verboten (Konflikt mit `Enum.index`) → `QuoteType.marketIndex`. Yahoo liefert Marktstatus nicht im Chart; Berechnung aus `currentTradingPeriod.pre/regular/post` gegen die aktuelle Zeit, Krypto immer `open`. Ohne `currentTradingPeriod` → `unknown`.
- **Wichtige Entscheidungen und ihre Gründe:** `search` gehört mit in `QuoteProvider` (eine Quelle = eine Schnittstelle). `YahooParseException` erbt von `ParseQuoteException`, damit der Rest der App nur die neutralen Typen kennt. `Quote.name` bevorzugt `longName` (shortName ist bei Yahoo oft abgeschnitten/aufgefüllt).
- **Auswirkungen auf Folge-Tasks:** Task 03 implementiert `YahooQuoteProvider.search` (Fixture `yahoo_search_msci.json`). Task 05 holt FX-Kurse einfach als Symbole `EURUSD=X` über `fetchQuotes`. Task 10 nutzt `Quote.marketState` und `QuoteBatch.errors`.
- **Hinweise zu Tests und Befehlen:** `flutter test tests/quotes/`. Für Tests mit Marktstatus immer `clock`/`now` setzen (NVDA-Fixture: regulär 1795617000–1795640400 epoch s). Fake-Provider-Beispiel steht in `tests/quotes/yahoo_quote_provider_test.dart`.
