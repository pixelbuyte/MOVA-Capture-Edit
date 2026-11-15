// Renders design/demo.html to frames, deterministic per-frame.
// Usage: node tools/render-demo.js <outDir> [fps] [onlyTimesCommaSeparated]
// Needs a static server for design/ on http://localhost:8765 (python3 -m http.server 8765)
const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const out = process.argv[2] || 'frames';
  const fps = +(process.argv[3] || 30);
  const mode = process.env.MODE || 'full'; // full | screen
  const only = process.argv[4] ? process.argv[4].split(',').map(Number) : null;
  fs.mkdirSync(out, { recursive: true });
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: mode === 'screen' ? { width: 390, height: 844 } : { width: 1920, height: 1080 }, deviceScaleFactor: 1 });
  await page.goto('http://localhost:8765/demo.html?capture' + (mode === 'screen' ? '&screen' : ''), { waitUntil: 'networkidle' });
  await page.waitForFunction(() => window.ready && window.ready(), null, { timeout: 60000 });
  await page.waitForTimeout(500);
  const times = only || (mode === 'screen' ? Array.from({ length: Math.round(41.6 * fps) }, (_, i) => 3.8 + i / fps) : Array.from({ length: Math.round(49 * fps) }, (_, i) => i / fps));
  for (let i = 0; i < times.length; i++) {
    await page.evaluate(t => window.render(t), times[i]);
    const name = only ? `t${times[i]}.jpg` : `f${String(i).padStart(5, '0')}.jpg`;
    await page.screenshot({ path: `${out}/${name}`, type: 'jpeg', quality: 92 });
    if (i % 150 === 0) console.log('frame', i, '/', times.length);
  }
  await browser.close();
})();
