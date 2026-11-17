# MOVA iOS app

Native SwiftUI app for iOS 17+, built from the hand-designed v5 screens in `design/v5`.

## Run it

You need a Mac with Xcode 15 or 16.

```sh
brew install xcodegen
cd app
xcodegen            # creates MOVA.xcodeproj from project.yml
open MOVA.xcodeproj
```

Pick an iPhone simulator and press Run.
- **On the Simulator:** there is no camera, so the camera screen shows a sample frame and recording is simulated. Every screen can still be tried.
- **On a real iPhone:** set your team under Signing & Capabilities.

Run the tests with ⌘U, or run the logic tests without Xcode using `cd Packages/MovaCore && swift test`. CI runs both on every push that touches `app/` (`.github/workflows/ios.yml`).

## Layout

| Path | What's there |
|---|---|
| `project.yml` | XcodeGen spec: targets, Info.plist keys (camera, mic, photos), fonts, packages |
| `Packages/MovaCore` | Plain Swift logic with unit tests: shot plans (split/merge), beat map and cut timing, match score and framing tips, export estimates, sample data |
| `MOVA/App` | `MOVAApp`, `RootView` (tabs + navigation stack + camera cover), `AppModel` (state, routes, looks, library) |
| `MOVA/DesignSystem` | v5 tokens: colours, Bricolage Grotesque + DM Mono, spacing, motion, haptics, Phosphor `Icon` |
| `MOVA/Components` | Shot bar, match ring, glass, buttons, chips, segmented control, toggle, tab bar |
| `MOVA/Screens` | The 15 screens (01 Camera … 15 Empty Library) |
| `MOVA/Services` | `CameraService` (AVFoundation capture + recording), `ClipAnalyzing` protocol + `MockClipAnalyzer` |
| `MOVA/Resources` | Fonts (OFL), asset catalog with app icon and real sample photos (Unsplash) |

## Screen map

| # | Screen | File |
|---|---|---|
| 01 | Recreate camera | `CameraView.swift` |
| 02 | Welcome | `WelcomeView.swift` |
| 03 | Studio | `StudioView.swift` |
| 04 | Reference | `ReferenceView.swift` |
| 05 | Shot breakdown | `BreakdownView.swift` |
| 06 | Result | `ResultView.swift` |
| 07 | Editor | `EditorView.swift` |
| 08 | Export | `ExportView.swift` |
| 09 | Library | `LibraryView.swift` |
| 10 | You / Settings | `SettingsView.swift` |
| 11 | MOVA Pro | `PaywallView.swift` |
| 12 | Exporting | `ExportingView.swift` |
| 13 | Camera access | `CameraPermissionView.swift` |
| 14 | Couldn't break down clip | `AnalysisFailedView.swift` |
| 15 | Empty Library | `LibraryEmptyView.swift` |

## What's real and what's a stand-in

**Real**
- Navigation and every screen.
- The camera:
  - permissions;
  - live preview, front/back flip;
  - recording each shot to a file, timed to the shot length.
- Shot, beat and score logic, with tests.
- Looks applied to the preview.
- Settings state.

**Stand-ins, each marked `TODO` in code**
- **Clip analysis:** `MockClipAnalyzer` returns the sample shot plan. It fails on purpose for test links containing `private`, `short`, `nocuts` or `offline`, so screen 14 can be tried.
- **Live match score:** the score and framing tip use a fixed demo subject box. Real subject detection would use Vision.
- **Your-take scoring:** the Result screen uses the sample score.
- **Export:** progress is simulated. A real export would use `AVMutableComposition` + `AVAssetExportSession` + `PHPhotoLibrary`.
- **Purchases:** the paywall prices are placeholders; a real purchase would use StoreKit 2.
