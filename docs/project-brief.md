# Projektbild

> Wann lesen: wenn Ziel, Umfang oder Abgrenzung des Projekts unklar sind.

## Ziel und Zielgruppe

Ein schlankes Homescreen-Widget, das eine selbst gewählte Liste von Aktien, ETFs, Indizes und Kryptowerten mit aktuellem Kurs und Tagesveränderung zeigt – im Stil des Referenz-Screenshots (dunkle, abgerundete Karte, zweispaltige Liste Name | Kurs | Veränderung, grün/rot), aufgeräumter und mit Reload-Button oben rechts. Zielgruppe: ausschließlich der Projektinhaber selbst (private Nutzung).

## Kernfunktionen

- Werte per Name oder Ticker suchen, zur Watchlist hinzufügen, entfernen, sortieren.
- Eigene Anzeigenamen pro Wert (z. B. „msci world“ statt `IWDA.L`).
- Anzeigewährung global wählbar, pro Wert überschreibbar (inkl. Originalwährung).
- Anzeige der Tagesveränderung als Prozent, Betrag oder beides – global, pro Wert überschreibbar.
- Widget mit Header „Letzter Abruf: HH:MM Wochentag“, Reload-Button oben rechts, zweispaltiger, größenabhängiger Liste, Hell/Dunkel nach System.
- Sortierung im Widget wählbar: manuell (Watchlist-Reihenfolge), Name A–Z, Gewinner zuerst, Verlierer zuerst (nach Prozent).
- Automatisches Update im einstellbaren Intervall (15/30/60 Min).
- Hinweis bei geschlossener Börse, veralteten Daten und Fehlern; letzte Daten bleiben sichtbar.

## Nicht-Ziele

- Store-Veröffentlichung (Play Store / App Store).
- Charts und Kursverläufe, Portfolio/Stückzahlen, Kursalarme.
- Benutzerkonten, Cloud-Sync.
- Mehrere Widget-Instanzen mit unterschiedlichen Listen.

## Rahmenbedingungen

- Plattformen: Android zuerst und vollständig, iOS (ab iOS 17) danach.
- Verteilung: Sideload bzw. eigenes Gerät; kein Store-Review, keine Datenschutzerklärung nötig.
- Datenquelle: Yahoo Finance (inoffiziell, kostenlos) hinter austauschbarer Schnittstelle.
- Build: Android in der Cloud-Umgebung „SimpleStockWidget“ (Flutter + Android-SDK per Setup-Skript, kein Emulator); iOS nur mit Mac/Xcode oder macOS-CI.
- Kosten: keine laufenden Kosten vorgesehen.

## Offene Entscheidungen

- iOS-Hintergrund-Refresh über Dart oder nativen Swift-Abruf.
- iOS-Build-Umgebung (eigener Mac oder CI).

---
Pflege: Bei Änderungen an Zielen oder Umfang diese Datei aktualisieren.
