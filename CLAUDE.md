# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build commands

Xcode is at `/Applications/Xcode-26.5.0.app`. Always prefix xcodebuild and xcrun with:
```
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer
```

Build for simulator (both architectures):
```bash
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer \
  xcodebuild -project AchtUndPunkt.xcodeproj -scheme AchtUndPunkt \
  -destination 'generic/platform=iOS Simulator' -configuration Debug build
```

Build and run on the booted iPhone 17 Pro (iOS 26.5, ID `6DC4A4A3-2965-4371-8542-5412C3552495`):
```bash
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer \
  xcodebuild -project AchtUndPunkt.xcodeproj -scheme AchtUndPunkt \
  -destination 'id=6DC4A4A3-2965-4371-8542-5412C3552495' -configuration Debug build
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer \
  xcrun simctl install booted <path-to-.app> && xcrun simctl launch booted dev.lars-richter.AchtUndPunkt
```

iOS 16 regression simulator (iPhone 14, ID `73918B7F-E9A2-4127-A399-2AEAFDDE6298`, needs booting):
```bash
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcrun simctl boot 73918B7F-E9A2-4127-A399-2AEAFDDE6298
```

The app binary ends up at:
```
~/Library/Developer/Xcode/DerivedData/AchtUndPunkt-*/Build/Products/Debug-iphonesimulator/AchtUndPunkt.app
```

Screenshot a running simulator:
```bash
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer \
  xcrun simctl io booted screenshot /tmp/screen.png
```

There are no automated tests.

## Architecture

Single-target SwiftUI app (iOS 16+, iPhone + iPad). All state lives in one `GameViewModel` (`ObservableObject`) owned as `@StateObject` in `ContentView`.

### Game flow

`GamePhase` (enum with associated value) drives the entire UI:
- `.setup` → `PlayerSetupView` (2–6 players, names)
- `.playing(round: Int)` → `RoundView` (score entry per round, 5 rounds total)
- `.finished` → `WinnerView` (final standings, confetti)

`ContentView` switches on `GamePhase` and applies spring transitions between screens. `RoundView` is given `.id(round)` so SwiftUI recreates it — and resets all `@State` — automatically on each round advance.

### Data model

`Player` is a value type (struct). `GameViewModel` holds `@Published var players: [Player]` and mutates elements by index. Scores are stored as `[Int?]` — `nil` means not yet entered for that round.

Scores are committed from local `@State` string inputs in `RoundView` only when the user taps "Nächste Runde" / "Endergebnis anzeigen". Until then, edits are local to the view.

**Important:** highest total wins. The game rulebook actually awards points (higher = better); `sortedByTotal` sorts descending.

### Theme system (`Theme.swift`)

All colours, player palette, and reusable components live here:
- `SkyBackground` — full-screen sky gradient + wavy grass strip (used by all three screens)
- `ClayLabel` — bold rounded text with a dark shadow offset, mimicking the claymation box art
- `ClayCard` — white card with soft shadow, accepts a fill colour
- `ChunkyButtonStyle` — pill button with a bottom-shadow "raised" effect
- `SpeechBubble` / `BlobShape` — green rounded blob used for section headers

### iPad adaptation

Each view reads `@Environment(\.horizontalSizeClass)` and branches on `.regular`:
- `PlayerSetupView`: 700pt max-width column, 2-column player grid
- `RoundView`: 2-column `LazyVGrid` for score cards, 500pt max-width action button
- `WinnerView`: side-by-side HStack (trophy left at fixed 320pt, standings table right)

### Score entry UX

`RoundView` has an `achtUndAusPlayer: UUID?` state. Tapping the "8!" button on a player card marks them as the round winner, prefills their score with 16, and clears any previously marked player's prefill if it is still "16".

### Debug-only icon export

`AppIconView` (scalable, default 1024×1024) + `IconExportSheet` (renders via `ImageRenderer` at scale 1.0 → exact 1024 px, shares as PNG via `ShareLink`) are compiled into all builds, but the trigger — a small `app.fill` button in the top-trailing corner of `PlayerSetupView` — is wrapped in `#if DEBUG` and absent from Release builds.

### Orientation

Portrait-only on iPhone. iPad allows portrait + portrait-upside-down. Configured via `INFOPLIST_KEY_UISupportedInterfaceOrientations_*` in `project.pbxproj` (not in an Info.plist file).

### Compatibility notes

- `@Observable` / `@Bindable` are **not** used — the project targets iOS 16 which predates the Observation framework. Use `ObservableObject` + `@Published` + `@ObservedObject` / `@StateObject`.
- `Text.foregroundStyle()` on `TextField` prompts requires iOS 17; use `.foregroundColor()` there instead.
- `ShareLink` and `ImageRenderer` are iOS 16+ — fine for this target.
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set project-wide.
- The project uses `PBXFileSystemSynchronizedRootGroup` (Xcode 16+), so new `.swift` files placed in `AchtUndPunkt/` are picked up automatically without editing `project.pbxproj`.
