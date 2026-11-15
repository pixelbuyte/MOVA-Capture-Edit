---
name: mova-design
description: Design and build on-brand screens, flows and states for MOVA, the iPhone camera, video editor and AI reference-recreation studio, as HTML/CSS mockups that use MOVA's three token layers (primitives, semantic, component), its component library, icon sprite and motion layer. Use this whenever the user asks for a new MOVA screen, a redesign or variant of an existing one, an empty, loading or error state, an onboarding step, an App Store screenshot, a motion spec, or anything that must "look like MOVA", even if they only describe the feature ("design the export sheet", "add a screen for sharing a recipe") and never say "design system".
---

# MOVA design

MOVA is a premium creative tool: a pro camera, an editor, and an AI studio that turns a reference video into a new one starring the user's own media. Its look is called **Monitor**: a cinema field monitor, where the picture is the only real color and the chrome reads like instrument readouts. Good MOVA screens feel calm, precise and media-first. Generic AI-app tropes (purple gradients, outlined cards everywhere, rows of pills, chat bubbles for everything) are what this skill exists to prevent.

## What's bundled

```
assets/
  tokens/primitives.css   layer 1: raw values (never referenced by screens)
  tokens/semantic.css     layer 2: roles (+ the Darkroom and Lumen directions)
  tokens/component.css    layer 3: per-component decisions
  components.css          the component library (reads layers 2–3 only)
  icons.svg               70-symbol sprite, 24pt grid, 1.6 stroke
  proto.js                behaviours: choices, lanes, wipe, dial, sliders, rulers, switches
  motion.js               anime.js 3.2.2 motion layer (entry, press, shine, develop, sparks, fireflies, draw)
  screen-template.html    the starting file for every new screen
references/
  tokens.md               every role and when to use it        (read before choosing a color, size or space)
  components.md           every component with markup          (read before building any control)
  motion.md               motion and haptic rules               (read before adding animation)
  process.md              concept → directions → critique       (read for new features or redesigns)
scripts/
  check_screen.py         validates a screen against the rules below
```

## Workflow

1. **Understand the job of the screen.** One screen answers one question for the user ("which seconds should we recreate?", "what carries over?"). Write that question down before designing; if you can't, the screen is doing two jobs.
2. **For a new feature or redesign, read `references/process.md`** and sketch at least two directions in words before building. For a small addition to an existing flow, skip to step 3.
3. **Start from `assets/screen-template.html`.** Copy the `assets/` folder next to your screens folder so the relative links (`../tokens/…`, `../components.css`, `../icons.svg`) resolve. Keep the frame at 390 × 844 (iPhone 15/16 points) with `--safe-top` and `--safe-bottom` left empty; never draw a fake status bar.
4. **Build from components, then tokens.** Look up the control in `references/components.md` first. Only write local CSS for layout (position, grid, size), and take every color, type size, radius, space and duration from semantic or component tokens. If a value you need doesn't exist, add it to `component.css` with a role name rather than hard-coding it, and say so in your reply.
5. **Use real content.** Real-sounding titles ("Golden hour walk"), real units (0:07–0:12, 41 / 120 frames, 36 credits), images from the project's `img/` folder. Unknown business facts like prices become `[PRICE]`.
6. **Run the checker:** `python scripts/check_screen.py path/to/screen.html` (or a folder). Fix every error. Warnings are judgement calls; fix or explain them.
7. **Render and look.** Screenshot at 390 × 844 (Playwright is fine) and check the result. Look for clipped text, content hidden behind the action bar or tab bar, and unreadable text over photos. One look, one round of fixes.

## The rules that make it MOVA

These come from auditing what made earlier versions feel generated. Each one has a reason; keep the reason in mind when a case is borderline.

- **Periwinkle means intelligence.** `--accent` marks AI-derived data, AI actions and credits. If it's used for decoration, links, or selection, users can no longer spot what the AI did. One `btn--ai` per screen, maximum: it's the button that spends credits.
- **Selection is white, shown with viewfinder brackets** (`.vf` + `aria-selected`/`aria-checked`), not colored outlines. Brackets borrow the camera's own focus language.
- **Each signal has one meaning.** `--rec` is only recording. `--cam` (yellow) is only focus, lens and manual exposure inside the camera. `--positive`, `--caution` and `--critical` are for status. Never reuse them as decoration.
- **Reference vs your media is always explicit.** Use `.src--ref` (diamond) and `.src--yours` (dot) tags, with `.src--chip` over photos. Never rely on a colored frame alone.
- **One control per kind of choice.** Rail for switching views, picker for a few discrete values, ruler for manual dials, lanes for carry-over, switch for settings. A row of pills is almost always one of these in disguise.
- **Depth comes from fill, not outlines.** Five surfaces (`--surface-1` … `--surface-4`, `--canvas`) plus hairlines. Avoid cards inside cards; use a grouped list or a readout table.
- **Type has a floor and a voice.** Nothing ships below `--t-micro` (11px). The serif (`--font-display`) is for editorial moments only: Home's greeting, a finished film's title, an empty state. Mono (`--font-mono`) is for timecode and readouts. Everything else is the UI sans.
- **Text over media uses `--on-media`.** It stays light in every direction and always sits on a scrim or `--overlay`.
- **Honest states.** Progress shows real stages, frames or bytes, never invented percentages. Failed AI work says which shot failed, why, how to fix it, and that credits were returned.
- **44pt targets** (`--tap-min`) for everything tappable. Icon-only buttons get an `aria-label`.
- **The camera and editing never cost credits.** Any screen that touches money says so where relevant.

## Output

Unless asked otherwise, deliver: the screen file(s), a screenshot of each at 390 × 844, and a short note listing which components you used, any token you added, and the checker result. When you explore directions, render each one, critique it in two or three lines, and say which you chose and why.
