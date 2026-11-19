# Designing a new MOVA feature

Adapted from a "stop making apps look like AI slop" workflow: concept → directions → design → render → critique → refine. The point is to make the obvious, generic answer compete with better ones before any of it gets built.

## 1. Concept (in words, before any markup)
- **The question** this screen answers for the user, in their words.
- **What the AI knows** that the user can't see yet. MOVA's signature move is making the AI's understanding visible and editable: shots, camera paths, light direction, pacing. If a screen hides that behind a toggle, look for a way to show it.
- **The one action** that moves them forward, and whether it spends credits.

## 2. Two or three directions
Describe each in two sentences: layout idea plus the one distinctive element. For example, for "choose what carries over": (a) a grid of toggles, the generic answer, written down so it can lose; (b) lanes per characteristic across the reference's shots; (c) a single preview with tappable hotspots. Pick by: does it show real data? Is it one control per kind of choice? Does it work at 390pt without tiny text?

For visual-direction work, render the same screen in Monitor, Darkroom and Lumen (`?direction=`) and compare.

## 3. Design and render
Build from `screen-template.html`, components first. Render at 390 × 844.

## 4. Critique: look for these generated-looking tells
- Purple (or any accent) outlines on many elements; accent used for non-AI things
- Rows of identical pills or chips
- Cards inside cards; every block with the same radius and shadow
- Marketing headlines in task screens ("Unleash your creativity")
- Percent progress bars for AI work; fake status bars
- Text under 11px, or light text over a bright photo without a scrim
- Two primary buttons; more than one AI button
- Everything centered; generic gradient backgrounds

## 5. Refine
Fix what the critique found, run `scripts/check_screen.py`, render once more, done. State what you changed and why in the reply.

## Checklist before you hand over
- [ ] Checker passes
- [ ] One job, one primary action, at most one AI action (with its cost)
- [ ] Reference vs yours is unmistakable
- [ ] Real content and units; `[PRICE]` for unknown prices
- [ ] Loading, empty and error versions considered (design them if the feature can fail)
- [ ] Works with no motion
