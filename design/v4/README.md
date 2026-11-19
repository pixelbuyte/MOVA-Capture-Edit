# MOVA v4: Teal & Tungsten

v3 was monochrome and used generic icons. v4 replaces that with a full color system taken from the cinema teal-and-orange grade, plus a real interactive prototype.

- **Open `index.html`**: a single-file prototype with 10 screens (Welcome, Studio, Reference, Breakdown, Camera, Result, Editor, Export, Library, You). Click through the whole recreation flow, or jump between screens from the left rail.
- **`mova-v4-walkthrough.mp4`**: a 54s screen recording of that flow, captured from the prototype itself.
- **`brand/`**: the design philosophy (`PHILOSOPHY.md`) and the key-visual poster (`key-visual.png`, built from `poster.html`).
- **`screens/`**: PNG captures of every screen and interaction state.
- **`img/`**: 8 art-directed frames, all generated in the same teal and orange grade.
- **`prototype/`**: the React 19 + Framer Motion source. Run `python3 make-imgs.py` to inline the images before building.

## System

| Role | Token | Value |
|---|---|---|
| Background | `--bg` | `#071416` teal-black ink |
| Text | `--text` | `#FBF3E8` cream |
| Action + AI | `--action` | `#FF7A2F` tungsten orange |
| Selection + data | `--select` | `#4FE0D0` teal |
| Coaching | `--warn` | `#FFC65E` amber |
| Record | `--rec` | `#FF4B3E` |

Type: Bricolage Grotesque (display), Instrument Sans (body), JetBrains Mono (timecode and scores). Icons: Phosphor duotone, tinted by meaning.

## Where each repo is used

| Repo | Ported as | Where it shows up in v4 |
|---|---|---|
| twostraws/Vortex | `skills/vortex-particles-web` | Fireflies on Welcome, spark on Result, confetti on Export |
| EmergeTools/Pow | `skills/pow-motion-web` | Film-exposure flash on capture, Snapshot reveal on Export, haptic events |
| mikelikesdesign/SwiftUI-experiments | `skills/swiftui-interactions-web` | Radial mode menu on the shutter (hold), 2D look trackpad |
| muhittincamdali/SwiftUI-Design-System-Pro | `skills/layered-design-tokens` | Three token layers and the Micro / Component / Page motion timings |
| meliwat/awesome-ios-design-md | `skills/ios-design-md-reference` | VSCO-style "color lives in the content" rule; TikTok and YouTube camera patterns |

## Verified

Playwright checks on the bundle:

- 0 broken images and 0 console errors.
- No text smaller than 10.5px.
- No horizontal scroll at 390px.
- Radial menu selects a mode by drag.
- The look pad changes the viewfinder filter.
- Recording advances the shot list.
- The compare slider drags.
- Export completes and shows the share panel.
