---
name: layered-design-tokens
description: How to structure a design-token system in three layers (primitives → semantic roles → component decisions) with motion tokens grouped by scope (micro, component, page), following the pattern in muhittincamdali/SwiftUI-Design-System-Pro and the "build the design system and skills your agent can follow" approach, with a CSS template and a SwiftUI mapping. Use this when starting or refactoring any design system, theming an app for multiple directions or brands, or when tokens are a flat list of hex values that screens reference directly.
---

# Layered design tokens

The pattern comes from SwiftUI-Design-System-Pro (MIT; `PrimitiveColors` → semantic `ColorTokens`, plus `AnimationTokens.Micro/Component/Page`). Use the architecture, not the package. Its own roadmap notes that its components don't read the active theme, which is exactly the gap this layering closes.

## The three layers
| Layer | Naming | Example | Who may read it |
|---|---|---|---|
| 1 Primitive | what it is | `--bone-50`, `--carbon-900`, `--size-15`, `--ms-220` | layer 2 only |
| 2 Semantic | what it's for | `--surface`, `--text-1`, `--signal-rec`, `--t-body` | components, screens |
| 3 Component | one component's decision | `--shutter-size`, `--tab-height`, `--slider-track` | components, screens |

A theme or design direction remaps layer 2 onto different primitives. A brand change edits layer 1. A component tweak edits layer 3. Screens never change.

## Motion tokens by scope (from DS Pro's AnimationTokens)
```css
--motion-micro-press:   120ms var(--curve-out);    /* button press, toggle */
--motion-micro-select:  200ms var(--curve-out);
--motion-component-in:  420ms var(--curve-emph);   /* card, sheet content, reveal */
--motion-page-push:     520ms var(--curve-emph);   /* screen transitions, shared elements */
--motion-page-sheet:    480ms var(--curve-emph);
```
Under `prefers-reduced-motion`, set every duration to 0ms at layer 2.

## SwiftUI mapping
- Layer 1: `enum Primitive { static let bone50 = Color(hex:) }`
- Layer 2: `enum Tokens.Color { static let surface = Primitive.carbon900 }`, with a theme environment swapping the mapping.
- Layer 3: `enum ShutterTokens { static let size: CGFloat = 78 }`.
- Motion: `enum Motion.Micro { static let press = Animation.snappy(duration: 0.12) }`.

## Checks
- `grep` the screens for raw hex values: there should be none.
- `grep` the screens for layer-1 names: there should be none.
- Every semantic color has a measured contrast note next to it.

`assets/tokens-template.css` is a starting file.
