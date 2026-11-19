// vortex.js — a faithful web port of twostraws/Vortex (MIT, © Paul Hudson) for canvas.
// Same system fields, same update math (VortexSystem-Behavior.swift), same preset values (Presets/*.swift).
// Positions are unit space (0–1); x speed is scaled by height/width like Vortex's drawDivisor.
// Usage:
//   const v = Vortex.mount(canvas, Vortex.presets.spark({ color: '#EDEAE3' }));
//   v.burst();            // for systems with birthRate 0 (confetti, fireworks)
//   v.stop();             // stops and cleans up
// Respects prefers-reduced-motion: mount() returns a no-op controller.
(function (global) {
  const spread = x => (Math.random() - 0.5) * x;          // Double.randomSpread(): -x/2 … x/2
  const lerp = (a, b, t) => a + (b - a) * t;
  const deg = d => d * Math.PI / 180;

  function parseColor(c) {
    if (Array.isArray(c)) return c;
    const m = c.match(/^#?([0-9a-f]{6})([0-9a-f]{2})?$/i);
    if (m) { const n = parseInt(m[1], 16); return [n >> 16 & 255, n >> 8 & 255, n & 255, m[2] ? parseInt(m[2], 16) / 255 : 1]; }
    const r = c.match(/rgba?\(([^)]+)\)/); if (r) { const p = r[1].split(',').map(Number); return [p[0], p[1], p[2], p[3] ?? 1]; }
    return [255, 255, 255, 1];
  }
  // ColorMode: { mode: 'single'|'ramp'|'random'|'randomRamp', colors: [...] | [[...],[...]] }
  function colorAt(sys, p, life) {
    const cm = sys.colors;
    if (cm.mode === 'single') return cm.colors[0];
    if (cm.mode === 'random') return p.fixedColor;
    const ramp = cm.mode === 'randomRamp' ? p.ramp : cm.colors;   // Array-InterpolatedColor: lerp along the ramp by life progress
    const f = Math.min(0.9999, Math.max(0, life)) * (ramp.length - 1), i = Math.floor(f), t = f - i;
    const a = ramp[i], b = ramp[i + 1] || ramp[i];
    return [lerp(a[0], b[0], t), lerp(a[1], b[1], t), lerp(a[2], b[2], t), lerp(a[3], b[3], t)];
  }

  function System(o) {
    const s = Object.assign({
      position: [0.5, 0.5], shape: { type: 'point' }, birthRate: 100, emissionLimit: null,
      emissionDuration: 1, idleDuration: 0, burstCount: 100, burstCountVariation: 0,
      lifespan: 1, lifespanVariation: 0, speed: 1, speedVariation: 0, angle: 0, angleRange: 0,
      acceleration: [0, 0], attractionCenter: null, attractionStrength: 0, dampingFactor: 0,
      angularSpeed: [0, 0, 0], angularSpeedVariation: [0, 0, 0], colors: { mode: 'single', colors: ['#ffffff'] },
      size: 1, sizeVariation: 0, sizeMultiplierAtDeath: 1, stretchFactor: 1, symbol: 'circle', symbolSize: 32,
    }, o);
    s.colors = { mode: s.colors.mode, colors: s.colors.mode === 'randomRamp' ? s.colors.colors.map(r => r.map(parseColor)) : s.colors.colors.map(parseColor) };
    s.particles = []; s.outstanding = 0; s.emitted = 0; s.clock = 0; s.lastUpdate = null;
    return s;
  }

  function spawnPosition(s) {
    const [x, y] = s.position, sh = s.shape;
    if (sh.type === 'box') return [x + spread(sh.width), y + spread(sh.height)];
    if (sh.type === 'ellipse') { const a = Math.random() * Math.PI * 2, r = Math.random() * sh.radius; return [x + Math.cos(a) * r, y + Math.sin(a) * r]; }
    if (sh.type === 'ring') { const a = Math.random() * Math.PI * 2; return [x + Math.cos(a) * sh.radius, y + Math.sin(a) * sh.radius]; }
    return [x, y];
  }

  function makeParticle(s, now) {
    const launchAngle = deg(s.angle) + deg(spread(s.angleRange)) - Math.PI / 2;   // angle 0 = straight up
    const launchSpeed = s.speed + spread(s.speedVariation);
    const lifespan = s.lifespan + spread(s.lifespanVariation);
    const size = s.size + spread(s.sizeVariation);
    const c = s.colors, pick = a => a[Math.floor(Math.random() * a.length)];
    const p = {
      position: spawnPosition(s), speed: [Math.cos(launchAngle) * launchSpeed, Math.sin(launchAngle) * launchSpeed],
      birthTime: now, lifespan, initialSize: size, currentSize: size,
      angle: [0, 0, 0], angularSpeed: s.angularSpeed.map((v, i) => v + spread(s.angularSpeedVariation[i])),
      fixedColor: c.mode === 'random' ? pick(c.colors) : null, ramp: c.mode === 'randomRamp' ? pick(c.colors) : null,
    };
    p.color = colorAt(s, p, 0);   // a particle can be drawn before its first update
    return p;
  }

  function update(s, now, W, H) {
    if (s.lastUpdate == null) s.lastUpdate = now;
    const delta = Math.min(0.05, now - s.lastUpdate); s.lastUpdate = now;
    const drawDivisor = H / W;
    s.particles = s.particles.filter(p => {
      const age = now - p.birthTime, life = age / p.lifespan;
      if (s.attractionCenter) {
        const gap = [s.attractionCenter[0] - p.position[0], s.attractionCenter[1] - p.position[1]];
        const k = s.attractionStrength / 1000;
        p.speed[0] += gap[0] * k; p.speed[1] += gap[1] * k;
      }
      p.position[0] += p.speed[0] * delta * drawDivisor;
      p.position[1] += p.speed[1] * delta;
      if (s.dampingFactor !== 1) { const d = s.dampingFactor * delta / s.lifespan; p.speed[0] -= p.speed[0] * d; p.speed[1] -= p.speed[1] * d; }
      p.speed[0] += s.acceleration[0] * delta; p.speed[1] += s.acceleration[1] * delta;
      for (let i = 0; i < 3; i++) p.angle[i] += p.angularSpeed[i] * delta;
      p.currentSize = lerp(p.initialSize, p.initialSize * s.sizeMultiplierAtDeath, life);
      p.color = colorAt(s, p, life);
      return age < p.lifespan;
    });
    // emission: run for emissionDuration, rest for idleDuration (Spark uses this to pulse)
    s.clock += delta;
    const cycle = s.emissionDuration + s.idleDuration, inEmission = s.idleDuration === 0 || (s.clock % cycle) < s.emissionDuration;
    if (s.birthRate > 0 && inEmission && (s.emissionLimit == null || s.emitted < s.emissionLimit)) {
      s.outstanding += s.birthRate * delta;
      while (s.outstanding >= 1) { s.particles.push(makeParticle(s, now)); s.outstanding -= 1; s.emitted++; }
    }
  }

  const sprite = (() => {   // soft circle like Vortex's default "circle" symbol
    const c = document.createElement('canvas'); c.width = c.height = 64; const g = c.getContext('2d');
    const grd = g.createRadialGradient(32, 32, 0, 32, 32, 32); grd.addColorStop(0, 'rgba(255,255,255,1)'); grd.addColorStop(.45, 'rgba(255,255,255,.85)'); grd.addColorStop(1, 'rgba(255,255,255,0)');
    g.fillStyle = grd; g.fillRect(0, 0, 64, 64); return c;
  })();

  function draw(s, ctx, W, H) {
    for (const p of s.particles) {
      const x = p.position[0] * W, y = p.position[1] * H, px = s.symbolSize * p.currentSize;
      if (px <= 0.1) continue;
      const [r, g, b, a] = p.color;
      ctx.save(); ctx.translate(x, y);
      if (s.stretchFactor !== 1) {
        const v = Math.hypot(p.speed[0], p.speed[1]), stretch = Math.max(1, v * s.stretchFactor);
        ctx.rotate(Math.atan2(p.speed[1], p.speed[0]) + Math.PI / 2); ctx.scale(1, stretch);
      } else ctx.rotate(p.angle[2]);
      ctx.globalAlpha = a;
      if (s.symbol === 'square') { ctx.fillStyle = `rgb(${r|0},${g|0},${b|0})`; ctx.fillRect(-px / 2, -px / 2, px, px * Math.abs(Math.cos(p.angle[0]))); }
      else { ctx.globalCompositeOperation = 'lighter'; ctx.filter = 'none'; ctx.drawImage(tint(r, g, b), -px / 2, -px / 2, px, px); }
      ctx.restore();
    }
  }
  const tintCache = new Map();
  function tint(r, g, b) {
    const key = `${r>>4},${g>>4},${b>>4}`; if (tintCache.has(key)) return tintCache.get(key);
    const c = document.createElement('canvas'); c.width = c.height = 64; const g2 = c.getContext('2d');
    g2.drawImage(sprite, 0, 0); g2.globalCompositeOperation = 'source-in'; g2.fillStyle = `rgb(${r|0},${g|0},${b|0})`; g2.fillRect(0, 0, 64, 64);
    tintCache.set(key, c); return c;
  }

  function mount(canvas, systemOptions) {
    const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduce) return { burst() {}, stop() {}, system: null };
    const sys = System(systemOptions), ctx = canvas.getContext('2d');
    let raf, dpr = Math.min(2, devicePixelRatio || 1);
    const size = () => { canvas.width = canvas.clientWidth * dpr; canvas.height = canvas.clientHeight * dpr; };
    size(); const ro = new ResizeObserver(size); ro.observe(canvas);
    const frame = t => {
      const now = t / 1000, W = canvas.width, H = canvas.height;
      update(sys, now, W, H); ctx.clearRect(0, 0, W, H); draw(sys, ctx, W, H);
      raf = requestAnimationFrame(frame);
    };
    raf = requestAnimationFrame(frame);
    return {
      system: sys,
      burst(count) { const now = performance.now() / 1000, n = count ?? (sys.burstCount + Math.round(spread(sys.burstCountVariation))); for (let i = 0; i < n; i++) sys.particles.push(makeParticle(sys, now)); },
      move(x, y) { sys.position = [x, y]; },
      stop() { cancelAnimationFrame(raf); ro.disconnect(); ctx.clearRect(0, 0, canvas.width, canvas.height); },
    };
  }

  // Presets: values copied from Vortex/Sources/Vortex/Presets/*.swift. Colors are overridable for brand use.
  const presets = {
    spark: (o = {}) => ({ birthRate: 150, emissionDuration: 0.2, idleDuration: 0.5, lifespan: 1.5, speed: 1.25, speedVariation: 0.2,
      angle: 330, angleRange: 20, acceleration: [0, 3], dampingFactor: 4, colors: { mode: 'ramp', colors: o.ramp || ['#ffffff', '#ffd60a', '#ffd60a00'] },
      size: 0.1, sizeVariation: 0.1, stretchFactor: 8, ...o }),
    fireflies: (o = {}) => ({ shape: { type: 'ellipse', radius: 0.5 }, birthRate: 200, lifespan: 2, speed: 0, speedVariation: 0.25, angleRange: 360,
      colors: { mode: 'ramp', colors: o.ramp || ['#ffd60a', '#ffd60a', '#ffd60a00'] }, size: 0.01, sizeMultiplierAtDeath: 100, ...o }),
    magic: (o = {}) => ({ shape: { type: 'ring', radius: 0.5 }, lifespan: 1.5, speed: 0, speedVariation: 0.2, angleRange: 360, angularSpeedVariation: [0, 0, 10],
      colors: { mode: 'random', colors: o.palette || ['#ff3b30', '#ff2d55', '#ff9500', '#007aff', '#34c759', '#ffffff'] }, size: 0.5, sizeVariation: 0.5, sizeMultiplierAtDeath: 0.01, ...o }),
    smoke: (o = {}) => ({ shape: { type: 'box', width: 0.05, height: 0 }, lifespan: 3, speed: 0.1, speedVariation: 0.1, angleRange: 10,
      colors: { mode: 'ramp', colors: o.ramp || ['#8e8e93', '#8e8e9300'] }, size: 0.5, sizeVariation: 0.5, sizeMultiplierAtDeath: 2, ...o }),
    confetti: (o = {}) => ({ symbol: 'square', birthRate: 0, lifespan: 4, speed: 0.5, speedVariation: 0.5, angleRange: 90, acceleration: [0, 1], angularSpeedVariation: [4, 4, 4],
      colors: { mode: 'random', colors: o.palette || ['#ffffff', '#ff3b30', '#34c759', '#007aff', '#ff2d55', '#ff9500', '#32ade6'] }, size: 0.5, sizeVariation: 0.5, symbolSize: 18, ...o }),
  };

  global.Vortex = { mount, presets, System };
})(window);
