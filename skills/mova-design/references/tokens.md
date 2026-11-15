# MOVA tokens

Three layers, each allowed to read only the one below it:

| Layer | File | Holds | Who may reference it |
|---|---|---|---|
| 1 Primitives | `tokens/primitives.css` | Raw values named by what they are (`--gray-950`, `--peri-300`, `--space-4`) | Only `semantic.css` |
| 2 Semantic | `tokens/semantic.css` | Roles named by what they're for (`--surface-2`, `--accent`, `--t-body`) | Components and screens |
| 3 Component | `tokens/component.css` | Per-component decisions (`--button-height`, `--lane-label-size`) | Components and screens |

Why three layers: a direction or theme is a different mapping of layer 2 onto layer 1, so `data-direction="darkroom"` re-themes every screen without touching a component. Layer 3 lets you tune one component (say, lane cell height) everywhere at once.

## Directions

| Direction | Selector | Status | Character |
|---|---|---|---|
| A · Monitor | `:root` | **Chosen** | Graphite, periwinkle intelligence, white selection |
| B · Darkroom | `[data-direction="darkroom"]` | Explored | Warm umber blacks, safelight-orange accent, film-lab feel |
| C · Lumen | `[data-direction="lumen"]` | Explored | Paper ground, ink type, deeper periwinkle; camera and players stay dark |

Preview any screen in a direction with `?direction=darkroom` or `?direction=lumen` (handled by `motion.js`).

## Roles

**Surfaces**: `--canvas` (camera, players, full-bleed media) · `--surface-1` (screen) · `--surface-2` (grouped rows, sheets, fields) · `--surface-3` (controls at rest) · `--surface-4` (pressed, selected fill, tracks) · `--hairline`, `--hairline-strong` (separators) · `--material`, `--material-border`, `--material-sheen` (Liquid Glass stand-in, only over media) · `--overlay` (dark backing for text over photos) · `--scrim-top`, `--scrim-bottom`.

**Text**: `--text-1` (primary) · `--text-2` (secondary, 7.6:1) · `--text-3` (tertiary, ≥4.5:1 even on surface-4) · `--text-disabled` · `--on-media`, `--on-media-accent` (over photos, every direction).

**Selection**: `--select`, `--on-select` (white button, white brackets).

**Intelligence**: `--accent` (AI marks and data, 8.7:1) · `--accent-fill` (the single AI button) · `--accent-wash`, `--accent-line`.

**Signals**: `--rec` recording · `--cam` focus/lens/manual exposure · `--positive` done · `--caution` fix suggested · `--critical` failed · `--temp-cool`, `--temp-warm` white-balance ends · `--glow-warm` key-light glow.

**Type**: `--font-ui`, `--font-display` (serif, editorial only), `--font-mono` (timecode, readouts). Sizes: `--t-display` 40 · `--t-title1` 28 · `--t-title2` 21 · `--t-headline` 16 · `--t-body` 15 · `--t-callout` 13 · `--t-caption` 12 · `--t-micro` 11 (floor). Each has a matching `--lh-*`. `--track-tight`, `--track-caps`.

**Space**: `--sp-1` 4 … `--sp-12` 48 on a 4pt grid · `--gutter` 20 · `--safe-top` 54 · `--safe-bottom` 34.

**Shape**: `--r-1` 6 (filmstrip frames) · `--r-2` 10 (controls, small media) · `--r-3` 16 (buttons, media tiles) · `--r-4` 24 (sheets, hero media) · `--r-round`.

**Motion**: `--dur-1` 120 press · `--dur-2` 220 select · `--dur-3` 380 screen/sheet · `--dur-4` 700 AI reveal · `--ease-standard` · `--ease-emphasized` (spring, sparingly). All durations become 0 under Reduce Motion.

**Component tokens**: `--tap-min` 44 · `--button-*` · `--tabbar-*` · `--lane-*` · `--bracket-*` · `--shot-height` · `--ruler-needle` · `--wipe-knob` · `--sheet-radius`.

## Adding a token

Need a new value? Decide which layer it belongs to:
- A new raw color or size: add a primitive, then map it in semantic.
- A new meaning: add a semantic role. Name it for the job (`--badge-draft`), not the look (`--orange`).
- A one-component decision: add it to `component.css`.

Never reference a primitive from a screen; `check_screen.py` flags it.
