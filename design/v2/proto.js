// MOVA v2 prototype behaviours. Design-phase only: makes controls feel real, no app logic.
// Every control is pointer + keyboard operable and exposes ARIA state.
(() => {
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const clamp = (v, a, b) => Math.max(a, Math.min(b, v));

  // Drag helper: calls fn(x, y, rect) on pointerdown/move
  function drag(el, fn) {
    el.addEventListener('pointerdown', e => {
      el.setPointerCapture(e.pointerId);
      const move = ev => { const r = el.getBoundingClientRect(); fn(ev.clientX - r.left, ev.clientY - r.top, r); };
      move(e);
      el.addEventListener('pointermove', move);
      el.addEventListener('pointerup', () => el.removeEventListener('pointermove', move), { once: true });
    });
  }

  // Single-choice groups: looks, pickers, rails, shot maps. [data-choice] on the container.
  $$('[data-choice]').forEach(group => {
    const attr = group.dataset.choice || 'aria-checked';
    const items = $$('[data-opt]', group);
    items.forEach(it => {
      it.addEventListener('click', () => {
        if (it.getAttribute('aria-disabled') === 'true') return;
        items.forEach(o => o.setAttribute(attr, String(o === it)));
        group.dispatchEvent(new CustomEvent('choice', { detail: it }));
      });
    });
    group.addEventListener('keydown', e => {
      if (!['ArrowLeft', 'ArrowRight'].includes(e.key)) return;
      const live = items.filter(o => o.getAttribute('aria-disabled') !== 'true');
      const i = live.findIndex(o => o.getAttribute(attr) === 'true');
      const n = live[clamp(i + (e.key === 'ArrowRight' ? 1 : -1), 0, live.length - 1)];
      n.click(); n.focus(); e.preventDefault();
    });
  });

  // Shot map → detail panel + playhead
  $$('[data-shotmap]').forEach(map => {
    map.addEventListener('choice', e => {
      const d = JSON.parse(e.detail.dataset.shot || '{}');
      const scope = map.closest('.screen');
      Object.entries(d).forEach(([k, v]) => $$(`[data-bind="${k}"]`, scope).forEach(el => {
        if (el.tagName === 'IMG') el.src = v; else el.textContent = v;
      }));
      const path = scope.querySelector('[data-campath]');
      if (path && d.path) { path.setAttribute('d', d.path); const m = scope.querySelector('.campath .mover'); if (m) m.style.offsetPath = `path('${d.path}')`; }
      const ph = scope.querySelector('[data-playhead]');
      if (ph) ph.style.left = e.detail.offsetLeft + 'px';
    });
  });

  // Lanes: tap the state button to switch Recreate ↔ Off
  $$('[data-lane]').forEach(lane => {
    const btn = lane.querySelector('.lane__toggle');
    const name = lane.querySelector('.lane__name').textContent.trim();
    const sync = () => {
      const on = lane.dataset.state !== 'off';
      btn.setAttribute('aria-pressed', String(on));
      btn.setAttribute('aria-label', `${name}: ${on ? 'recreating from reference' : 'not recreated'}`);
      const scope = lane.closest('.screen');
      const n = $$('[data-lane]', scope).filter(l => l.dataset.state !== 'off').length;
      $$('[data-carry-count]', scope).forEach(el => el.textContent = n);
    };
    btn.addEventListener('click', () => { lane.dataset.state = lane.dataset.state === 'off' ? 'ref' : 'off'; sync(); });
    sync();
  });

  // Wipe compare (role=slider)
  $$('[data-wipe]').forEach(w => {
    const set = p => { p = clamp(p, 4, 96); w.style.setProperty('--x', p + '%'); w.setAttribute('aria-valuenow', Math.round(p)); };
    drag(w, (x, y, r) => set(x / r.width * 100));
    w.addEventListener('keydown', e => { const v = +w.getAttribute('aria-valuenow'); if (e.key === 'ArrowLeft') set(v - 5); if (e.key === 'ArrowRight') set(v + 5); });
    set(+w.getAttribute('aria-valuenow') || 50);
  });

  // Light dial (role=slider, value = degrees, 0 = camera side / front)
  $$('[data-dial]').forEach(d => {
    const sun = d.querySelector('.lightdial__sun'), beam = d.querySelector('.lightdial__beam');
    const out = d.closest('.screen').querySelectorAll('[data-dial-out]');
    const names = ['Front', 'Front-right', 'Side right', 'Back-right', 'Back', 'Back-left', 'Side left', 'Front-left'];
    const set = deg => {
      deg = (Math.round(deg) % 360 + 360) % 360;
      const r = d.clientWidth / 2 - 15, a = (deg + 90) * Math.PI / 180;
      sun.style.left = (d.clientWidth / 2 + r * Math.cos(a)) + 'px';
      sun.style.top = (d.clientHeight / 2 + r * Math.sin(a)) + 'px';
      beam.style.transform = `rotate(${deg + 90}deg)`;
      d.setAttribute('aria-valuenow', deg);
      const label = names[Math.round(deg / 45) % 8];
      d.setAttribute('aria-valuetext', `${label} key light, ${deg} degrees`);
      out.forEach(o => o.textContent = `${label} · ${deg}°`);
    };
    drag(d, (x, y, r) => set(Math.atan2(y - r.height / 2, x - r.width / 2) * 180 / Math.PI - 90));
    d.addEventListener('keydown', e => { const v = +d.getAttribute('aria-valuenow'); if (e.key === 'ArrowRight' || e.key === 'ArrowUp') set(v + 15); if (e.key === 'ArrowLeft' || e.key === 'ArrowDown') set(v - 15); });
    set(+d.getAttribute('aria-valuenow') || 45);
  });

  // Continuous sliders (role=slider). data-min/max/unit, optional [data-out="id"]
  $$('[data-slider]').forEach(s => {
    const min = +s.dataset.min || 0, max = +s.dataset.max || 100, step = +s.dataset.step || 1;
    const fill = s.querySelector('.slider__fill'), thumb = s.querySelector('.slider__thumb');
    const out = s.dataset.out ? document.getElementById(s.dataset.out) : null;
    const fmt = v => (s.dataset.prefix || '') + (v > 0 && s.dataset.signed ? '+' : '') + v + (s.dataset.unit || '');
    const set = v => {
      v = clamp(Math.round(v / step) * step, min, max);
      const p = (v - min) / (max - min) * 100;
      if (fill) fill.style.width = p + '%'; thumb.style.left = p + '%';
      s.setAttribute('aria-valuenow', v); s.setAttribute('aria-valuetext', fmt(v));
      if (out) out.textContent = fmt(v);
    };
    drag(s, (x, y, r) => set(min + clamp(x / r.width, 0, 1) * (max - min)));
    s.addEventListener('keydown', e => { const v = +s.getAttribute('aria-valuenow'); if (e.key === 'ArrowRight') set(v + step); if (e.key === 'ArrowLeft') set(v - step); });
    set(+s.getAttribute('aria-valuenow'));
  });

  // Rulers (detented dials). data-values="100,125,160…" ; readout in [data-out]
  $$('[data-ruler]').forEach(r => {
    const vals = r.dataset.values.split(','), ticks = r.querySelector('.ruler__ticks');
    const out = r.dataset.out ? document.getElementById(r.dataset.out) : null;
    let i = +r.dataset.index || 0, startX = 0, startI = 0;
    const set = n => {
      i = clamp(n, 0, vals.length - 1);
      ticks.style.transform = `translateX(${r.clientWidth / 2 - 300 - i * 12}px)`;
      r.setAttribute('aria-valuetext', vals[i]); r.setAttribute('aria-valuenow', i);
      if (out) out.textContent = vals[i];
    };
    r.addEventListener('pointerdown', e => { r.setPointerCapture(e.pointerId); startX = e.clientX; startI = i;
      const mv = ev => set(startI + Math.round((startX - ev.clientX) / 12));
      r.addEventListener('pointermove', mv); r.addEventListener('pointerup', () => r.removeEventListener('pointermove', mv), { once: true }); });
    r.addEventListener('keydown', e => { if (e.key === 'ArrowRight') set(i + 1); if (e.key === 'ArrowLeft') set(i - 1); });
    set(i);
  });

  // Switches
  $$('[role="switch"]').forEach(s => s.addEventListener('click', () => s.setAttribute('aria-checked', String(s.getAttribute('aria-checked') !== 'true'))));

  // Reduce Motion: freeze SMIL camera-path animations on their first frame
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) $$('svg').forEach(s => s.pauseAnimations && s.pauseAnimations());

  // Play/pause buttons swap their own icon + label
  $$('[data-playtoggle]').forEach(b => b.addEventListener('click', () => {
    const playing = b.getAttribute('aria-pressed') === 'true';
    b.setAttribute('aria-pressed', String(!playing));
    b.setAttribute('aria-label', playing ? 'Play' : 'Pause');
    const use = b.querySelector('use'); if (use) use.setAttribute('href', use.getAttribute('href').replace(playing ? '#pause' : '#play', playing ? '#play' : '#pause'));
  }));
})();
