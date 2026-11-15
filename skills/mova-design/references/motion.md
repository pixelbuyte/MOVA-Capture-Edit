# MOVA motion

Motion explains cause and effect; it never decorates. Every effect below has one job. Load order at the end of `<body>`: `proto.js`, then anime.js 3.2.2 from cdnjs, then `motion.js`. A screen must be complete and usable with no motion at all (Reduce Motion, or the library failing to load).

| Effect | Attribute / API | Job | Haptic in the app |
|---|---|---|---|
| Entry | `data-enter` | Orient: content rises in, staggered 70 ms, once | none |
| Press | automatic on `.btn`, `.ibtn`, shutter | Confirm the touch | impact light; medium on shutter and Generate |
| Shine | `data-shine` | A value changed (credits) | none |
| Lane settle | automatic on `.lane__toggle` | Show what the toggle affected | selection |
| Develop | `data-develop="64%"` | A generated shot is being rendered (after Pow's Film Exposure) | none |
| Sparks | `data-sparks="ms"` or `movaSparks(x, y, host)` | Success, once, about 0.8 s (after Vortex's spark preset) | success |
| Fireflies | `data-fireflies="16"` | Ambient welcome only (after Vortex's fireflies) | none |
| Draw | `data-draw="delay"` on an `<svg>` | The mark or a camera path draws on first view | none |
| Timelines | push a function to `window.movaTimelines` | Screen-specific choreography (onboarding demos) | as above |

Durations come from `--dur-1…4`. Use `--ease-standard` for most things; the spring (`--ease-emphasized`, or anime's `spring()`) only for toggles, brackets and press release.

Don't loop anything except the onboarding demos, welcome fireflies, and progress that is genuinely in progress. Don't animate layout properties on long lists. Never add motion to text the user is reading.

SwiftUI mapping for the build phase: entry is `.transition(.opacity.combined(with: .offset(y: 12)))`, press is `.buttonStyle` with `.scaleEffect`, shine and develop are Pow's `.changeEffect(.shine)` and `.transition(.movingParts.filmExposure)`, sparks and fireflies are Vortex presets, and haptics use `.sensoryFeedback`. Gate all of it on `@Environment(\.accessibilityReduceMotion)`.
