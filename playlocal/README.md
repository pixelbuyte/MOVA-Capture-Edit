# MOVA on playlocal.space

Drop-in files for adding MOVA to the Doberg site at playlocal.space.

| File | What it is |
|---|---|
| `mova-card.html` | The MOVA app card, matching the Skintel / Blith cards. Paste the card after the Blith card and the CSS rules into the page stylesheet |
| `index-with-mova.html` | The current live homepage with the card and a footer link already added. Replaces `index.html` |
| `mova.html` | A dedicated MOVA page (hero, demo video, how recreation works, rules, early-access contact) |
| `assets/` | `mova-icon.png`, `mova-demo.mp4` (portrait, 1.5 MB), `mova-demo-poster.jpg`, `mova-demo-wide.mp4` (16:9, 2 MB), `mova-demo-wide-poster.jpg` |

To publish: copy `mova.html` and `assets/*` into the site root next to `index.html`, then either replace `index.html` with `index-with-mova.html` or paste `mova-card.html` by hand. The site is a static deploy, so no build step is needed.

The homepage hero still says "We make Skintel and Blith" and frames the studio around health apps. Whether to change that line for MOVA is an editorial call, so it was left as is.
