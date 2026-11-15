# MOVA design v3

Design phase only. Builds on v2 "Monitor" with:

- **Three token layers**: `tokens/primitives.css` → `tokens/semantic.css` (plus the Darkroom and Lumen directions, previewable with `?direction=`) → `tokens/component.css`.
- **Motion layer**: `motion.js` on anime.js 3.2.2, with nine named effects, token durations, and Reduce Motion support.
- **New screens**: welcome and onboarding, export sheet, upload-paused state.
- **App Store**: `appstore/mova-appstore-1..5.png` at 1290 × 2796, built from `appstore/index.html`.
- **Agent skill**: `../../skills/mova-design/`, packaged as `../../skills/dist/mova-design.skill`.

Check every screen with: `python ../../skills/mova-design/scripts/check_screen.py screens`
