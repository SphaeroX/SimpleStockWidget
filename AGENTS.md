# SimpleStockWidget

Privates Homescreen-Kurs-Widget (Aktien, ETFs, Indizes, Krypto) für Android und später iOS. Flutter-App (Dart, Riverpod) für Auswahl, Einstellungen und Datenabruf; native Widgets (Kotlin + Jetpack Glance, später SwiftUI + WidgetKit) zeigen nur den fertig formatierten Payload an.

## Oberste Regeln

1. **Test-Driven Development ist Pflicht.** Immer zuerst einen fehlschlagenden Test mit `flutter_test` (+ `mocktail`) schreiben, dann den minimalen Code, dann refaktorieren (Red, Green, Refactor). Kein Produktivcode ohne vorher fehlschlagenden Test. Bugfixes beginnen mit einem Test, der den Fehler reproduziert.
   - Bestehende Tests nie ändern, löschen oder abschwächen, um Grün zu erreichen. Schlägt ein Test fehl, wird die Implementierung korrigiert. Ist der Test selbst falsch, begründen und Freigabe einholen.
   - Reparaturbudget: höchstens 3 Versuche pro fehlschlagendem Test, danach anhalten und berichten (welche Tests, was versucht, Vermutung zur Ursache).
   - Führe zuerst die Tests des betroffenen Bereichs aus (`flutter test tests/<bereich>/`); die komplette Suite bei Änderungen an gemeinsam genutztem Code und vor jedem Abschluss.
   - Tests liegen ausschließlich in `tests/` (nicht `test/`), deshalb immer `flutter test tests/` mit Pfad aufrufen.
2. **Dokumentation aktuell halten.** Ändert sich Tech-Stack, Architektur, Konventionen, Code-Style oder Testing, aktualisiere sofort im selben Arbeitsschritt die passende Datei in `docs/`. Eine Aufgabe ist erst erledigt, wenn `docs/` stimmt.
3. **Umgebung:** Abhängigkeiten nur über `flutter pub add` / `flutter pub get`, keine anderen Paketmanager. In der Cloud-Umgebung liegt Flutter unter `/opt/flutter` – vorher `export PATH=/opt/flutter/bin:$PATH`. `pubspec.lock` wird committet.
4. **Logik nur in Dart.** Kurs-, Währungs- und Formatierungslogik gehört in Dart; Kotlin/Swift rendern nur den Payload. Widget-Speicher-Keys auf allen Plattformen gleichzeitig ändern.

## Befehle

```bash
export PATH=/opt/flutter/bin:$PATH        # nur Cloud-Umgebung
flutter pub get                            # Abhängigkeiten installieren
flutter test tests/                        # alle Tests
flutter test tests/<pfad>_test.dart        # einzelne Testdatei
(cd android && ./gradlew :app:testDebugUnitTest)   # Kotlin-Tests (Widget-Logik)
flutter analyze                            # Lint
dart format lib tests                      # Format
flutter build apk --debug                  # Android-Build (benötigt Android-SDK)
```

## Roadmap

Arbeit an Roadmap-Tasks richtet sich nach [Roadmap/AGENTS.md](Roadmap/AGENTS.md); die aktuellen Task-Dateien liegen in `Roadmap/Tasks/`, projektübergreifendes Wissen in `Roadmap/README.md`.

## Dokumentation (bei Bedarf laden)

Lies nur die Dateien, die für deine aktuelle Aufgabe relevant sind:

- [docs/architecture.md](docs/architecture.md) – Lies das vor Strukturänderungen, neuen Komponenten, neuen Abhängigkeiten oder Arbeit am nativen Widget. Tech-Stack, Datenfluss, Umgebung.
- [docs/testing.md](docs/testing.md) – Lies das, bevor du Tests schreibst oder die Test-Konfiguration änderst. Testing-Strategie, Fixtures, Fertig-Kriterien.
- [docs/code-style.md](docs/code-style.md) – Lies das vor dem Schreiben oder Formatieren von Code. Styling und Formatierung.
- [docs/conventions.md](docs/conventions.md) – Lies das bei Benennung, Dateiorganisation, Widget-Speicher-Keys oder Commits.
- [docs/project-brief.md](docs/project-brief.md) – Lies das, wenn Ziel, Umfang oder Nicht-Ziele des Projekts unklar sind.

## Grenzen

- Keine echten Netzwerkaufrufe in Standardtests; Yahoo-Antworten als Fixtures unter `tests/fixtures/`.
- Keine neuen Abhängigkeiten ohne Begründung in `docs/architecture.md`.
- Keine Secrets, Keystores oder `key.properties` committen.
- Keine Store-Veröffentlichungs-Artefakte (Store-Listing, Datenschutzerklärung) – Nicht-Ziel.
