# MOVA design spec

MOVA is a professional iPhone camera, a photo and video editor, and an AI studio built around one signature capability: **give it a reference video, it learns how that video was made, and it builds a genuinely new one from your own photo or footage.**

- Editable design canvas: the claude.ai Design artifact (26 boards).
- Static export: `design/screens/*.html` (open `design/index.html`).
- Demo video: `design/video/mova-demo-1080p.mp4` (49 s), portrait screen-only clip `mova-demo-portrait.mp4`.

## Brand

| | |
|---|---|
| Name | MOVA (from *movement*). Wordmark: Inter Bold, tracking 0.26–0.3 em |
| Mark | "Echo M": two strokes of the same M, the violet one offset behind the white one. Reference + yours = recreation |
| Personality | Sophisticated, cinematic, confident; minimal but never empty; advanced but never complicated |

## Tokens

| Token | Value | Use |
|---|---|---|
| `bg` | `#0A0A0C` | Media workspace, camera, editor |
| `surface` | `#121215` | Timeline, secondary panels |
| `elev` | `#1B1B20` | Cards, lists, fields |
| `elev2` / `elev3` | `#25252C` / `#30303A` | Secondary buttons, control tracks |
| `text` / `text2` / `text3` | `#F5F5F7` / `#A9A9B3` / `#8B8B96` | All pass 4.5:1 on `bg` |
| `accent` | `#8F7FFF` | **AI only**: analysis, generation, credits |
| `accent-ink` | `#5B47F0` | Filled AI buttons (white text 5.6:1) |
| `rec` | `#FF453A` | Recording only |
| Camera highlight | `#FFD60A` | Selected lens, focus box, active mode (iOS camera convention) |

Light appearance is defined for settings, profile and account surfaces (`.scr.light`). The camera, editor and players stay dark because media judgement needs a dark surround.

## Type (SwiftUI)

| Role | SwiftUI | Mock font |
|---|---|---|
| Editorial headline 34–42 | `.system(size:, design: .serif)` (New York) | Instrument Serif |
| Title / heading / body | SF Pro, Dynamic Type (`.title`, `.headline`, `.body`) | Inter |
| Labels, timecode, camera readouts | `.system(.caption, design: .monospaced)` + tabular digits | JetBrains Mono |

## Navigation

Five-destination floating **Liquid Glass** tab bar: Home · Discover · **Camera** (centre, raised white shutter) · Studio · Library. The camera opens full-screen and hides the tab bar. Glass is used only over media: tab bar, camera chrome, player controls, sheets.

## Screens (26 boards)

1. Product identity · 2. Design system
3. **01 Home**: "Create something.", the signature card, Take Photo / Record Video / Animate, recent activity, Continue creating, From Discover
4. **02 Camera (photo)**: grid, level, histogram, focus and exposure lock, EV slider, flash/timer/HEIF/RAW/aspect, readouts, lens 0.5–5×, modes
5. **02b Camera (recording)**: 4K·24·HEVC·LOG, REC timecode, storage estimate, USB-C mic meters, zebra, peaking, stabilization, pause, still-during-video
6. **02c Pro controls sheet**: format, frame rate, codec, Log, stabilization, audio input, shutter/ISO/WB/focus, assists, storage. ProRes and 120 fps at 4K are shown **unavailable with a reason**
7. **03–08 Reference recreation**: import → analysis (scene cards, shot boundaries, tags) → your media (violet frame = reference, white frame = yours) → customize (9 carry-over toggles, appearance, direction notes) → generation studio (cost, model, duration/aspect/resolution) → immersive result (takes, regenerate, new take, change prompt, edit, save, export)
9. **09 Animate**: motion path overlay, motion presets, "Talking · needs a face" disabled for a dog photo, 18 credits
10. **10 Restyle**: original / preview-frame split, prompt, style presets, intensity, keep people, free preview
11. **11 Discover**, **12 Template details**, **12b My templates (Template Factory)**: recipe = scene structure, timing, moves, transitions, look, prompt recipe, inputs, output; Private / In review / Published
12. **13 Photo editor**: before/after, ruler slider, adjustments, filters, crop, selective, send to AI Studio
13. **14 Video editor**: 9:16 preview, timecode, T / CC / V1 / A1 / A2 tracks, selected clip with trim handles, speed badge, transition marker, tools
14. **15 Library**: search, type filters, saved templates, badges (AI, Project, RAW, Draft, Imported)
15. **16 Assistant**: knows the timeline, selection and reference; proposes toggleable changes with per-change cost, Preview / Apply
16. **17 Profile**, **17b Camera prefs (light)**, **18 Subscription & credits**: capture free forever, transparent cost table, refunds on failure. Prices are `[PRICE]` placeholders
17. Connected workflows · States & edge cases (17 states)

## Product rules the design enforces

- Capture and editing never cost credits and never need a subscription.
- Every AI action shows its credit cost before the tap; failed or cancelled generations refund automatically.
- Progress shows real stages or real bytes and frames, never invented percentages.
- Unsupported device capabilities render as unavailable, with a reason, never as active.
- Reference and source media are always visually distinct (violet frame vs white frame).
- A generated result is a new video from the user's media, never the reference with a filter.

## Native implementation map

| Area | Framework |
|---|---|
| Camera capture, formats, Log, ProRes, RAW | AVFoundation (`AVCaptureDevice`, `AVCapturePhotoOutput`, `AVCaptureMovieFileOutput`), check `activeFormat`/`supportedColorSpaces` before enabling |
| Histogram, zebra, peaking overlays | Metal / Core Image on `AVCaptureVideoDataOutput` |
| Level | Core Motion |
| Photo edits | Core Image filters, `PHContentEditingOutput` |
| Video editor | AVFoundation compositions (`AVMutableComposition`, `AVVideoComposition`), AVKit player |
| Shot boundaries, poses, subject tracking (on-device pre-pass) | Vision (`VNDetectHumanBodyPoseRequest`, saliency, optical flow) |
| Library and import | PhotosUI `PHPickerViewController`, Files `UIDocumentPickerViewController` |
| Generation | Server-side video models; background `URLSession` uploads; push notification on completion |
| Purchases | StoreKit 2 (subscriptions plus consumable credit packs) |
| UI | SwiftUI, `.glassEffect()` Liquid Glass on iOS 26 for floating controls |
