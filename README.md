# 8 und Punkt!

**Der digitale Punktezettel für euren Kartenspielabend.**

Schluss mit Zetteln, die verschwinden, und Streit über unleserliche Zahlen. Tragt die Namen ein, spielt — und die App rechnet.

<p align="center">
  <img src="Screenshots/iPhone-67/1-setup.png" width="220" alt="Spieler einrichten">
  <img src="Screenshots/iPhone-67/2-playing.png" width="220" alt="Runde spielen">
  <img src="Screenshots/iPhone-67/3-finished.png" width="220" alt="Endergebnis">
</p>

---

## Features

- **2–6 Spieler:innen** — Namen eintragen, Spiel starten
- **5 Runden** — Punkte pro Runde eintragen, Gesamtpunktzahl wird laufend berechnet
- **8 und Aus!** — Ein Tipp markiert den Rundensieger und trägt automatisch 16 Punkte ein
- **Endergebnis** — Vollständige Tabelle mit allen Rundenwerten und Gesamtpunkten
- **iPhone & iPad** — Native SwiftUI, für beide optimiert
- **Kein Account, keine Werbung, keine Daten** — Die App funktioniert vollständig offline

---

## Tech

| | |
|---|---|
| **Platform** | iOS 16+ / iPadOS 16+ |
| **Language** | Swift 5.9 |
| **UI** | SwiftUI |
| **Architecture** | Single `ObservableObject` (`GameViewModel`) driving three screens via `GamePhase` enum |
| **No dependencies** | Pure SwiftUI, no third-party packages |

---

## Project structure

```
AchtUndPunkt/
├── Models.swift          # Player, GamePhase, GameViewModel
├── ContentView.swift     # Root: switches on GamePhase, applies transitions
├── PlayerSetupView.swift # Screen 1: player names (2–6)
├── RoundView.swift       # Screen 2: score entry per round
├── WinnerView.swift      # Screen 3: trophy, winner, full standings table
├── Theme.swift           # Colours, SkyBackground, ClayLabel, ClayCard, …
└── AppIconView.swift     # Scalable icon + debug export sheet
```

---

## Building

Requires **Xcode 16+**. Open `AchtUndPunkt.xcodeproj` and hit Run — no additional setup needed.

The project uses `PBXFileSystemSynchronizedRootGroup`, so new `.swift` files dropped into `AchtUndPunkt/` are picked up automatically without touching `project.pbxproj`.

### Screenshots

The screenshot mode is baked into the app via launch arguments, making it easy to regenerate all App Store screenshots from the terminal:

```bash
# Boot simulators, install, then:
xcrun simctl launch <device-id> dev.lars-richter.AchtUndPunkt                    # setup screen
xcrun simctl launch <device-id> dev.lars-richter.AchtUndPunkt --screenshot-playing   # round screen
xcrun simctl launch <device-id> dev.lars-richter.AchtUndPunkt --screenshot-finished  # results screen
xcrun simctl io   <device-id> screenshot output.png
```

---

## License

MIT © 2026 Lars Richter
