---
name: ios-design-md-reference
description: Reference design-system specs (DESIGN.md format, from meliwat/awesome-ios-design-md) for camera, photo and video apps — VSCO, Midjourney, Instagram, TikTok, YouTube, Apple TV — plus how to extract principles from them without cloning their look. Use this when designing or critiquing a premium iOS creative, camera, photo, video or media app and you want grounded references for colour roles, type, controls and do's/don'ts, or when the user asks "how would VSCO/Instagram/TikTok handle this".
---

# iOS design references for creative apps

`references/` holds six DESIGN.md packs from github.com/meliwat/awesome-ios-design-md (MIT). Each pack has nine sections: visual theme, color roles, typography, component states, layout, depth, do's and don'ts, responsive behavior, and an agent prompt guide. Brand names and logos belong to their owners. The packs describe those apps so you can learn from them. They're not templates to copy.

## When to read which
- `vsco.md`: editor tools. Hairline bipolar sliders, uppercase wide-tracked chrome, **no accent color** (white is the only interactive color; film tones appear only in content).
- `midjourney.md`: AI generation UI. Grid-first galleries, the prompt as the hero, content supplying all color.
- `instagram.md` / `tiktok.md`: capture and full-screen media. Oversized capture controls, edge-to-edge media, overlay chrome.
- `youtube.md` / `apple-tv.md`: players, scrubbers, shelves, focus states.

## How to use them well
1. Name the problem first (for example "a two-axis look control", or "the AI result reveal").
2. Read the relevant sections of one or two packs, not all six.
3. Extract the principle and say it in one line, such as "VSCO puts color only in content, so its chrome is white."
4. Apply it in your own product's language. If a screen ends up resembling the reference app, you copied a surface instead of a principle. Go back to step 3.

## Principles pulled out already (for MOVA)
- Color belongs to the footage, so chrome stays monochrome and selection is white (VSCO).
- The capture control is the largest thing on a camera screen (Snapchat, Instagram).
- Tool labels are uppercase and wide-tracked, and values sit in tabular numerals right-aligned (VSCO).
- Generated results are shown big and unboxed, with metadata quiet beneath (Midjourney).
