# MOVA components

All live in `assets/components.css`. Icons: `<svg class="ic" aria-hidden="true"><use href="../icons.svg#name"/></svg>` (sizes `ic--xs` 14, `ic--sm` 18, default 22, `ic--lg` 28).

## Contents
Frame · Navigation · Buttons · Choice controls · Lists · Media · Recreation-specific · Feedback · Icons list

## Frame
```html
<main class="screen top">            <!-- 390×844; .top pads --safe-top; .screen--media for full-bleed dark -->
  …
  <div class="actionbar"><a class="btn btn--primary" href="next.html">Continue</a></div>
  <div class="home-indicator"></div>
</main>
```
Helpers: `.pad` (gutter), `.row`, `.row--between`, `.stack`, `.grow`, `.hr`. Type classes: `.display` `.title1` `.title2` `.headline` `.body` `.callout` `.caption` `.tc` (mono timecode) `.label` (caps).

## Navigation
- `.navbar` – 3-column bar: back · `.navbar__title` (+ `.navbar__sub tc`) · trailing action.
- `.flowhead` + `.flowsteps` (`i.done`, `i.now`) – the recreation flow's step header. Don't add a second "Step 3" label.
- `.tabbar` – glass capsule (`.tabbar__tabs` with `aria-current="page"`) plus a separate `.tabbar__shutter` that opens the camera. Only on Home, Discover, Studio and Library roots.
- `.sheet` + `.sheet__grabber` – bottom sheets.

## Buttons (four kinds, each with one job)
| Class | Use | Note |
|---|---|---|
| `.btn.btn--primary` | Continue, save, confirm | White |
| `.btn.btn--ai` | The action that spends credits | Max one per screen; append `<span class="btn__cost">· 36 cr</span>` |
| `.btn.btn--secondary` | Alternatives | |
| `.btn.btn--plain` | Low-emphasis text actions | |
| `.btn--sm` | Compact, in toolbars | |
| `.ibtn` (+ `--glass`, `--fill`) | Icon buttons, 44pt | Needs `aria-label` |

## Choice controls (pick by the kind of choice)
- **Rail** – switching views or filters: `<div class="rail" role="tablist" data-choice="aria-selected"><button role="tab" data-opt aria-selected="true">All</button>…</div>`
- **Picker** – 2–4 discrete values (length, aspect): `<div class="picker" role="radiogroup" data-choice><button class="picker__opt" role="radio" data-opt aria-checked="true">12 s</button>…</div>`
- **Ruler** – manual dials (ISO, shutter, adjustments, speed): `<div class="ruler" data-ruler data-values="1/125,1/250,1/500" data-index="1" data-out="id" role="slider" tabindex="0" aria-label="Shutter speed"><div class="ruler__ticks"></div><div class="ruler__needle"></div></div>` (`.ruler--neutral` outside the camera)
- **Slider** – continuous values: `.slider` (+ `.slider--temp` for white balance) with `data-slider data-min data-max data-step data-unit data-out`.
- **Switch** – on/off settings: `<button class="switch" role="switch" aria-checked="true" aria-label="…"></button>`
- **Look strip** – visual styles rendered on the user's own media: `.looks` > `.look.vf` (`.look__img`, `.look__name`).
- **Lanes** – what carries over from a reference (see Recreation).

## Lists
`.group` > `.cell` (+ `.cell__glyph`, `.cell__value`) for settings; `.readout` (`dl` with `dt`/`dd`) for spec tables; `.section-label` above a group.

## Media
`.media` (+ `img`), `.media__tc` (duration), `.media__scrim`, `.media__mark` (`--ai` variant). Tags: `.src.src--ref` / `.src.src--yours`, add `.src--chip` over photos. Selection: add `.vf` and set `aria-selected`/`aria-checked`. `.vf--ref` uses accent brackets.

## Recreation-specific
- `.shotmap` > `.shot.vf` (proportional `flex` = duration, `data-shot` JSON drives `[data-bind]` targets) + `.playhead`, `.shot__cut` transition glyph.
- `.campath` – top-down camera path SVG (`.subject`, `.path`, `.cam`, `.fov`, `<animateMotion>` or a rotating group).
- `.lanes` > `.lane[data-lane][data-state="ref|off|edit"]` (`.lane__name`, `.lane__cells` > `.lane__cell`, `.lane__toggle` with `aria-pressed` and `aria-label`). `[data-carry-count]` shows how many are on.
- `.lightdial[data-dial]` – drag the key light around the subject; `[data-dial-out]` shows direction.
- `.wipe[data-wipe]` – compare (`.wipe__top`, `.wipe__bar`, `.wipe__knob`), role=slider.
- `.board` > `.board__frame` + `.board__glyph` – storyboard frames.
- `.segprog` > `i.done` / `i.now` (`--p`) – one segment per shot.

## Feedback
`.toast` (status), `.skeleton` (shimmer, honest placeholder), `.credits` (meter chip, add `data-shine` when it changes), `.field` (+ `--placeholder`), `.home-indicator`.

## Icons in the sprite
home discover camera spark studio library search plus close back chev chevdown play pause check bolt timer flip lock sun mic heart share save scissors trim text music speed transition drop undo redo more person bell shield storage help credit film photo sliders layers offline alert refresh compare orbit crane pushin track person-move frame pace wave cloud clock filter crop aperture eye link folder reset wand tag stack
