---
name: pow-motion-web
description: Web (HTML/CSS/JS) ports of EmergeTools/Pow's SwiftUI transitions and change effects, using Pow's exact formulas: film exposure, snapshot, iris, wipe, glare, blur, pop, shine, and Pow's damped spring. Use this whenever a web prototype, HTML mockup or design artifact needs iOS-style reveal transitions or "something changed" feedback that should match what a SwiftUI build with Pow would do, including when someone says "make it feel like Pow", asks for a film-exposure or iris reveal, a shine on a value, or spring physics in a prototype.
---

# Pow motion for the web

`assets/pow.js` ports Pow (github.com/EmergeTools/Pow, MIT) so that a web prototype animates the way the shipped SwiftUI app will. The value of using it over ad-hoc CSS is fidelity. Each function maps progress `p` (0 to 1) with the same math as the Swift modifier, so a designer's prototype and the engineer's `.transition(.movingParts.filmExposure)` look the same.

## Load
```html
<script src="pow.js"></script>
```
Exposes `window.Pow`.

## API
| Call | Pow source | Use it for |
|---|---|---|
| `Pow.transition(el, 'filmExposure', {duration})` | Transitions/FilmExposure.swift (ExposureFade): opacity 1−2^(−10p), brightness −(1−p) | A photo or rendered frame "developing" into view |
| `Pow.transition(el, 'snapshot')` | FilmExposure.swift (Snapshot): saturation/contrast .5+.5p, brightness +.85(1−p), blur 5(1−p) | A capture flashing in after the shutter |
| `Pow.transition(el, 'iris', {origin:[x,y], blur})` | Transitions/Iris.swift | Revealing from a tap point or a lens |
| `Pow.transition(el, 'wipe', {angle, blur})` | Transitions/Wipe.swift | Before/after reveals |
| `Pow.transition(el, 'glare', {angle, color})` | Transitions/Glare.swift (mask to 1.6p, glare band p…1.6p) | A premium reveal of a finished result |
| `Pow.transition(el, 'blur', {radius})` / `'pop'` | Blur.swift / Pop.swift | Quiet entrances |
| `Pow.change(el, 'shine', {duration, angle})` | Effects/ShineEffect.swift (sin² band, fade 1−f^8) | A value changed: credits, a saved state |
| `Pow.spring({stiffness, damping})` | Infrastructure/Spring.swift (zeta form) | Easing for any of the above |
| `Pow.haptic(kind)` | Effects/HapticFeedbackEffect.swift | Emits `pow:haptic` so a prototype can show where the device would tap |

Pass `{out: true}` to run a transition as a removal.

## Rules
- Reduced motion jumps straight to the end state; nothing else needs handling.
- One transition per moment. Pow effects are punctuation, so stacking them reads as noise.
- When you hand off to SwiftUI, name the Pow call in your notes (for example `.transition(.movingParts.filmExposure)` or `.changeEffect(.shine, value: credits)`) so engineering can match it.

`assets/demo.html` shows every effect side by side.
