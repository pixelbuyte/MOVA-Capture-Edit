---
name: vortex-particles-web
description: A canvas particle engine that ports twostraws/Vortex (SwiftUI particle effects) to the web with the same system fields, update math and preset values — spark, fireflies, magic, smoke, confetti — with brand-overridable colors. Use this whenever a web prototype, landing page or design artifact needs particles that should match a SwiftUI build using Vortex, or someone asks for sparks, fireflies, confetti, smoke or a "success burst", even if they don't name Vortex.
---

# Vortex particles for the web

`assets/vortex.js` is a faithful port of Vortex (github.com/twostraws/Vortex, MIT). The fields are the same as the Swift version: `birthRate`, `emissionDuration`, `idleDuration`, `lifespan`, `speed`, `speedVariation`, `angle`, `angleRange`, `acceleration`, `dampingFactor`, `colors` (single, ramp, random, randomRamp), `size`, `sizeVariation`, `sizeMultiplierAtDeath`, `stretchFactor` and `shape` (point, box, ellipse, ring). The update step copies `VortexSystem-Behavior.swift`, including the height/width divisor on x movement and damping relative to lifespan. A particle system designed on the web therefore carries straight into Swift.

## Load and mount
```html
<canvas id="fx" style="position:absolute;inset:0;width:100%;height:100%;pointer-events:none"></canvas>
<script src="vortex.js"></script>
<script>
  const fx = Vortex.mount(document.getElementById('fx'),
    Vortex.presets.spark({ ramp: ['#EDEAE3', '#EDEAE3', '#EDEAE300'], position: [0.5, 0.6] }));
</script>
```
`mount` returns `{ burst(n), move(x, y), stop(), system }`. Systems with `birthRate: 0` (confetti) emit only on `burst()`.

## Presets (values from Presets/*.swift)
- `spark`: 0.2 s bursts every 0.7 s, stretch 8, gravity. Use for "it worked".
- `fireflies`: ellipse field, particles grow ×100 as they fade. Use for ambient welcome or waiting moments.
- `magic`: ring, spinning, shrinking to 0.01. Use for transformations.
- `smoke`: slow, rising, doubling in size. Use for "processing" backdrops.
- `confetti`: squares that tumble on three axes and fall. Use for celebrations, sparingly.

Each preset takes overrides. Recolor with `ramp:` or `palette:` so particles use the brand's colors rather than Vortex's demo colors.

## Rules
- Particles are seasoning. Give each one a job, keep it short, and put it behind content (`pointer-events:none`).
- Reduced motion: `mount` returns a no-op. Never rely on particles to convey information.
- Cap density on phones: halve `birthRate` below 500 px wide.
- For SwiftUI handoff, name the preset and overrides (for example `VortexView(.spark)` with `colors: .ramp(...)`).

`assets/demo.html` runs all five presets.
