// pow.js — web ports of EmergeTools/Pow (MIT) transitions and change effects, using Pow's own formulas.
// Every effect animates a progress value p from 0→1 and maps it exactly as the Swift modifier does.
// Usage:  Pow.transition(el, 'filmExposure', { duration: 1800 })   // reveal
//         Pow.transition(el, 'iris', { origin: [0.5, 0.5], blur: 12 })
//         Pow.change(el, 'shine', { duration: 1000 })              // after a value changes
//         Pow.spring({ stiffness: 170, damping: 0.65 })            // returns an easing fn (Pow's Spring, zeta form)
// Reduced motion: everything jumps to the end state.
(function (g) {
  const reduce = () => matchMedia('(prefers-reduced-motion: reduce)').matches;
  const clamp = (v, a = 0, b = 1) => Math.max(a, Math.min(b, v));
  const easeInOut = t => t < .5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;   // SwiftUI .easeInOut approximation

  function run(duration, ease, step, done) {
    if (reduce()) { step(1); done && done(); return { cancel() {} }; }
    let start, raf;
    const tick = t => { start ??= t; const x = clamp((t - start) / duration); step(ease(x)); if (x < 1) raf = requestAnimationFrame(tick); else done && done(); };
    raf = requestAnimationFrame(tick);
    return { cancel() { cancelAnimationFrame(raf); } };
  }

  // Transitions.swift ports. Each returns the style for progress p (0 = hidden/active, 1 = identity).
  const T = {
    // FilmExposure.swift / ExposureFade: opacity 1 - 2^(-10p), brightness -1·(1-p)
    filmExposure: p => ({ opacity: 1 - Math.pow(2, -10 * p), filter: `brightness(${clamp(p)})` }),
    // FilmExposure.swift / Snapshot: saturation .5+.5p, contrast .5+.5p, brightness +.85(1-p), blur 5(1-p)
    snapshot: p => ({ filter: `saturate(${.5 + .5 * clamp(p)}) contrast(${.5 + .5 * clamp(p)}) brightness(${1 + .85 * (1 - clamp(p))}) blur(${5 * (1 - clamp(p))}px)` }),
    // Iris.swift: circular mask growing to the corner diagonal from origin, blur (1-p)·blurRadius
    iris: (p, el, o) => {
      const [ox, oy] = o.origin || [.5, .5], w = el.offsetWidth, h = el.offsetHeight;
      const sw = w * 2 * Math.max(ox, 1 - ox), sh = h * 2 * Math.max(oy, 1 - oy), d = p * Math.hypot(sw, sh);
      return { clipPath: `circle(${d / 2}px at ${ox * 100}% ${oy * 100}%)`, filter: o.blur ? `blur(${(1 - p) * Math.min(30, o.blur)}px)` : '' };
    },
    // Wipe.swift: hard edge sweeping at angle, optional blur
    wipe: (p, el, o) => {
      const a = o.angle ?? 0, l = p * 100;
      const m = `linear-gradient(${90 + a}deg, #000 0 ${l}%, transparent ${l + (o.blur ? 8 : 0)}%)`;
      return { webkitMaskImage: m, maskImage: m };
    },
    // Glare.swift: mask reveals to l = 1.6p while a glare band sits between t = p and l
    glare: (p, el, o) => {
      const l = p * 1.6 * 100, t = p * 100, a = (o.angle ?? 45);
      const m = `linear-gradient(${90 + a}deg, #000 0 ${l}%, transparent ${l}%)`;
      el.style.setProperty('--pow-glare', `linear-gradient(${90 + a}deg, transparent ${t}%, ${o.color || 'rgba(255,255,255,.9)'} ${t + 1}% ${l + 1}%, transparent ${l + 2}%)`);
      return { webkitMaskImage: m, maskImage: m };
    },
    // Blur.swift: blur radius (1-p)·r with opacity p
    blur: (p, el, o) => ({ filter: `blur(${(1 - p) * (o.radius ?? 30)}px)`, opacity: p }),
    // Pop.swift-like overshoot handled by spring easing at the call site
    pop: p => ({ transform: `scale(${p})`, opacity: clamp(p * 2) }),
  };

  function transition(el, name, o = {}) {
    const fn = T[name]; if (!fn) throw new Error('Unknown Pow transition ' + name);
    let overlay;
    if (name === 'glare') { overlay = document.createElement('i'); overlay.style.cssText = 'position:absolute;inset:0;pointer-events:none;background:var(--pow-glare);mix-blend-mode:screen'; if (getComputedStyle(el).position === 'static') el.style.position = 'relative'; el.appendChild(overlay); }
    const back = o.out;   // true = removal (1→0)
    return run(o.duration ?? 1000, o.ease || easeInOut, x => Object.assign(el.style, fn(back ? 1 - x : x, el, o)),
      () => { overlay && overlay.remove(); if (!back) ['clipPath', 'webkitMaskImage', 'maskImage', 'filter'].forEach(k => el.style[k] = ''); o.done && o.done(); });
  }

  // ShineEffect.swift: a band whose stops follow 0.8·sin²(x)·base, sweeping across, fading out as 1 - f^8
  function change(el, name, o = {}) {
    if (name !== 'shine') throw new Error('Only shine is ported as a change effect');
    if (getComputedStyle(el).position === 'static') el.style.position = 'relative';
    el.style.overflow = 'hidden';
    const band = document.createElement('i'), stops = [];
    for (let x = 0; x <= Math.PI + 1e-6; x += 0.2) stops.push(`rgba(255,255,255,${(Math.pow(Math.sin(x), 2) * 0.8).toFixed(3)})`);
    band.style.cssText = `position:absolute;top:-50%;bottom:-50%;width:200%;left:-150%;pointer-events:none;mix-blend-mode:soft-light;background:linear-gradient(90deg,${stops.join(',')});transform:rotate(${o.angle ?? 25}deg)`;
    el.appendChild(band);
    return run(o.duration ?? 1000, easeInOut, f => { band.style.left = `${-150 + f * 200}%`; band.style.opacity = String((1 - Math.pow(f, 8)) * Math.sin(f) / Math.sin(1)); }, () => band.remove());
  }

  // Spring.swift (damped harmonic oscillator, zeta form) → easing function for run()
  function spring({ mass = 1, stiffness = 170, damping = 0.7 } = {}) {
    const w0 = Math.sqrt(stiffness / mass), z = damping;
    return t => {
      const s = t * 1.4; // time scale so most springs settle within the duration
      if (z < 1) { const wd = w0 * Math.sqrt(1 - z * z); return 1 - Math.exp(-z * w0 * s) * (Math.cos(wd * s) + (z * w0 / wd) * Math.sin(wd * s)); }
      return 1 - Math.exp(-w0 * s) * (1 + w0 * s);
    };
  }

  // HapticFeedbackEffect.swift has no web equivalent on iOS Safari; we expose a hook for prototypes to show a visual tick.
  function haptic(kind = 'selection') { g.dispatchEvent(new CustomEvent('pow:haptic', { detail: kind })); if (navigator.vibrate) navigator.vibrate(kind === 'impact' ? 12 : 6); }

  g.Pow = { transition, change, spring, haptic, transitions: Object.keys(T) };
})(window);
