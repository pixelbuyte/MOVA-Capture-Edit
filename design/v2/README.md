# MOVA design v2 · "Monitor"

Design-phase only. HTML/CSS mockups with light prototype behaviour; no app code.

Open `index.html` through a local server (`python3 -m http.server` in this folder) for the full review: audit, system, signature flow, live prototype, every screen, states, and the before-and-after.

| Path | What it is |
|---|---|
| `tokens.css` | The only place values live: surfaces, text, accent, signals, type scale, 4pt spacing, radii, motion, haptic annotations |
| `components.css` | 28 components built only from tokens (no raw colors): buttons, rail, picker, ruler, slider, switch, grouped list, media, viewfinder brackets, source tags, shot map, readout, camera path, lanes, light dial, look strip, compare wipe, storyboard, segmented progress, credit meter, tab bar, sheet, field, toast, flow header |
| `icons.svg` | 70-symbol sprite on a 24pt grid, 1.6 stroke, SF Symbols "regular" weight |
| `proto.js` | Shared behaviours: choices, shot map, lanes, wipe, light dial, sliders, rulers, switches, play toggles. Pointer and keyboard, ARIA state, Reduce Motion |
| `screens/` | 27 screens at 390 × 844, linked to each other |
| `shots/` | 2× screenshots of v2, and `shots/v1/` of the previous design |

## Rules the system enforces

- Periwinkle (`--accent`) means MOVA's intelligence: AI marks, AI-derived data, credits, and at most one AI button per screen.
- Selection is white, framed with viewfinder brackets. No colored outlines.
- `--rec` is recording only; `--cam` is camera focus and lens only.
- The serif is for editorial moments only. Mono is for timecode and readouts.
- Each kind of choice has its own control: rail for views, picker for discrete values, ruler for manual dials, lanes for carry-over, switch for settings.
- Every target is at least 44 pt, and every text token is at least 4.5:1 on the surfaces it sits on.
- Progress shows real stages, frames and bytes. Failed AI work refunds credits, and the screen says so.
