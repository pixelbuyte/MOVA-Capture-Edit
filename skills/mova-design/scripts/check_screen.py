#!/usr/bin/env python3
"""Check MOVA screen files against the design-system rules.

Usage: python check_screen.py <screen.html | folder> [...]
Exit code 1 if any ERROR is found. Warnings never fail the run.
"""
import re
import sys
from pathlib import Path

LAYERS = ["tokens/primitives.css", "tokens/semantic.css", "tokens/component.css"]
RAW_COLOR = re.compile(r"#[0-9a-fA-F]{3,8}\b|rgba?\([^)]*\)|hsla?\([^)]*\)")
SMALL_FONT = re.compile(r"(?:font:\s*\d{3}\s+|font-size:\s*)(\d+(?:\.\d+)?)px")
SVG_SMALL = re.compile(r'font-size="(\d+(?:\.\d+)?)"')
PRIMITIVE_USE = re.compile(r"var\(--(gray|peri|umber|paper|ink|red|yellow|green|orange|coral|blue|amber|safelight|family|size|space|radius|ms|curve)-")


def strip_non_css_colors(text: str) -> str:
    # icon sprite references (icons.svg#name) and HTML entities aren't colors
    text = re.sub(r"icons\.svg#[\w-]+", "", text)
    text = re.sub(r"&#\d+;", "", text)
    return text


def check(path: Path):
    html = path.read_text(encoding="utf-8")
    errors, warnings = [], []

    missing = [layer for layer in LAYERS if layer not in html]
    if missing:
        errors.append(f"missing token layer link(s): {', '.join(missing)}")
    if "components.css" not in html:
        errors.append("missing components.css link")

    body = strip_non_css_colors(html)
    raw = sorted(set(RAW_COLOR.findall(body)))
    if raw:
        errors.append(f"raw color values (use semantic tokens): {', '.join(raw[:6])}{' …' if len(raw) > 6 else ''}")

    prim = sorted(set(m.group(0) for m in PRIMITIVE_USE.finditer(html)))
    if prim:
        errors.append(f"screen references primitive tokens directly (use semantic roles): {', '.join(prim[:4])}")

    small = [float(v) for v in SMALL_FONT.findall(html) + SVG_SMALL.findall(html) if float(v) < 11]
    if small:
        errors.append(f"text below the 11px floor: {sorted(set(small))}")

    ai = len(re.findall(r'class="[^"]*\bbtn--ai\b', html))
    if ai > 1:
        errors.append(f"{ai} AI buttons (btn--ai); maximum is one per screen")

    for m in re.finditer(r"<(button|a)\b([^>]*)>(.*?)</\1>", html, re.S):
        attrs, inner = m.group(2), m.group(3)
        text = re.sub(r"<[^>]+>", "", inner).strip()
        if not text and "aria-label" not in attrs and "aria-hidden" not in attrs:
            errors.append(f"icon-only <{m.group(1)}> without aria-label: {attrs.strip()[:60]}")

    if re.search(r"9:41|status-?bar", html, re.I):
        errors.append("looks like a fake status bar; leave --safe-top empty")

    if "--accent" in html and ("link" in html and re.search(r"a\s*\{[^}]*color:\s*var\(--accent\)", html)):
        warnings.append("accent used as a link color; accent is reserved for AI")
    if html.count("class=\"chip") > 3:
        warnings.append("several chips: check whether a rail, picker or lanes fits better")
    if re.search(r"\d+%\s*(done|complete)", html, re.I):
        warnings.append("percent-complete copy: prefer real stages, frames or bytes")
    if "font-family" in html and "var(--font" not in html:
        warnings.append("font-family set without a font token")

    return errors, warnings


def main(argv):
    targets = []
    for arg in argv or ["."]:
        p = Path(arg)
        targets += sorted(p.glob("*.html")) if p.is_dir() else [p]
    total_err = 0
    for t in targets:
        errors, warnings = check(t)
        total_err += len(errors)
        status = "PASS" if not errors else "FAIL"
        print(f"{status}  {t}")
        for e in errors:
            print(f"   error: {e}")
        for w in warnings:
            print(f"   warn:  {w}")
    print(f"\n{len(targets)} file(s), {total_err} error(s)")
    return 1 if total_err else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
