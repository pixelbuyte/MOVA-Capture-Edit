import { useEffect, useRef, useState, type ReactNode, type CSSProperties } from 'react'
import { motion } from 'framer-motion'
import { ArrowRight, House, Aperture, FilmSlate, SquaresFour, VideoCamera, Camera, Sparkle, Timer, User, ArrowsLeftRight } from '@phosphor-icons/react'
import './lib/vortex.js'
import './lib/pow.js'

declare global { interface Window { Vortex: any; Pow: any } }

export const spring = { type: 'spring' as const, stiffness: 420, damping: 34, mass: 0.9 }
export const soft = { type: 'spring' as const, stiffness: 220, damping: 28 }

/* ── Vortex particle canvas (twostraws/Vortex port) ── */
export function VortexCanvas({ preset, opts, burstEvery, style }: { preset: string; opts?: any; burstEvery?: number; style?: CSSProperties }) {
  const ref = useRef<HTMLCanvasElement>(null)
  useEffect(() => {
    const c = ref.current!
    const r = c.getBoundingClientRect(); c.width = r.width * 2; c.height = r.height * 2
    const v = window.Vortex.mount(c, window.Vortex.presets[preset](opts || {}))
    let id: any
    if (burstEvery) { v.burst(90); id = setInterval(() => v.burst(90), burstEvery) }
    return () => { clearInterval(id); v.stop() }
  }, [preset])
  return <canvas ref={ref} className="vortex" style={style} aria-hidden />
}

/* ── Primary CTA: button-in-button ── */
export function Primary({ children, onClick, icon, full }: { children: ReactNode; onClick?: () => void; icon?: ReactNode; full?: boolean }) {
  return (
    <button className="btn btn-primary" onClick={() => { window.Pow.haptic('impact'); onClick?.() }} style={full ? { width: '100%', justifyContent: 'space-between' } : undefined}>
      <span>{children}</span>
      <span className="nub">{icon ?? <ArrowRight size={20} weight="bold" />}</span>
    </button>
  )
}

/* ── Tab bar with a morphing glass selection blob (layoutId) ── */
export type Tab = 'home' | 'library' | 'editor' | 'profile'
export function TabBar({ tab, go }: { tab: Tab; go: (s: string) => void }) {
  const items: { id: Tab; label: string; I: any }[] = [
    { id: 'home', label: 'Studio', I: House },
    { id: 'library', label: 'Library', I: SquaresFour },
    { id: 'editor', label: 'Edit', I: FilmSlate },
    { id: 'profile', label: 'You', I: User },
  ]
  const btn = (it: (typeof items)[number]) => (
    <button key={it.id} className="tab" role="tab" aria-selected={tab === it.id} onClick={() => go(it.id)}>
      {tab === it.id && <motion.span layoutId="tabblob" className="blob" transition={spring} />}
      <it.I size={24} weight={tab === it.id ? 'duotone' : 'regular'} color={tab === it.id ? 'var(--p-orange-400)' : undefined} />
      {it.label}
    </button>
  )
  return (
    <nav className="tabbar glass" role="tablist" aria-label="Main">
      {btn(items[0])}{btn(items[1])}
      <button className="tab-shoot" aria-label="Open camera" onClick={() => go('camera')}><Aperture size={30} weight="duotone" /></button>
      {btn(items[2])}{btn(items[3])}
    </nav>
  )
}

