# Setup & Checkliste – Stock Market App (UI-Teil)

Diese Anleitung ist für dich (Hassan). Sie zeigt, was du installieren musst, wie du die App in der vom Professor geforderten Umgebung (Emulator/Simulator) startest, und was im UI-Teil bereits fertig ist.

## 1. Was du installieren musst

1. **Flutter SDK** – https://docs.flutter.dev/get-started/install (Mac-Anleitung wählen). Danach im Terminal `flutter doctor` ausführen und alle roten Punkte abarbeiten.
2. **Android Studio** – https://developer.android.com/studio
   - Beim ersten Start: Android SDK + mindestens ein **Android Virtual Device (AVD)** über *Device Manager* anlegen (z. B. Pixel 8, API 34).
   - Das ist die vom Professor geforderte Emulator-Umgebung.
3. **Xcode** (optional, nur falls du auch den iOS-Simulator zeigen willst) – über den Mac App Store. Danach `open -a Simulator` reicht zum Testen.
4. **VS Code** (optional) mit den Extensions "Flutter" und "Dart" – etwas leichtgewichtiger als Android Studio zum Code editieren, ersetzt aber nicht den Emulator/die Android-Studio-Installation.
5. **Git**, falls noch nicht installiert (meist schon auf dem Mac vorhanden).

## 2. Projekt zum ersten Mal starten

```bash
cd ~/Downloads/stock_market_mobile
flutter pub get
```

Dann einen Emulator starten (Android Studio → Device Manager → ▶) oder den iOS-Simulator öffnen, und:

```bash
flutter run
```

Alternativ in Android Studio/VS Code: Projektordner öffnen, Gerät oben rechts auswählen, auf den grünen Run-Button klicken.

**Bekannte Stolperfalle:** Falls der Android-Build mit einem Fehler zu `minSdkVersion` abbricht (kann bei `firebase_auth` vorkommen), in `android/app/build.gradle.kts` `minSdk = flutter.minSdkVersion` auf `minSdk = 23` setzen.

## 3. Was im UI-Teil bereits fertig ist

Ich habe deinen kompletten UI-Teil basierend auf den 4 Figma-Screens (Home, Details, Portfolio, Profile) umgesetzt und um den Pflicht-Screen "Premium kaufen" ergänzt:

- Home, Explore, Portfolio, Profile über eine eigene Bottom-Nav-Bar erreichbar
- Stock-Detailseite mit Kursverlauf, Tagesspanne/52-Wochen-Spanne, Kennzahlen, Watchlist, Buy/Sell
- Portfolio-Übersicht mit Gewinn/Verlust, Chart, Kategorie-Filtern, Holdings-Liste
- Profil mit Premium-Banner → eigener Premium-Screen (Plan wählen, "Upgrade now" – rein simulierter Checkout, keine echte Zahlung)
- Einheitliches Farbschema/Theme über die ganze App (`lib/theme/app_theme.dart`)
- Neues, eindeutiges App-Icon (Android + iOS) statt des Standard-Flutter-Logos
- Da echte Kurs-Daten und Chart-Statistiken noch nicht angebunden sind (siehe Punkt 4), sind Charts/Kennzahlen mit "Demo"-Kennzeichnung als stabile Platzhalterwerte generiert – sehen für jede Aktie immer gleich aus, sind aber klar als Demo markiert.

Eine interaktive Vorschau aller Screens habe ich dir oben im Chat gezeigt – zum echten Testen brauchst du aber den Emulator/Simulator, wie vom Professor verlangt.

## 4. Was noch außerhalb des UI-Teils fehlt

Das ist nicht dein Part, aber relevant für die Abgabe – sprich es mit deinem Team ab:

- `lib/services/api_service.dart`, `stock_service.dart`, `locations_service.dart`, `lib/models/stock.dart`, `lib/models/user.dart` sind aktuell leere Platzhalter-Dateien. Echte Kursdaten (z. B. über eine Aktien-API) und ein `geolocator`-Package für das Länder-Feature müssen noch jemand aus dem Team einbauen.
- Sobald echte Daten angebunden sind, kannst du die "Demo"-Badges/Platzhalterwerte in den UI-Dateien einfach entfernen – die Widgets (`MarketChart`, `RangeBar`, etc.) erwarten nur normale Zahlen, keine Umstellung der UI nötig.

## 5. Checkliste laut Aufgabenstellung des Professors

| Anforderung | Status |
|---|---|
| ≥ 6 Screens | ✅ Home, Explore, Stock-Detail, Portfolio, Profile, Premium, Login, Sign-up |
| Navigation über Buttons/Nav-Bar | ✅ Bottom-Nav-Bar + Buttons/Links |
| Eindeutiges App-Icon | ✅ neu erstellt (Android + iOS) |
| AppBar mit Titel | ✅ auf allen Screens |
| ≥ 1 Asset-Bild, das bei Rotation fehlerfrei skaliert | ✅ Profilbild (`assets/images/profile.png`) |
| Einheitliches Farbschema (Continuity) | ✅ zentrales `AppTheme` |
| ≥ 1 Flutter-Package | ✅ `http`, `firebase_auth`, `firebase_core`, `provider`, `url_launcher` |
| Fehlerfrei im Emulator/Simulator | ⚠️ konnte ich nicht selbst testen (kein Flutter-SDK in meiner Umgebung) – bitte bei dir lokal verifizieren |
| Echte API-Daten | ❌ noch offen, Team-Aufgabe (siehe Punkt 4) |
| Geolocator für Land | ❌ noch offen, Team-Aufgabe |
| Material Theme | ✅ `ThemeData` in `main.dart` |

**Wichtiger Hinweis:** Die PDF nennt als Abgabetermin "22.06.2026, 23:59" – das aktuelle Datum ist aber bereits der 24.06.2026. Falls das kein Tippfehler in der Vorlage ist, prüfe bitte kurz mit deinem Professor/Team, ob sich euer tatsächlicher Abgabetermin verschoben hat.

## 6. Code-Qualität

Da in meiner Umgebung kein Flutter/Dart-Compiler verfügbar war, konnte ich den Code nicht selbst bauen oder ausführen. Ich habe stattdessen:
- jede bearbeitete Datei manuell durchgelesen,
- ein automatisiertes Skript über alle Klammern/Imports laufen lassen (keine Fehler gefunden),
- alle Imports/Klassennamen auf Konsistenz geprüft.

Trotzdem: führe nach dem ersten `flutter run` unbedingt selbst einen Blick über die Konsole, falls doch irgendwo ein Tippfehler durchgerutscht ist – das lässt sich dann sehr schnell fixen.
