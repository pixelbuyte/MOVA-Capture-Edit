---
name: swiftui-interactions-web
description: Web ports of interaction patterns from mikelikesdesign/SwiftUI-experiments that suit camera, photo and video apps — a press-and-drag radial menu, a two-axis trackpad slider with detent feedback, a colour-cycling glow trail, and a distance-scaled tilt grid — each keeping the experiment's own math. Use this when prototyping mobile interactions on the web that should feel native and tactile, e.g. a mode switcher, a two-dimensional "look" picker, a playful touch trail, or a gallery that reacts to the finger.
---

# SwiftUI-experiments interactions for the web

`assets/interactions.js` ports four experiments from github.com/mikelikesdesign/SwiftUI-experiments (MIT). The author calls them prototypes, not production code. These ports are the same: they're for design prototypes.

| Function | Source experiment | What it keeps | Good for |
|---|---|---|---|
| `Interactions.RadialMenu(el, {items, onSelect})` | radial menu | Segment from `atan2`; selected segment expands by `0.3·(1−e^(−d/50))` as you drag further | Press-and-hold the shutter, drag to a mode (Photo, Video, Recreate) |
| `Interactions.Trackpad2D(el, {x, y, steps, onChange})` | draggable slider | 2D knob, the pad tilts toward the finger, soft detents fire a haptic on each cell | Picking a look on two axes (warm↔cool × soft↔punchy) |
| `Interactions.GlowTrail(canvas, {hue})` | colorful glow | Hue cycles with age, blur `30 − age·10`, fade over 3 s, 100-point cap | A touch-to-paint moment, onboarding delight |
| `Interactions.TiltGrid(el, {strength})` | tilt grid | Children shrink with distance from the focus point | Galleries and template shelves that respond to the finger |

`RadialMenu` exposes `openAt(x, y)`, `move(x, y)` and `release()`, so you wire it to your own long-press. Haptics go through `Pow.haptic` when pow-motion-web is loaded.

Required CSS (adapt to your tokens):
```css
.rm{position:absolute;width:0;height:0;pointer-events:none;opacity:0;transition:opacity .2s}
.rm.is-open{opacity:1;pointer-events:auto}
.rm__item{position:absolute;left:-28px;top:-28px;width:56px;height:56px;border-radius:50%;transform:translate(var(--x),var(--y));transition:transform .25s cubic-bezier(.3,1.35,.55,1)}
.tp{position:relative;border-radius:24px;transform:perspective(600px) rotateX(var(--rx,0)) rotateY(var(--ry,0));transition:transform .3s}
.tp__knob{position:absolute;left:0;top:0;width:30px;height:30px;border-radius:50%}
```
Keyboard: Trackpad2D takes arrow keys, and every RadialMenu item is a real button.
