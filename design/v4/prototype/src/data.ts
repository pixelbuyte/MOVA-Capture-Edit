import { street, skate, dancer, recreated, rooftop, stilllife, surf, portrait } from './imgs'

export const IMG = { street, skate, dancer, recreated, rooftop, stilllife, surf, portrait }

export type Template = { id: string; title: string; img: string; shots: number; dur: string; tag: string; level: 1 | 2 | 3; uses: string }
export const TEMPLATES: Template[] = [
  { id: 'neon', title: 'Neon Walk', img: street, shots: 4, dur: '0:12', tag: 'Trending', level: 1, uses: '18.2k' },
  { id: 'ollie', title: 'Golden Ollie', img: skate, shots: 3, dur: '0:08', tag: 'Action', level: 3, uses: '9.4k' },
  { id: 'spin', title: 'Warehouse Spin', img: dancer, shots: 5, dur: '0:15', tag: 'Dance', level: 2, uses: '12.7k' },
  { id: 'shore', title: 'Last Light', img: surf, shots: 3, dur: '0:10', tag: 'Travel', level: 1, uses: '6.1k' },
  { id: 'roof', title: 'Rooftop Laugh', img: rooftop, shots: 4, dur: '0:11', tag: 'Friends', level: 1, uses: '7.8k' },
]

/* Shot breakdown for Neon Walk. Crop = background-position on the reference frame. */
export type Shot = { n: number; name: string; framing: string; move: 'dolly' | 'pan' | 'static' | 'tilt'; dur: number; pos: string; color: string; tip: string }
export const SHOTS: Shot[] = [
  { n: 1, name: 'Wide approach', framing: 'Wide · eye level', move: 'dolly', dur: 3.2, pos: '50% 60%', color: 'var(--p-orange-500)', tip: 'Walk backwards slowly, phone at chest height.' },
  { n: 2, name: 'Jacket detail', framing: 'Close · low', move: 'tilt', dur: 2.1, pos: '30% 45%', color: 'var(--p-amber-400)', tip: 'Tilt up from the hands to the collar.' },
  { n: 3, name: 'Over-the-shoulder', framing: 'Medium · eye level', move: 'pan', dur: 3.4, pos: '70% 30%', color: 'var(--p-teal-400)', tip: 'Pan left with the subject as they pass.' },
  { n: 4, name: 'Face to neon', framing: 'Close-up · slight low', move: 'static', dur: 3.3, pos: '45% 18%', color: 'var(--p-rose-400)', tip: 'Hold still. Let the light do the work.' },
]

export type Look = { id: string; name: string; filter: string }
export const LOOKS: Look[] = [
  { id: 'none', name: 'Natural', filter: 'none' },
  { id: 'tungsten', name: 'Tungsten', filter: 'sepia(.28) saturate(1.3) hue-rotate(-8deg) contrast(1.06)' },
  { id: 'teal', name: 'Teal Night', filter: 'saturate(1.15) hue-rotate(14deg) brightness(.9) contrast(1.18)' },
  { id: 'sodium', name: 'Sodium', filter: 'sepia(.55) saturate(1.7) hue-rotate(-14deg) brightness(.96)' },
  { id: 'bleach', name: 'Bleach', filter: 'saturate(.42) contrast(1.32) brightness(1.06)' },
  { id: 'k2383', name: 'Print 2383', filter: 'contrast(1.14) saturate(1.18) sepia(.14) brightness(.97)' },
]

export const SCORES = [
  { k: 'Framing', v: 92 },
  { k: 'Camera move', v: 81 },
  { k: 'Color', v: 88 },
  { k: 'Timing', v: 74 },
]

export const LIBRARY = [
  { img: recreated, d: '0:12', t: 'Neon Walk · take 2' },
  { img: portrait, d: 'Photo', t: 'Window light' },
  { img: stilllife, d: 'Photo', t: 'Still life' },
  { img: rooftop, d: '0:11', t: 'Rooftop Laugh' },
  { img: dancer, d: '0:15', t: 'Warehouse Spin' },
  { img: surf, d: '0:10', t: 'Last Light' },
  { img: skate, d: '0:08', t: 'Golden Ollie' },
  { img: street, d: '0:12', t: 'Reference · Neon Walk' },
]

/* waveform: deterministic pseudo-random heights; every 6th bar is a detected beat */
export const WAVE = Array.from({ length: 56 }, (_, i) => {
  const h = 0.25 + 0.75 * Math.abs(Math.sin(i * 1.7) * Math.cos(i * 0.37))
  return { h, beat: i % 7 === 3 }
})