/* ── Shutter with radial mode menu (SwiftUI-experiments radial menu math) ── */
export const MODES = [
  { id: 'Recreate', I: Sparkle },
  { id: 'Video', I: VideoCamera },
  { id: 'Photo', I: Camera },
  { id: 'Slo-mo', I: Timer },
  { id: 'Portrait', I: User },
  { id: 'Pan', I: ArrowsLeftRight },
]
export function Shutter({ recording, onTap, onMode }: { recording: boolean; onTap: () => void; onMode: (m: string) => void }) {
  const [open, setOpen] = useState(false)
  const [sel, setSel] = useState<number | null>(null)
  const [d, setD] = useState(0)
  const o = useRef<{ x: number; y: number } | null>(null)
  const timer = useRef<any>(null)
  const R = 92, segs = MODES.length, segSize = 360 / segs
  const segmentFor = (dx: number, dy: number, dist: number) => {
    if (dist <= 18) return null
    const a = (Math.atan2(dy, dx) * 180 / Math.PI + 360) % 360
    return Math.floor(((a + 90 + segSize / 2) % 360) / segSize) % segs
  }
  return (
    <div style={{ position: 'relative' }}>
      {open && (
        <div className="radial" style={{ left: 42, top: 42 }} role="menu" aria-label="Capture mode">
          <motion.div className="hub" initial={{ scale: .4, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} transition={spring} />
          {MODES.map((m, i) => {
            const mid = i * segSize, x = Math.cos((mid - 90) * Math.PI / 180) * R, y = Math.sin((mid - 90) * Math.PI / 180) * R
            const e = i === sel ? 0.3 * (1 - Math.exp(-d / 50)) : 0
            return (
              <motion.div key={m.id} role="menuitem" className={'it' + (i === sel ? ' sel' : '')}
                initial={{ x: 0, y: 0, scale: .3, opacity: 0 }} animate={{ x: x * (1 + e), y: y * (1 + e), scale: 1 + e, opacity: 1 }}
                transition={{ ...spring, delay: i * 0.02 }}>
                <m.I size={20} weight="duotone" />{m.id}
              </motion.div>
            )
          })}
        </div>
      )}
      <button className="shutter" aria-label={recording ? 'Stop recording' : 'Record. Press and hold for modes'}
        onPointerDown={e => {
          e.currentTarget.setPointerCapture?.(e.pointerId)
          o.current = { x: e.clientX, y: e.clientY }
          timer.current = setTimeout(() => { setOpen(true); window.Pow.haptic('impact') }, 280)
        }}
        onPointerMove={e => {
          if (!open || !o.current) return
          const dx = e.clientX - o.current.x, dy = e.clientY - o.current.y, dist = Math.hypot(dx, dy)
          const s = segmentFor(dx, dy, dist)
          if (s !== sel && s != null) window.Pow.haptic('selection')
          setSel(s); setD(dist)
        }}
        onPointerUp={() => {
          clearTimeout(timer.current)
          if (open) { if (sel != null) onMode(MODES[sel].id); setOpen(false); setSel(null); setD(0) }
          else onTap()
        }}
        onKeyDown={e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onTap() } }}>
        <span className="ring" />
        <motion.span className="core" animate={recording ? { width: 30, height: 30, borderRadius: 9, background: 'var(--rec)' } : { width: 66, height: 66, borderRadius: 33 }} transition={spring} />
      </button>
    </div>
  )
}

