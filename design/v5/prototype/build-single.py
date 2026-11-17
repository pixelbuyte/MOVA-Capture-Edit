#!/usr/bin/env python3
"""Build the MOVA v5 clickable prototype.

  python3 build-single.py [single-file-output.html]

Reads   ../screen-NN-*.html   (the approved boards; never modified)
        screens.json          (registry: order + hotspots)
        shell.html            (prototype chrome, CSS and runtime JS)
Writes  index.html            (photos referenced relatively: ../../v3/img/x.jpg)
        <single-file output>  (photos inlined as base64; no <!doctype>/<html>/<head>/<body>)

Each screen's in-phone markup and its full stylesheet are copied verbatim and mounted
in its own shadow root at runtime, so screens cannot collide and stay identical to the PNGs.
"""
import base64, html, json, re, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
V5 = HERE.parent
IMG_DIR = V5.parent / "v3" / "img"
DEFAULT_OUT = Path("/tmp/claude-0/-home-user-MOVA-Capture-Edit/6f535842-b2ba-5edd-8952-efe3592da324/scratchpad/mova-v5-prototype.html")
DEFAULT_HOTSPOTS = [{"sel": "[aria-label^='Back'], [aria-label='Close']", "to": "@back", "fallback": "03-studio", "fx": "pop"}]


def extract(path: Path):
    src = path.read_text(encoding="utf-8")
    css = "\n".join(re.findall(r"<style>(.*?)</style>", src, re.S))
    # board-only page rules; the shell supplies the host font/colour instead
    css = re.sub(r"(?m)^[ \t]*html\s*,\s*body\s*\{[^}]*\}\s*", "", css)
    css = re.sub(r"(?m)^[ \t]*body\s*\{[^}]*\}\s*", "", css)
    css = css.replace(":root", ":host")
    m = re.search(r'<div class="phone">\s*(<div class="screen">.*?</div>)\s*</div>\s*(?:<script|</body>)', src, re.S)
    if not m:
        raise SystemExit(f"{path.name}: could not find .phone > .screen markup")
    body = m.group(1)
    scripts = re.findall(r"<script>(.*?)</script>", src[src.find("<body"):], re.S)
    t = re.search(r"<title>(.*?)</title>", src, re.S)
    title = html.unescape(t.group(1)).split("·")[-1].strip() if t else path.stem
    fix = lambda s: s.replace("../v3/img/", "../../v3/img/")
    if "v4/img" in src:
        raise SystemExit(f"{path.name}: references design/v4/img, which is not allowed")
    return fix(css), fix(body), scripts, title


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_OUT
    reg = json.loads((HERE / "screens.json").read_text(encoding="utf-8"))
    reg.pop("_readme", None)
    files = {p.name[len("screen-"):-len(".html")]: p for p in sorted(V5.glob("screen-[0-9][0-9]-*.html"))}
    known = {s["id"] for s in reg["screens"]}
    for sid in files:                      # auto-register screens nobody listed yet
        if sid not in known:
            reg["screens"].append({"id": sid, "hotspots": DEFAULT_HOTSPOTS})
    reg["screens"] = [s for s in reg["screens"] if s["id"] in files]
    ids = [s["id"] for s in reg["screens"]]
    reg["order"] = [i for i in reg.get("order", []) if i in ids] + [i for i in ids if i not in reg.get("order", [])]

    tpl, js, used = [], [], set()
    for s in reg["screens"]:
        css, body, scripts, title = extract(files[s["id"]])
        s.setdefault("name", title)
        s["num"] = s["id"][:2]
        used.update(re.findall(r"\.\./\.\./v3/img/([\w.\-]+)", css + body))
        tpl.append(f'<template data-screen="{s["id"]}"><style>{css}</style>\n{body}\n</template>')
        for code in scripts:               # board scripts run with `document` bound to the screen's shadow root
            js.append(f'(window.MOVA_SCRIPTS=window.MOVA_SCRIPTS||{{}})["{s["id"]}"]=function(document){{{code}}};')

    shell = (HERE / "shell.html").read_text(encoding="utf-8")
    head, body = shell.split("<!--@HEAD-END-->")
    body = body.replace("<!--@SCREENS-->", "\n".join(tpl))
    body = body.replace("<!--@REGISTRY-->", '<script type="application/json" id="mova-registry">' + json.dumps(reg).replace("</", "<\\/") + "</script>"
                        + ("\n<script>\n" + "\n".join(js) + "\n</script>" if js else ""))

    index = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n' + head.strip() +
             "\n</head>\n<body>\n" + body.replace("<!--@IMG-->", "").strip() + "\n</body>\n</html>\n")
    (HERE / "index.html").write_text(index, encoding="utf-8")

    imgs = {}
    for name in sorted(used):
        imgs[name] = "data:image/jpeg;base64," + base64.b64encode((IMG_DIR / name).read_bytes()).decode()
    single = head.strip() + "\n" + body.replace("<!--@IMG-->", "<script>window.MOVA_IMG=" + json.dumps(imgs) + ";</script>").strip() + "\n"
    for bad in (r"<!doctype", r"<html[\s>]", r"<head[\s>]", r"<body[\s>]"):
        assert not re.search(bad, single, re.I), bad
    assert "<title>MOVA Prototype</title>" in single[:8000]
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(single, encoding="utf-8")
    print(f"screens: {', '.join(ids)}")
    print(f"index.html  {len(index)//1024} KB")
    print(f"{out}  {len(single)//1024} KB, {len(imgs)} photos inlined")


if __name__ == "__main__":
    main()
