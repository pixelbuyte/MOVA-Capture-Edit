// interactions.js — web ports of mikelikesdesign/SwiftUI-experiments (MIT) that fit a camera / editor app.
// Each keeps the experiment's own math. All are pointer + keyboard operable.
//
//  RadialMenu(el, { items, onSelect })   radial menu: press-and-drag to a segment; expansion = 0.3·(1 - e^(-d/50))
//  Trackpad2D(el, { x, y, onChange })    draggable slider: a 2D pad with a knob and soft detents (two-axis choices)
//  GlowTrail(canvas)                     colorful glow: finger trail whose hue cycles with age, blur 30 - age·10, 100-point cap
//  TiltGrid(el, { strength })            tilt grid: children scale by distance from a focus point (pointer or device tilt)
(function (g) {
  const reduce = () => matchMedia('(prefers-reduced-motion: reduce)').matches;

  // radial menu/ContentView.swift
  function RadialMenu(el, { items, radius = 85, onSelect }) {
    const segs = items.length, segSize = 360 / segs;
    el.classList.add('rm'); el.setAttribute('role', 'menu');
    el.innerHTML = items.map((it, i) => {
      const mid = i * segSize + segSize / 2, x = Math.cos((mid - 90) * Math.PI / 180) * radius, y = Math.sin((mid - 90) * Math.PI / 180) * radius;
      return `<button class="rm__item" role="menuitem" data-i="${i}" style="--x:${x}px;--y:${y}px">${it.label}</button>`;
    }).join('');
    let sel = null, open = false, origin = null;
    const btns = [...el.querySelectorAll('.rm__item')];
    const paint = d => btns.forEach((b, i) => { const e = i === sel ? 0.3 * (1 - Math.exp(-d / 50)) : 0; b.style.transform = `translate(calc(var(--x) * ${1 + e}), calc(var(--y) * ${1 + e})) scale(${1 + e})`; b.classList.toggle('is-sel', i === sel); });
    const segmentFor = (dx, dy, d) => { if (d <= 5) return null; const a = (Math.atan2(dy, dx) * 180 / Math.PI + 360) % 360; return Math.floor(((a + 90 + segSize / 2) % 360) / segSize) % segs; };
    el.openAt = (x, y) => { open = true; origin = { x, y }; el.style.left = x + 'px'; el.style.top = y + 'px'; el.classList.add('is-open'); paint(0); };
    el.move = (x, y) => { if (!open) return; const dx = x - origin.x, dy = y - origin.y, d = Math.hypot(dx, dy); const s = segmentFor(dx, dy, d); if (s !== sel) { sel = s; s != null && g.Pow?.haptic('selection'); } paint(d); };
    el.release = () => { if (!open) return; open = false; el.classList.remove('is-open'); if (sel != null) onSelect?.(items[sel], sel); sel = null; };
    btns.forEach((b, i) => b.addEventListener('click', () => { onSelect?.(items[i], i); el.classList.remove('is-open'); }));
    return el;
  }

  // draggable slider/ContentView.swift (trackpad with soft impact feedback on each detent)
  function Trackpad2D(el, { x = 0.5, y = 0.5, steps = 4, onChange }) {
    el.classList.add('tp'); el.setAttribute('role', 'slider'); el.tabIndex = 0;
    el.innerHTML = '<i class="tp__knob"></i>';
    const knob = el.firstChild; let last = '';
    const set = (nx, ny) => {
      x = Math.min(1, Math.max(0, nx)); y = Math.min(1, Math.max(0, ny));
      knob.style.transform = `translate(${x * (el.clientWidth - 30)}px, ${y * (el.clientHeight - 30)}px)`;
      el.style.setProperty('--rx', ((y - .5) * -10) + 'deg'); el.style.setProperty('--ry', ((x - .5) * 10) + 'deg');  // trackpadRotation
      const cell = `${Math.round(x * (steps - 1))},${Math.round(y * (steps - 1))}`;
      if (cell !== last) { last = cell; g.Pow?.haptic('selection'); }
      el.setAttribute('aria-valuetext', `${Math.round(x * 100)}% across, ${Math.round(y * 100)}% down`);
      onChange?.(x, y);
    };
    el.addEventListener('pointerdown', e => { el.setPointerCapture(e.pointerId); const mv = ev => { const r = el.getBoundingClientRect(); set((ev.clientX - r.left - 15) / (r.width - 30), (ev.clientY - r.top - 15) / (r.height - 30)); }; mv(e); el.addEventListener('pointermove', mv); el.addEventListener('pointerup', () => { el.removeEventListener('pointermove', mv); el.style.setProperty('--rx', '0deg'); el.style.setProperty('--ry', '0deg'); }, { once: true }); });
    el.addEventListener('keydown', e => { const k = { ArrowLeft: [-.05, 0], ArrowRight: [.05, 0], ArrowUp: [0, -.05], ArrowDown: [0, .05] }[e.key]; if (k) { set(x + k[0], y + k[1]); e.preventDefault(); } });
    requestAnimationFrame(() => set(x, y));
    return { set };
  }

  // colorful glow/ContentView.swift
  function GlowTrail(canvas, { hue = null } = {}) {
    if (reduce()) return { stop() {} };
    const ctx = canvas.getContext('2d'), pts = []; let raf;
    const add = e => { const r = canvas.getBoundingClientRect(); pts.push({ x: (e.clientX - r.left) * devicePixelRatio, y: (e.clientY - r.top) * devicePixelRatio, t: performance.now() / 1000 }); if (pts.length > 100) pts.shift(); };
    canvas.addEventListener('pointermove', add); canvas.addEventListener('pointerdown', add);
    const draw = () => {
      canvas.width = canvas.clientWidth * devicePixelRatio; canvas.height = canvas.clientHeight * devicePixelRatio;
      const now = performance.now() / 1000;
      for (const p of pts) { const age = now - p.t; if (age > 3) continue;
        ctx.filter = `blur(${Math.max(1, 30 - age * 10)}px)`;
        ctx.fillStyle = hue == null ? `hsla(${(age % 1) * 360},100%,60%,${Math.max(0, 1 - age / 3)})` : `hsla(${hue},40%,85%,${Math.max(0, 1 - age / 3)})`;
        ctx.beginPath(); ctx.arc(p.x, p.y, 30 * devicePixelRatio, 0, Math.PI * 2); ctx.fill(); }
      raf = requestAnimationFrame(draw);
    };
    raf = requestAnimationFrame(draw);
    return { stop() { cancelAnimationFrame(raf); } };
  }

  // tilt grid/ContentView.swift: scale(for:) shrinks cards with distance from the focus point
  function TiltGrid(el, { strength = 0.25 } = {}) {
    const kids = () => [...el.children];
    const focus = (fx, fy) => kids().forEach(k => { const r = k.getBoundingClientRect(), cx = r.left + r.width / 2, cy = r.top + r.height / 2; const d = Math.hypot(cx - fx, cy - fy) / Math.hypot(innerWidth, innerHeight); k.style.transform = `scale(${1 - Math.min(strength, d * strength * 2)})`; });
    el.addEventListener('pointermove', e => focus(e.clientX, e.clientY));
    el.addEventListener('pointerleave', () => kids().forEach(k => k.style.transform = ''));
    return { focus };
  }

  g.Interactions = { RadialMenu, Trackpad2D, GlowTrail, TiltGrid };
})(window);