/* ── 2D look trackpad (SwiftUI-experiments draggable slider, two axes + soft detents) ── */
export function LookPad({ x, y, onChange }: { x: number; y: number; onChange: (x: number, y: number) => void }) {
  const ref = useRef<HTMLDivElement>(null)
  const last = useRef('')
  const set = (cx: number, cy: number) => {
    const r = ref.current!.getBoundingClientRect()
    const nx = Math.min(1, Math.max(0, (cx - r.left) / r.width)), ny = Math.min(1, Math.max(0, (cy - r.top) / r.height))
    const key = Math.round(nx * 4) + ':' + Math.round(ny * 3)
    if (key !== last.current) { last.current = key; window.Pow.haptic('selection') }
    onChange(nx, ny)
  }
  return (
    <div ref={ref} className="pad2d" role="slider" tabIndex={0} aria-label="Look: warm to cool, soft to punchy"
      aria-valuetext={`${Math.round((1 - x) * 100)}% warm, ${Math.round((1 - y) * 100)}% punchy`}
      onPointerDown={e => { (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId); set(e.clientX, e.clientY) }}
      onPointerMove={e => { if (e.buttons) set(e.clientX, e.clientY) }}
      onKeyDown={e => {
        const s = 0.05, m: any = { ArrowLeft: [-s, 0], ArrowRight: [s, 0], ArrowUp: [0, -s], ArrowDown: [0, s] }[e.key]
        if (m) { e.preventDefault(); onChange(Math.min(1, Math.max(0, x + m[0])), Math.min(1, Math.max(0, y + m[1]))) }
      }}>
      <div className="grid" />
      <span className="ax" style={{ left: 12, top: '50%', translate: '0 -50%' }}>Warm</span>
      <span className="ax" style={{ right: 12, top: '50%', translate: '0 -50%' }}>Cool</span>
      <span className="ax" style={{ top: 10, left: '50%', translate: '-50% 0' }}>Punchy</span>
      <span className="ax" style={{ bottom: 10, left: '50%', translate: '-50% 0' }}>Soft</span>
      <motion.span className="knob" animate={{ left: `${x * 100}%`, top: `${y * 100}%` }} transition={{ type: 'spring', stiffness: 700, damping: 40 }} />
    </div>
  )
}
export const padFilter = (x: number, y: number) => {
  const warm = 1 - x, punch = 1 - y
  return `sepia(${(warm * 0.35).toFixed(2)}) hue-rotate(${((x - 0.5) * 30).toFixed(0)}deg) saturate(${(0.85 + punch * 0.6).toFixed(2)}) contrast(${(0.92 + punch * 0.3).toFixed(2)})`
}

/* ── Before / after compare slider ── */
export function Compare({ a, b, h = 420 }: { a: string; b: string; h?: number }) {
  const [p, setP] = useState(0.5)
  const ref = useRef<HTMLDivElement>(null)
  const set = (cx: number) => { const r = ref.current!.getBoundingClientRect(); setP(Math.min(.97, Math.max(.03, (cx - r.left) / r.width))) }
  return (
    <div ref={ref} className="cmp" style={{ height: h, borderRadius: 25 }} role="slider" tabIndex={0} aria-label="Compare reference and your take" aria-valuenow={Math.round(p * 100)}
      onPointerDown={e => { (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId); set(e.clientX) }}
      onPointerMove={e => { if (e.buttons) set(e.clientX) }}
      onKeyDown={e => { if (e.key === 'ArrowLeft') setP(v => Math.max(.03, v - .05)); if (e.key === 'ArrowRight') setP(v => Math.min(.97, v + .05)) }}>
      <img src={b} alt="Your take" />
      <img src={a} alt="Reference" style={{ clipPath: `inset(0 ${(1 - p) * 100}% 0 0)` }} />
      <span className="chip media" style={{ position: 'absolute', left: 12, top: 12 }}>Reference</span>
      <span className="chip media" style={{ position: 'absolute', right: 12, top: 12, background: 'rgba(255,122,47,.85)', color: 'var(--action-ink)' }}>Your take</span>
      <div className="handle" style={{ left: `${p * 100}%` }}><b><ArrowsLeftRight size={20} weight="bold" /></b></div>
    </div>
  )
}

/* ── Progress ring ── */
export function Ring({ v, size = 44, stroke = 4, color = 'var(--select)', children }: { v: number; size?: number; stroke?: number; color?: string; children?: ReactNode }) {
  const r = (size - stroke) / 2, c = 2 * Math.PI * r
  return (
    <div style={{ position: 'relative', width: size, height: size, flex: 'none' }}>
      <svg width={size} height={size} style={{ rotate: '-90deg' }}>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="rgba(124,226,214,.14)" strokeWidth={stroke} />
        <motion.circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color} strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={c} initial={{ strokeDashoffset: c }} animate={{ strokeDashoffset: c * (1 - v) }} transition={{ duration: .9, ease: [.16, 1, .3, 1] }} />
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'grid', placeItems: 'center' }}>{children}</div>
    </div>
  )
}
