// MOVA motion layer · v3
// Built on anime.js 3.2.2 (juliangarnier/anime, MIT). Effects are web re-implementations of ideas from
// EmergeTools/Pow (shine, film exposure, haptic-paired feedback) and twostraws/Vortex (sparks, fireflies).
// Rules: every effect has a job, durations come from the motion tokens, Reduce Motion turns all of it off,
// and the page is complete without any of it (if anime.js fails to load, nothing breaks).
(() => {
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const A = window.anime;
  const ms = name => parseFloat(getComputedStyle(document.documentElement).getPropertyValue(name)) || 0;
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];

  // Direction switch for the design review: ?direction=darkroom|lumen
  const dir = new URLSearchParams(location.search).get('direction');
  if (dir) document.documentElement.setAttribute('data-direction', dir);

  if (reduce || !A) return;

  // 1 · Entry: content rises in, staggered, once. (Haptic: none. Purpose: orientation.)
  const enter = $$('[data-enter]');
  if (enter.length) A({ targets: enter, opacity: [0, 1], translateY: [12, 0], delay: A.stagger(70, { start: 60 }), duration: ms('--dur-4'), easing: 'cubicBezier(.2,.8,.2,1)' });

  // 2 · Press: every button compresses (haptic: impact light in the app)
  $$('.btn, .ibtn, .tabbar__shutter, .shutter').forEach(b => {
    b.addEventListener('pointerdown', () => A({ targets: b, scale: 0.96, duration: ms('--dur-1'), easing: 'easeOutQuad' }));
    b.addEventListener('pointerup', () => A({ targets: b, scale: 1, duration: ms('--dur-3'), easing: 'spring(1, 120, 12, 0)' }));
    b.addEventListener('pointerleave', () => A({ targets: b, scale: 1, duration: ms('--dur-2'), easing: 'easeOutQuad' }));
  });

  // 3 · Shine (after Pow's .shine): sweeps across credit counts when they change or on first view
  $$('[data-shine]').forEach(el => {
    el.style.position = el.style.position || 'relative'; el.style.overflow = 'hidden';
    const s = document.createElement('i');
    s.setAttribute('aria-hidden', 'true');
    s.style.cssText = 'position:absolute;top:0;bottom:0;width:40%;left:-50%;background:linear-gradient(100deg,transparent,rgba(255,255,255,.35),transparent);pointer-events:none';
    el.appendChild(s);
    A({ targets: s, left: ['-50%', '130%'], duration: 900, delay: 600, easing: 'easeInOutQuad' });
  });

  // 4 · Lane toggle: the row's cells settle with a small spring (haptic: selection)
  $$('[data-lane] .lane__toggle').forEach(b => b.addEventListener('click', () => {
    const cells = b.closest('[data-lane]').querySelectorAll('.lane__cell');
    A({ targets: cells, scale: [0.94, 1], delay: A.stagger(40), duration: ms('--dur-3'), easing: 'spring(1, 160, 14, 0)' });
  }));

  // 5 · Film exposure (after Pow's .filmExposure): an image develops bottom-up, used for generated shots
  $$('[data-develop]').forEach(el => {
    const state = { v: 100 }, end = parseFloat(el.dataset.develop || '0');
    A({ targets: state, v: end, duration: 2400, easing: 'easeInOutSine', update: () => el.style.setProperty('--undeveloped', state.v + '%') });
  });

  // 6 · Sparks (after Vortex's .spark preset): one short burst for success, never looping
  window.movaSparks = (x, y, host = document.body) => {
    const n = 12, parts = [];
    for (let i = 0; i < n; i++) {
      const p = document.createElement('i');
      p.setAttribute('aria-hidden', 'true');
      p.style.cssText = `position:absolute;left:${x}px;top:${y}px;width:4px;height:4px;border-radius:50%;background:var(--accent);pointer-events:none;z-index:60`;
      host.appendChild(p); parts.push(p);
    }
    A({ targets: parts, translateX: () => A.random(-90, 90), translateY: () => A.random(-70, 40), scale: [1, 0.3], opacity: [1, 0],
        duration: () => A.random(600, 900), easing: 'easeOutCubic', complete: () => parts.forEach(p => p.remove()) });
  };
  $$('[data-sparks]').forEach(el => setTimeout(() => {
    const r = el.getBoundingClientRect(), h = el.closest('.screen') || document.body, hr = h.getBoundingClientRect();
    window.movaSparks(r.left - hr.left + r.width / 2, r.top - hr.top + r.height / 2, h);
  }, +el.dataset.sparks || 300));

  // 7 · Fireflies (after Vortex's .fireflies): ambient, slow, few. Welcome screen only.
  $$('[data-fireflies]').forEach(host => {
    const n = +host.dataset.fireflies || 14;
    for (let i = 0; i < n; i++) {
      const f = document.createElement('i');
      f.setAttribute('aria-hidden', 'true');
      const size = A.random(2, 4);
      f.style.cssText = `position:absolute;left:${A.random(5, 95)}%;top:${A.random(10, 90)}%;width:${size}px;height:${size}px;border-radius:50%;background:var(--accent);box-shadow:0 0 8px 2px var(--accent-line);opacity:0;pointer-events:none`;
      host.appendChild(f);
      A({ targets: f, opacity: [{ value: A.random(4, 9) / 10, duration: 1400 }, { value: 0, duration: 1400 }],
          translateX: A.random(-30, 30), translateY: A.random(-40, -10), delay: A.random(0, 2400), duration: 2800, loop: true, easing: 'easeInOutSine' });
    }
  });

  // 8 · Draw: SVG strokes draw on (the Echo mark, camera paths on first view)
  $$('[data-draw]').forEach(svg => {
    A({ targets: svg.querySelectorAll('path'), strokeDashoffset: [A.setDashoffset, 0], duration: 1100, delay: A.stagger(220, { start: +svg.dataset.draw || 0 }), easing: 'easeInOutCubic' });
  });

  // 9 · Timelines: elements with data-timeline run a named choreography (defined per screen)
  (window.movaTimelines || []).forEach(fn => fn(A, ms));
})();
