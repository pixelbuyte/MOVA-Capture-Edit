# MOVA — Capture. Recreate. Edit.

A professional iPhone camera, a photo and video editor, and an AI studio built around reference-video recreation: give it a reference video, it learns how it was made, and it builds a new one from your own photo or footage.

**Status:** design phase.

| Path | Contents |
|---|---|
| `design/index.html` | All 26 design boards (open locally; screens are clickable) |
| `design/screens/` | One static HTML file per screen, 390×844 |
| `design/SPEC.md` | Brand, tokens, type, screen list, product rules, native framework map |
| `design/video/` | Demo video: 1080p and 720p (49 s), portrait screen-only clip, posters |
| `design/demo.html` + `design/tools/render-demo.js` | The demo stage and the frame-by-frame renderer used to make the video |
| `design/canvas.json` | Board layout from the editable design canvas |
| `playlocal/` | MOVA card, dedicated page and assets for playlocal.space |

Re-render the video:

```sh
cd design && python3 -m http.server 8765 &
node tools/render-demo.js /tmp/frames 30          # 1920×1080, 49 s
MODE=screen node tools/render-demo.js /tmp/sframes 30   # 390×844 portrait
ffmpeg -framerate 30 -i /tmp/frames/f%05d.jpg -c:v libx264 -crf 20 -pix_fmt yuv420p video/mova-demo-1080p.mp4
```

Photography in the mockups is from Unsplash (Unsplash License).
