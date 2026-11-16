import { useEffect, useRef, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  CaretLeft, ShareNetwork, Play, Pause, Sparkle, LinkSimple, Bell, CheckCircle, CircleNotch, Circle, Info, X, Ghost, CameraRotate,
  Faders, ArrowDown, Scissors, Palette, TextT, MusicNotes, MagicWand, SkipBack, SkipForward, DownloadSimple, TiktokLogo,
  InstagramLogo, YoutubeLogo, Copy, ArrowCounterClockwise, Waveform, ArrowsOutSimple, ArrowsVertical, ArrowsHorizontal,
  Crosshair, FilmStrip, Clock, Swatches, Fire, Crown, Vibrate, HardDrives, Plus, Target, Lightning, ArrowUpRight, Sun,
} from '@phosphor-icons/react'
import { IMG, TEMPLATES, SHOTS, LOOKS, SCORES, LIBRARY, WAVE, type Shot } from './data'
import { VortexCanvas, Primary, TabBar, Shutter, LookPad, padFilter, Compare, Ring, spring, soft, MODES } from './ui'

export type Ctx = {
  go: (s: string) => void
  look: string; setLook: (l: string) => void
  pad: [number, number]; setPad: (p: [number, number]) => void
  done: number; setDone: (n: number) => void
}
const lookFilter = (id: string) => LOOKS.find(l => l.id === id)?.filter ?? 'none'
const stagger = (i: number) => ({ initial: { opacity: 0, y: 14 }, animate: { opacity: 1, y: 0 }, transition: { ...soft, delay: 0.05 + i * 0.05 } })
const MoveIcon = ({ m, size = 16 }: { m: Shot['move']; size?: number }) => {
  const I = { dolly: ArrowsOutSimple, tilt: ArrowsVertical, pan: ArrowsHorizontal, static: Crosshair }[m]
  return <I size={size} weight="duotone" color="var(--p-teal-300)" />
}
const moveLabel = { dolly: 'Dolly in', tilt: 'Tilt up', pan: 'Pan left', static: 'Locked off' }
const Crop = ({ pos, h, w, r = 12 }: { pos: string; h: number; w: number | string; r?: number }) => (
  <div style={{ width: w, height: h, borderRadius: r, backgroundImage: `url(${IMG.street})`, backgroundSize: '260%', backgroundPosition: pos, flex: 'none' }} />
)
const Back = ({ onClick, media }: { onClick: () => void; media?: boolean }) => (
  <button className={'icon-btn' + (media ? '' : ' flat')} aria-label="Back" onClick={onClick}><CaretLeft size={20} weight="bold" /></button>
)
const Segs = ({ done = 99, h = 6 }: { done?: number; h?: number }) => (
  <div className="segs" style={{ height: h }}>
    {SHOTS.map((s, i) => <i key={s.n} style={{ ['--w' as any]: s.dur, ['--c' as any]: i < done ? s.color : 'rgba(255,247,236,.22)' }} />)}
  </div>
)

/* ───────────── 01 Welcome ───────────── */
export function Welcome({ go }: Ctx) {
  return (
    <div className="page" style={{ overflow: 'hidden' }}>
      <motion.img src={IMG.street} alt="" className="media-img" style={{ position: 'absolute', inset: 0, height: '74%' }}
        initial={{ scale: 1.12 }} animate={{ scale: 1 }} transition={{ duration: 2.4, ease: [.16, 1, .3, 1] }} />
      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(7,20,22,.35) 0%, rgba(7,20,22,0) 22%, rgba(7,20,22,0) 42%, var(--bg) 74%)' }} />
      <VortexCanvas preset="fireflies" opts={{ ramp: ['#FFB27A', '#FF7A2F', '#FF7A2F00'], birthRate: 26, lifespan: 2.6, size: 0.004, sizeMultiplierAtDeath: 60 }} style={{ height: '70%' }} />
      <div className="brandmark" style={{ position: 'absolute', top: 64, left: 24 }}><i />MOVA</div>

      <motion.div className="glass" style={{ position: 'absolute', top: 300, right: 18, width: 186, borderRadius: 20, padding: 12 }}
        initial={{ opacity: 0, x: 30 }} animate={{ opacity: 1, x: 0 }} transition={{ ...soft, delay: .7 }}>
        <div className="row between" style={{ marginBottom: 9 }}>
          <span className="chip o" style={{ height: 24 }}><Sparkle size={13} weight="fill" /> 4 shots found</span>
          <span className="mono" style={{ fontSize: 11, color: 'var(--on-media)' }}>0:12</span>
        </div>
        <Segs />
        <div className="row" style={{ gap: 6, marginTop: 10 }}>
          {SHOTS.map(s => <Crop key={s.n} pos={s.pos} w={37} h={50} r={8} />)}
        </div>
      </motion.div>

      <div style={{ position: 'absolute', left: 24, right: 24, bottom: 38 }}>
        <motion.span className="chip t" {...stagger(0)}><Target size={14} weight="duotone" /> Reference recreation</motion.span>
        <motion.h1 className="h-xl" style={{ fontSize: 46, margin: '16px 0 14px' }} {...stagger(1)}>Shoot it like<br />you <span style={{ color: 'var(--action)' }}>saw</span> it.</motion.h1>
        <motion.p className="lede" style={{ marginBottom: 26 }} {...stagger(2)}>Drop in any clip. MOVA breaks it into shots, then coaches your framing, movement and timing — one take at a time.</motion.p>
        <motion.div {...stagger(3)}><Primary full onClick={() => go('home')}>Start creating</Primary></motion.div>
        <motion.button {...stagger(4)} onClick={() => go('home')} style={{ display: 'block', margin: '16px auto 0', fontSize: 14, color: 'var(--text-2)' }}>I already have an account</motion.button>
      </div>
    </div>
  )
}

/* ───────────── 02 Studio (home) ───────────── */
export function Home({ go }: Ctx) {
  const hero = TEMPLATES[0]
  return (
    <div className="page">
      <div className="pad">
        <motion.div className="row between" {...stagger(0)}>
          <div>
            <div className="label" style={{ color: 'var(--action)' }}>Tuesday · Golden hour 6:42</div>
            <h1 className="h-l" style={{ marginTop: 6 }}>What are we<br />shooting tonight?</h1>
          </div>
          <div className="row" style={{ gap: 8, alignSelf: 'flex-start' }}>
            <button className="icon-btn flat" aria-label="Notifications" style={{ position: 'relative' }}><Bell size={20} weight="duotone" />
              <i style={{ position: 'absolute', top: 10, right: 11, width: 8, height: 8, borderRadius: 4, background: 'var(--action)' }} /></button>
          </div>
        </motion.div>

        {/* hero recreate card — shares layoutId with the Reference screen */}
        <motion.div className="bezel" style={{ marginTop: 20 }} {...stagger(1)}>
          <motion.div layoutId="ref-neon" className="core" style={{ height: 318 }} transition={spring} onClick={() => go('reference')}>
            <img src={hero.img} alt="Neon Walk reference clip" className="media-img" />
            <div style={{ position: 'absolute', inset: 0, background: 'var(--scrim)' }} />
            <div className="row" style={{ position: 'absolute', top: 14, left: 14, gap: 6 }}>
              <span className="chip media"><Fire size={14} weight="fill" color="var(--p-orange-400)" /> Trending</span>
              <span className="chip media">{hero.uses} recreated</span>
            </div>
            <div style={{ position: 'absolute', left: 16, right: 16, bottom: 16 }}>
              <div className="row between" style={{ alignItems: 'flex-end' }}>
                <div>
                  <div className="h-l" style={{ color: 'var(--on-media)' }}>{hero.title}</div>
                  <div className="mono" style={{ fontSize: 12, color: 'rgba(255,247,236,.75)', marginTop: 4 }}>4 shots · 0:12</div>
                </div>
                <button className="btn btn-primary" style={{ height: 44, padding: '0 16px', fontSize: 14 }} onClick={e => { e.stopPropagation(); go('reference') }}>
                  <Sparkle size={16} weight="fill" /> Recreate</button>
              </div>
              <div style={{ marginTop: 12 }}><Segs /></div>
            </div>
          </motion.div>
        </motion.div>

        {/* paste link */}
        <motion.div className="card row" style={{ marginTop: 14, padding: '10px 10px 10px 14px', gap: 12 }} {...stagger(2)}>
          <div style={{ width: 40, height: 40, borderRadius: 13, background: 'rgba(79,224,208,.12)', display: 'grid', placeItems: 'center' }}><LinkSimple size={21} weight="duotone" color="var(--select)" /></div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontWeight: 600, fontSize: 14 }}>Recreate any clip</div>
            <div style={{ fontSize: 12.5, color: 'var(--text-3)' }}>Paste a TikTok, Reel or Short link</div>
          </div>
          <button className="btn btn-teal" style={{ height: 38, fontSize: 13, padding: '0 14px' }}>Paste</button>
        </motion.div>

        <motion.div className="row between" style={{ margin: '28px 0 12px' }} {...stagger(3)}>
          <h2 className="h-m">Templates</h2><button style={{ fontSize: 13, color: 'var(--select)', fontWeight: 600 }}>See all</button>
        </motion.div>
        <motion.div className="rail" {...stagger(4)}>
          {TEMPLATES.slice(1).map(t => (
            <button key={t.id} style={{ width: 142, textAlign: 'left' }} onClick={() => go('reference')}>
              <div style={{ position: 'relative', height: 200, borderRadius: 20, overflow: 'hidden' }}>
                <img src={t.img} alt="" className="media-img" />
                <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg,transparent 55%,rgba(5,14,16,.8))' }} />
                <span className="chip media" style={{ position: 'absolute', top: 8, left: 8, height: 24, fontSize: 11 }}>{t.tag}</span>
                <span className="mono" style={{ position: 'absolute', bottom: 9, left: 10, fontSize: 11, color: 'var(--on-media)' }}>{t.shots} shots · {t.dur}</span>
              </div>
              <div style={{ fontWeight: 600, fontSize: 14, marginTop: 8 }}>{t.title}</div>
              <div className="row" style={{ gap: 3, marginTop: 4 }}>
                {[1, 2, 3].map(l => <i key={l} style={{ width: 14, height: 4, borderRadius: 2, background: l <= t.level ? 'var(--select)' : 'var(--surface-3)' }} />)}
                <span style={{ fontSize: 11, color: 'var(--text-3)', marginLeft: 6 }}>{['', 'Easy', 'Medium', 'Hard'][t.level]}</span>
              </div>
            </button>
          ))}
        </motion.div>

        <motion.h2 className="h-m" style={{ margin: '28px 0 12px' }} {...stagger(5)}>Pick up where you left off</motion.h2>
        {[{ img: IMG.recreated, t: 'Neon Walk', s: '3 of 4 shots', v: .75 }, { img: IMG.rooftop, t: 'Rooftop Laugh', s: 'Editing · 2 looks tried', v: .4 }].map((p, i) => (
          <motion.button key={p.t} className="card row" style={{ width: '100%', padding: 10, gap: 12, marginBottom: 10, textAlign: 'left' }} onClick={() => go(i ? 'editor' : 'camera')} {...stagger(6 + i)}>
            <img src={p.img} alt="" style={{ width: 52, height: 66, borderRadius: 12, objectFit: 'cover' }} />
            <div style={{ flex: 1 }}><div style={{ fontWeight: 600 }}>{p.t}</div><div style={{ fontSize: 12.5, color: 'var(--text-3)', marginTop: 2 }}>{p.s}</div></div>
            <Ring v={p.v}><span className="mono" style={{ fontSize: 11 }}>{Math.round(p.v * 100)}</span></Ring>
          </motion.button>
        ))}
      </div>
    </div>
  )
}

/* ───────────── 03 Reference ───────────── */
export function Reference({ go }: Ctx) {
  const [playing, setPlaying] = useState(false)
  return (
    <div className="page">
      <motion.div layoutId="ref-neon" style={{ position: 'relative', height: 486, overflow: 'hidden', borderRadius: '0 0 34px 34px' }} transition={spring}>
        <motion.img src={IMG.street} alt="Neon Walk reference clip" className="media-img" animate={playing ? { scale: 1.08 } : { scale: 1 }} transition={{ duration: 3.2, ease: 'linear' }} />
        <div style={{ position: 'absolute', inset: 0, background: 'var(--scrim)' }} />
        <div className="row between" style={{ position: 'absolute', top: 56, left: 18, right: 18 }}>
          <Back media onClick={() => go('home')} />
          <button className="icon-btn" aria-label="Share"><ShareNetwork size={20} weight="duotone" /></button>
        </div>
        <button className="icon-btn" aria-label={playing ? 'Pause' : 'Play'} onClick={() => setPlaying(p => !p)}
          style={{ position: 'absolute', left: '50%', top: '44%', translate: '-50% -50%', width: 68, height: 68 }}>
          {playing ? <Pause size={28} weight="fill" /> : <Play size={28} weight="fill" />}
        </button>
        <div style={{ position: 'absolute', left: 20, right: 20, bottom: 20 }}>
          <span className="chip media">Reference · @nightwalks</span>
          <h1 className="h-xl" style={{ color: 'var(--on-media)', margin: '10px 0 14px' }}>Neon Walk</h1>
          <Segs />
          <div className="row between mono" style={{ fontSize: 11, color: 'rgba(255,247,236,.7)', marginTop: 7 }}><span>0:00</span><span>0:12</span></div>
        </div>
      </motion.div>

      <div style={{ padding: '22px 20px 130px' }}>
        <motion.div className="label" {...stagger(0)}>What MOVA can see</motion.div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginTop: 12 }}>
          {[
            { I: FilmStrip, c: 'var(--p-orange-400)', k: 'Shots', v: '4 cuts' },
            { I: ArrowsOutSimple, c: 'var(--p-teal-400)', k: 'Camera', v: 'Dolly + pan' },
            { I: Waveform, c: 'var(--p-amber-400)', k: 'Beat', v: '96 BPM' },
            { I: Sun, c: 'var(--p-rose-400)', k: 'Light', v: 'Blue hour, neon' },
          ].map((s, i) => (
            <motion.div key={s.k} className="card" style={{ padding: 14 }} {...stagger(i + 1)}>
              <s.I size={24} weight="duotone" color={s.c} />
              <div style={{ fontSize: 12, color: 'var(--text-3)', marginTop: 10 }}>{s.k}</div>
              <div style={{ fontWeight: 600, fontSize: 15, marginTop: 2 }}>{s.v}</div>
            </motion.div>
          ))}
        </div>
        <motion.div className="card" style={{ padding: 14, marginTop: 10 }} {...stagger(5)}>
          <div className="row between"><span style={{ fontSize: 12, color: 'var(--text-3)' }}>Color grade</span><span className="chip o" style={{ height: 24 }}>Teal / orange</span></div>
          <div className="row" style={{ gap: 6, marginTop: 12 }}>
            {['#0B3940', '#1D6D74', '#3FA8A0', '#F2863A', '#FFC77A', '#2A1712'].map(c => <i key={c} style={{ flex: 1, height: 34, borderRadius: 10, background: c }} />)}
          </div>
        </motion.div>
      </div>
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: '30px 20px 30px', background: 'linear-gradient(180deg, transparent, var(--bg) 40%)' }}>
        <Primary full onClick={() => go('analyze')} icon={<Sparkle size={20} weight="fill" />}>Break it into shots</Primary>
      </div>
    </div>
  )
}

/* ───────────── 04 Analyze ───────────── */
const STEPS = ['Finding the cuts', 'Reading camera movement', 'Matching color and light', 'Mapping the beat']
export function Analyze({ go }: Ctx) {
  const [stage, setStage] = useState(0)
  useEffect(() => {
    if (stage >= STEPS.length) return
    const t = setTimeout(() => setStage(s => s + 1), 650)
    return () => clearTimeout(t)
  }, [stage])
  const ready = stage >= STEPS.length
  return (
    <div className="page">
      <div className="pad" style={{ paddingBottom: 140 }}>
        <div className="row" style={{ gap: 12 }}>
          <Back onClick={() => go('reference')} />
          <div><div className="label">Neon Walk · 0:12</div><div className="h-m" style={{ marginTop: 3 }}>{ready ? 'Your shot list' : 'Breaking it down…'}</div></div>
        </div>

        <div className="card" style={{ padding: '6px 16px', marginTop: 20 }}>
          {STEPS.map((s, i) => (
            <div key={s} className="row" style={{ gap: 12, height: 46, borderBottom: i < 3 ? '1px solid var(--line)' : 0 }}>
              <AnimatePresence mode="wait" initial={false}>
                {i < stage ? <motion.span key="d" initial={{ scale: 0 }} animate={{ scale: 1 }} transition={spring}><CheckCircle size={22} weight="fill" color="var(--select)" /></motion.span>
                  : i === stage ? <motion.span key="a"><CircleNotch size={22} weight="bold" color="var(--action)" className="spin" /></motion.span>
                    : <motion.span key="p"><Circle size={22} color="var(--surface-3)" /></motion.span>}
              </AnimatePresence>
              <span style={{ fontSize: 14.5, color: i <= stage ? 'var(--text)' : 'var(--text-3)' }}>{s}</span>
              {i < stage && <span className="mono" style={{ marginLeft: 'auto', fontSize: 11, color: 'var(--text-3)' }}>{['4 cuts', '3 moves', 'teal/orange', '96 bpm'][i]}</span>}
            </div>
          ))}
        </div>

        <AnimatePresence>
          {ready && (
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
              <div style={{ marginTop: 18, display: 'grid', gap: 10 }}>
                {SHOTS.map((s, i) => (
                  <motion.div key={s.n} className="card row" style={{ padding: 10, gap: 12, position: 'relative', overflow: 'hidden' }} {...stagger(i)}>
                    <i style={{ position: 'absolute', left: 0, top: 12, bottom: 12, width: 3, borderRadius: 2, background: s.color }} />
                    <Crop pos={s.pos} w={58} h={74} />
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div className="row" style={{ gap: 8 }}><span className="mono" style={{ fontSize: 11, color: s.color }}>0{s.n}</span><span style={{ fontWeight: 600 }}>{s.name}</span></div>
                      <div style={{ fontSize: 12.5, color: 'var(--text-3)', marginTop: 3 }}>{s.framing}</div>
                      <div className="row" style={{ gap: 6, marginTop: 7, fontSize: 12, color: 'var(--p-teal-300)' }}><MoveIcon m={s.move} /> {moveLabel[s.move]}</div>
                    </div>
                    <span className="mono" style={{ fontSize: 13, color: 'var(--text-2)', alignSelf: 'flex-start' }}>{s.dur.toFixed(1)}s</span>
                  </motion.div>
                ))}
              </div>
              <motion.div className="card" style={{ padding: 14, marginTop: 10 }} {...stagger(4)}>
                <div className="row between" style={{ marginBottom: 10 }}><span style={{ fontSize: 12.5, color: 'var(--text-3)' }}>Beat map</span><span className="mono" style={{ fontSize: 11, color: 'var(--action)' }}>● cuts land on beats</span></div>
                <div className="wave">{WAVE.map((w, i) => <i key={i} className={w.beat ? 'beat' : ''} style={{ height: `${w.h * 100}%` }} />)}</div>
              </motion.div>
              <motion.p className="row" style={{ gap: 8, fontSize: 12.5, color: 'var(--text-3)', margin: '14px 2px 0' }} {...stagger(5)}>
                <Info size={16} weight="duotone" /> Detected automatically — tap any shot to adjust it.
              </motion.p>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
      <AnimatePresence>
        {ready && (
          <motion.div initial={{ y: 120 }} animate={{ y: 0 }} transition={spring} style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: '30px 20px', background: 'linear-gradient(180deg, transparent, var(--bg) 40%)' }}>
            <Primary full onClick={() => go('camera')}>Shoot shot 1</Primary>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

/* ───────────── 05 Camera (recreate mode) ───────────── */
export function CameraScreen({ go, pad, setPad, done, setDone }: Ctx) {
  const [ghost, setGhost] = useState(true)
  const [mode, setMode] = useState('Recreate')
  const [rec, setRec] = useState(false)
  const [t, setT] = useState(0)
  const [lookOpen, setLookOpen] = useState(false)
  const [toast, setToast] = useState<string | null>(null)
  const vf = useRef<HTMLDivElement>(null)
  const shot = SHOTS[Math.min(done, 3)]
  const all = done >= SHOTS.length
  const match = [0.86, 0.79, 0.91, 0.88][Math.min(done, 3)]

  useEffect(() => {
    if (!rec) return
    const start = performance.now()
    let raf = 0
    const tick = () => {
      const el = (performance.now() - start) / 1000
      setT(el)
      if (el >= shot.dur * 0.6) { // demo runs at 0.6× real time
        setRec(false); setT(0)
        window.Pow.transition(vf.current, 'filmExposure', { duration: 900 })
        window.Pow.haptic('impact')
        const n = done + 1
        setDone(n)
        setToast(n >= SHOTS.length ? 'All 4 shots captured' : `Shot ${shot.n} captured · ${Math.round(match * 100)}% match`)
        setTimeout(() => setToast(null), 1800)
        return
      }
      raf = requestAnimationFrame(tick)
    }
    raf = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(raf)
  }, [rec])

  return (
    <div className="page" style={{ background: '#000', overflow: 'hidden' }}>
      <div ref={vf} className="vf" style={{ filter: padFilter(pad[0], pad[1]) }}>
        <img src={IMG.recreated} alt="Live viewfinder" />
      </div>
      {ghost && mode === 'Recreate' && !all && (
        <motion.img src={IMG.street} alt="" className="ghost media-img" initial={{ opacity: 0 }} animate={{ opacity: .34 }} style={{ position: 'absolute', inset: 0, objectPosition: shot.pos }} />
      )}
      <div className="thirds" />
      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(0,0,0,.45), transparent 22%, transparent 62%, rgba(0,0,0,.75))', pointerEvents: 'none' }} />

      {/* top */}
      <div className="row between" style={{ position: 'absolute', top: 56, left: 16, right: 16, gap: 10 }}>
        <button className="icon-btn" aria-label="Close camera" onClick={() => go('home')}><X size={20} weight="bold" /></button>
        <AnimatePresence mode="wait">
          {rec ? (
            <motion.div key="rec" className="chip" style={{ background: 'var(--rec)', color: '#fff', height: 34, fontSize: 14 }} initial={{ scale: .8, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ opacity: 0 }}>
              <i className="pulse" style={{ width: 8, height: 8, borderRadius: 4, background: '#fff' }} /><span className="mono">00:{t.toFixed(1).padStart(4, '0')}</span>
            </motion.div>
          ) : (
            <motion.div key="shot" className="glass" style={{ flex: 1, borderRadius: 18, padding: '8px 12px' }} initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
              <div className="row between" style={{ fontSize: 12.5, color: 'var(--on-media)', marginBottom: 6 }}>
                <span style={{ fontWeight: 600 }}>{all ? 'All shots done' : `Shot ${shot.n} of 4 · ${shot.name}`}</span>
                {!all && <span className="row mono" style={{ gap: 4, fontSize: 11 }}><MoveIcon m={shot.move} size={14} />{shot.dur}s</span>}
              </div>
              <Segs done={done} h={4} />
            </motion.div>
          )}
        </AnimatePresence>
        <button className="icon-btn" aria-label="Ghost overlay" aria-pressed={ghost} onClick={() => setGhost(g => !g)}
          style={ghost ? { background: 'var(--select)', color: 'var(--select-ink)', borderColor: 'transparent' } : undefined}><Ghost size={22} weight="duotone" /></button>
      </div>

      {/* coaching */}
      {mode === 'Recreate' && !all && !lookOpen && (
        <div style={{ position: 'absolute', top: 132, left: 16, display: 'grid', gap: 8, justifyItems: 'start' }}>
          <div className="glass row" style={{ borderRadius: 18, padding: '7px 12px 7px 7px', gap: 9 }}>
            <Ring v={match} size={40} stroke={4}><span className="mono" style={{ fontSize: 10.5, color: 'var(--on-media)' }}>{Math.round(match * 100)}</span></Ring>
            <div><div style={{ fontSize: 11, color: 'rgba(255,247,236,.7)' }}>Match</div><div style={{ fontSize: 13, fontWeight: 600, color: 'var(--on-media)' }}>Framing on</div></div>
          </div>
          <div className="chip" style={{ background: 'rgba(255,198,94,.92)', color: '#2a1a02', height: 32 }}><ArrowDown size={15} weight="bold" /> {shot.tip.split(',')[0]}</div>
        </div>
      )}

      <AnimatePresence>
        {toast && (
          <motion.div className="glass chip" style={{ position: 'absolute', top: '42%', left: '50%', x: '-50%', height: 40, fontSize: 14, color: 'var(--on-media)', padding: '0 16px' }}
            initial={{ opacity: 0, y: 12, scale: .9 }} animate={{ opacity: 1, y: 0, scale: 1 }} exit={{ opacity: 0, y: -10 }} transition={spring}>
            <CheckCircle size={20} weight="fill" color="var(--select)" /> {toast}
          </motion.div>
        )}
      </AnimatePresence>

      {/* look sheet */}
      <AnimatePresence>
        {lookOpen && (
          <motion.div className="glass" style={{ position: 'absolute', left: 12, right: 12, bottom: 238, borderRadius: 28, padding: 14 }}
            initial={{ y: 40, opacity: 0, scale: .96 }} animate={{ y: 0, opacity: 1, scale: 1 }} exit={{ y: 30, opacity: 0 }} transition={spring}>
            <div className="row between" style={{ marginBottom: 10, color: 'var(--on-media)' }}>
              <span style={{ fontWeight: 600 }}>Look</span>
              <button className="row" style={{ gap: 5, fontSize: 12.5, color: 'var(--p-teal-300)' }} onClick={() => setPad([.5, .5])}><ArrowCounterClockwise size={14} /> Reset</button>
            </div>
            <LookPad x={pad[0]} y={pad[1]} onChange={(x, y) => setPad([x, y])} />
          </motion.div>
        )}
      </AnimatePresence>

      {/* bottom controls */}
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 34 }}>
        {all ? (
          <div style={{ padding: '0 20px' }}><Primary full onClick={() => go('compare')} icon={<Sparkle size={20} weight="fill" />}>See how close you got</Primary></div>
        ) : (
          <>
            <div className="modes" role="group" aria-label="Mode" style={{ marginBottom: 18 }}>
              {MODES.slice(0, 4).map(m => (
                <button key={m.id} className="mode" aria-pressed={mode === m.id} onClick={() => setMode(m.id)}>
                  {mode === m.id && <motion.span layoutId="modepill" className="pill" transition={spring} />}{m.id}
                </button>
              ))}
            </div>
            <div className="row" style={{ justifyContent: 'space-around', padding: '0 18px' }}>
              <button aria-label="Last capture" onClick={() => go('library')} style={{ width: 50, height: 50, borderRadius: 14, overflow: 'hidden', border: '2px solid rgba(255,247,236,.85)' }}><img src={IMG.stilllife} alt="" className="media-img" /></button>
              <Shutter recording={rec} onTap={() => setRec(r => !r)} onMode={setMode} />
              <div className="row" style={{ gap: 8 }}>
                <button className="icon-btn" aria-label="Look" aria-pressed={lookOpen} onClick={() => setLookOpen(o => !o)} style={lookOpen ? { background: 'var(--action)', color: 'var(--action-ink)' } : undefined}><Faders size={21} weight="duotone" /></button>
                <button className="icon-btn" aria-label="Flip camera"><CameraRotate size={21} weight="duotone" /></button>
              </div>
            </div>
            <div style={{ textAlign: 'center', fontSize: 11.5, color: 'rgba(255,247,236,.6)', marginTop: 12 }}>Tap to record · hold for modes</div>
          </>
        )}
      </div>
    </div>
  )
}

/* ───────────── 06 Compare ───────────── */
export function CompareScreen({ go, setDone }: Ctx) {
  return (
    <div className="page">
      <div className="pad" style={{ paddingBottom: 40 }}>
        <div className="row between">
          <div className="row" style={{ gap: 12 }}>
            <Back onClick={() => go('camera')} />
            <div><div className="label">Neon Walk · take 2</div><div className="h-m" style={{ marginTop: 3 }}>How close you got</div></div>
          </div>
        </div>
        <motion.div className="bezel" style={{ marginTop: 18, position: 'relative' }} initial={{ opacity: 0, scale: .96 }} animate={{ opacity: 1, scale: 1 }} transition={soft}>
          <div className="core"><Compare a={IMG.street} b={IMG.recreated} h={390} /></div>
          <VortexCanvas preset="spark" opts={{ ramp: ['#FFF7EC', '#FF9450', '#FF945000'], position: [.5, .35] }} style={{ borderRadius: 30 }} />
        </motion.div>

        <motion.div className="card" style={{ padding: 16, marginTop: 14 }} {...stagger(1)}>
          <div className="row" style={{ gap: 14 }}>
            <Ring v={.86} size={64} stroke={6} color="var(--action)"><span className="display" style={{ fontWeight: 700, fontSize: 19 }}>86</span></Ring>
            <div><div style={{ fontWeight: 600, fontSize: 16 }}>Really close.</div><div style={{ fontSize: 13, color: 'var(--text-3)', marginTop: 2 }}>Better than 72% of recreations this week</div></div>
          </div>
          <div style={{ display: 'grid', gap: 11, marginTop: 16 }}>
            {SCORES.map((s, i) => (
              <div key={s.k}>
                <div className="row between" style={{ fontSize: 13, marginBottom: 5 }}><span style={{ color: 'var(--text-2)' }}>{s.k}</span><span className="mono" style={{ fontSize: 12 }}>{s.v}</span></div>
                <div className="bar"><motion.i initial={{ width: 0 }} animate={{ width: s.v + '%' }} transition={{ duration: 1, delay: .2 + i * .08, ease: [.16, 1, .3, 1] }} style={s.v < 80 ? { background: 'linear-gradient(90deg, var(--p-orange-700), var(--p-amber-400))' } : undefined} /></div>
              </div>
            ))}
          </div>
        </motion.div>

        <motion.div className="card" style={{ padding: 14, marginTop: 10, borderColor: 'rgba(255,122,47,.3)', background: 'linear-gradient(180deg, rgba(255,122,47,.08), var(--surface))' }} {...stagger(2)}>
          <div className="row" style={{ gap: 10, alignItems: 'flex-start' }}>
            <MagicWand size={22} weight="duotone" color="var(--action)" style={{ flex: 'none', marginTop: 1 }} />
            <div style={{ fontSize: 14, lineHeight: 1.45 }}>Shot 3 starts <b>half a beat early</b>. I can nudge it in the edit, or you can retake just that shot.</div>
          </div>
          <div className="row" style={{ gap: 8, marginTop: 12 }}>
            <button className="btn btn-ghost" style={{ height: 44, fontSize: 14, flex: 1 }} onClick={() => { setDone(2); go('camera') }}>Retake shot 3</button>
            <button className="btn btn-teal" style={{ height: 44, fontSize: 14, flex: 1 }} onClick={() => go('editor')}>Fix in edit</button>
          </div>
        </motion.div>
      </div>
    </div>
  )
}

/* ───────────── 07 Editor ───────────── */
export function Editor({ go, look, setLook, pad, setPad }: Ctx) {
  const [tool, setTool] = useState('Looks')
  const [ph, setPh] = useState(0.34)
  const [playing, setPlaying] = useState(false)
  const tl = useRef<HTMLDivElement>(null)
  const total = SHOTS.reduce((a, s) => a + s.dur, 0)
  useEffect(() => {
    if (!playing) return
    let raf = 0, last = performance.now()
    const f = (n: number) => { setPh(p => { const v = p + (n - last) / 1000 / total; return v >= 1 ? 0 : v }); last = n; raf = requestAnimationFrame(f) }
    raf = requestAnimationFrame(f)
    return () => cancelAnimationFrame(raf)
  }, [playing])
  let acc = 0
  const cur = SHOTS.findIndex(s => { acc += s.dur; return ph * total < acc })
  const fmt = (s: number) => `00:${s.toFixed(2).padStart(5, '0')}`
  const filter = tool === 'Adjust' ? padFilter(pad[0], pad[1]) : lookFilter(look)
  const tools = [{ k: 'Split', I: Scissors }, { k: 'Looks', I: Swatches }, { k: 'Adjust', I: Palette }, { k: 'Text', I: TextT }, { k: 'Audio', I: MusicNotes }, { k: 'Beat sync', I: MagicWand }]
  return (
    <div className="page" style={{ overflow: 'hidden' }}>
      <div className="row between" style={{ padding: '58px 16px 0' }}>
        <Back onClick={() => go('home')} />
        <div style={{ textAlign: 'center' }}><div style={{ fontWeight: 600 }}>Neon Walk</div><div className="mono" style={{ fontSize: 11, color: 'var(--text-3)' }}>4 clips · {total.toFixed(1)}s</div></div>
        <button className="btn btn-primary" style={{ height: 40, padding: '0 16px', fontSize: 14 }} onClick={() => go('export')}><DownloadSimple size={17} weight="bold" /> Export</button>
      </div>

      <div style={{ position: 'relative', margin: '14px 16px 0', height: 296, borderRadius: 24, overflow: 'hidden' }}>
        <motion.img key={cur} src={IMG.recreated} alt="Preview" className="media-img" style={{ objectPosition: SHOTS[Math.max(cur, 0)].pos, filter }}
          initial={{ scale: 1.06, opacity: .6 }} animate={{ scale: 1, opacity: 1 }} transition={{ duration: .5 }} />
        <span className="chip media" style={{ position: 'absolute', left: 10, top: 10 }}>{LOOKS.find(l => l.id === look)?.name}</span>
        <div style={{ position: 'absolute', left: 0, right: 0, bottom: 18, textAlign: 'center', font: '800 22px var(--f-display)', letterSpacing: '.02em', color: 'var(--on-media)', textShadow: '0 2px 12px rgba(0,0,0,.5)' }}>{ph > 0.15 && ph < 0.6 ? 'NEON WALK' : ''}</div>
      </div>

      <div className="row between" style={{ padding: '12px 20px 0' }}>
        <span className="mono" style={{ fontSize: 12 }}><span style={{ color: 'var(--text)' }}>{fmt(ph * total)}</span><span style={{ color: 'var(--text-3)' }}> / {fmt(total)}</span></span>
        <div className="row" style={{ gap: 6 }}>
          <button className="icon-btn flat" style={{ width: 38, height: 38 }} aria-label="Back to start" onClick={() => setPh(0)}><SkipBack size={17} weight="fill" /></button>
          <button className="icon-btn" style={{ width: 44, height: 44, background: 'var(--text)', color: 'var(--bg)' }} aria-label={playing ? 'Pause' : 'Play'} onClick={() => setPlaying(p => !p)}>{playing ? <Pause size={19} weight="fill" /> : <Play size={19} weight="fill" />}</button>
          <button className="icon-btn flat" style={{ width: 38, height: 38 }} aria-label="Next clip" onClick={() => setPh(p => Math.min(.99, p + .25))}><SkipForward size={17} weight="fill" /></button>
        </div>
      </div>

      {/* timeline */}
      <div ref={tl} className="tl" style={{ margin: '0 16px' }} onPointerDown={e => { const r = tl.current!.getBoundingClientRect(); setPh(Math.min(.999, Math.max(0, (e.clientX - r.left) / r.width))) }}
        onPointerMove={e => { if (e.buttons) { const r = tl.current!.getBoundingClientRect(); setPh(Math.min(.999, Math.max(0, (e.clientX - r.left) / r.width))) } }}>
        <div className="playhead" style={{ left: `${ph * 100}%` }} />
        <div className="track">
          {SHOTS.map((s, i) => (
            <div key={s.n} className={'clip' + (i === cur ? ' on' : '')} style={{ flex: s.dur }}>
              <div style={{ display: 'flex', height: '100%' }}>{[0, 1, 2].map(k => <div key={k} style={{ flex: 1, backgroundImage: `url(${IMG.recreated})`, backgroundSize: '300%', backgroundPosition: s.pos, filter: lookFilter(look) }} />)}</div>
            </div>
          ))}
        </div>
        <div className="wave" style={{ height: 28, marginTop: 6 }}>{WAVE.map((w, i) => <i key={i} className={w.beat ? 'beat' : ''} style={{ height: `${w.h * 100}%` }} />)}</div>
        <div style={{ position: 'relative', height: 22, marginTop: 6 }}>
          <span className="chip" style={{ position: 'absolute', left: '15%', width: '45%', height: 22, fontSize: 10.5, background: 'rgba(255,198,94,.16)', color: 'var(--warn)', borderRadius: 7 }}><TextT size={12} weight="bold" /> NEON WALK</span>
        </div>
      </div>

      {/* tools */}
      <div className="rail" style={{ margin: '8px 0 0', padding: '0 16px', gap: 6 }}>
        {tools.map(t => (
          <button key={t.k} className="tool" aria-pressed={tool === t.k} onClick={() => setTool(t.k)}>
            <span className="ic"><t.I size={23} weight="duotone" color={tool === t.k ? 'var(--action)' : t.k === 'Beat sync' ? 'var(--p-orange-300)' : 'var(--p-teal-300)'} /></span>{t.k}
          </button>
        ))}
      </div>

      <div style={{ padding: '14px 16px 0' }}>
        <AnimatePresence mode="wait">
          {tool === 'Adjust' ? (
            <motion.div key="adj" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} style={{ height: 120 }}>
              <div style={{ height: 120 }}><LookPad x={pad[0]} y={pad[1]} onChange={(x, y) => setPad([x, y])} /></div>
            </motion.div>
          ) : (
            <motion.div key="looks" className="rail" style={{ margin: 0, padding: '4px 4px' }} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}>
              {LOOKS.map(l => (
                <button key={l.id} className="look" aria-pressed={look === l.id} onClick={() => { setLook(l.id); window.Pow.haptic('selection') }}>
                  <span className="sw"><img src={IMG.recreated} alt="" className="media-img" style={{ filter: l.filter, objectPosition: '50% 25%' }} /></span>
                  {look === l.id && <motion.span layoutId="looksel" className="sel" style={{ height: 100 }} transition={spring} />}
                  {l.name}
                </button>
              ))}
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  )
}

/* ───────────── 08 Export ───────────── */
export function Export({ go, look }: Ctx) {
  const [res, setRes] = useState('4K')
  const [fps, setFps] = useState('30')
  const [p, setP] = useState<number | null>(null)
  const frame = useRef<HTMLDivElement>(null)
  useEffect(() => { window.Pow.transition(frame.current, 'snapshot', { duration: 1100 }) }, [])
  useEffect(() => {
    if (p == null || p >= 1) return
    const t = setTimeout(() => setP(v => Math.min(1, (v ?? 0) + 0.07)), 90)
    return () => clearTimeout(t)
  }, [p])
  const doneNow = p != null && p >= 1
  const Seg = ({ v, set, opts, id }: { v: string; set: (s: string) => void; opts: string[]; id: string }) => (
    <div className="seg">{opts.map(o => <button key={o} aria-pressed={v === o} onClick={() => set(o)}>{v === o && <motion.span layoutId={id} className="on" transition={spring} />}<span>{o}</span></button>)}</div>
  )
  return (
    <div className="page">
      <div className="pad" style={{ paddingBottom: 40 }}>
        <div className="row" style={{ gap: 12 }}>
          <Back onClick={() => go('editor')} />
          <div><div className="label">Neon Walk</div><div className="h-m" style={{ marginTop: 3 }}>{doneNow ? 'Saved.' : 'Export'}</div></div>
        </div>
        <div style={{ position: 'relative', margin: '18px auto 0', width: 220 }}>
          <div ref={frame} className="bezel"><div className="core" style={{ height: 300 }}>
            <img src={IMG.recreated} alt="Final frame" className="media-img" style={{ filter: lookFilter(look) }} />
            {p != null && !doneNow && <div style={{ position: 'absolute', inset: 0, background: 'rgba(5,14,16,.55)', display: 'grid', placeItems: 'center' }}>
              <Ring v={p} size={86} stroke={6} color="var(--action)"><span className="mono" style={{ fontSize: 16, color: 'var(--on-media)' }}>{Math.round(p * 100)}%</span></Ring></div>}
          </div></div>
          {doneNow && <VortexCanvas preset="confetti" burstEvery={2600} opts={{ palette: ['#FF7A2F', '#FFB27A', '#4FE0D0', '#2BC6B5', '#FFC65E', '#FBF3E8'], position: [.5, .1] }} style={{ inset: '-80px -80px -40px', width: 'calc(100% + 160px)', height: 'calc(100% + 120px)' }} />}
        </div>

        {!doneNow ? (
            <div key="opts">
              <div className="label" style={{ margin: '22px 0 8px' }}>Resolution</div>
              <Seg v={res} set={setRes} opts={['1080p', '4K']} id="segres" />
              <div className="label" style={{ margin: '16px 0 8px' }}>Frame rate</div>
              <Seg v={fps} set={setFps} opts={['24', '30', '60']} id="segfps" />
              <div className="card row" style={{ padding: '12px 14px', marginTop: 16, gap: 10, fontSize: 13, color: 'var(--text-2)' }}>
                <Clock size={18} weight="duotone" color="var(--p-teal-300)" /> About {res === '4K' ? '38' : '14'} MB · renders on this iPhone
              </div>
              <div style={{ marginTop: 18 }}>
                <Primary full onClick={() => setP(0)} icon={p != null ? <CircleNotch size={20} weight="bold" className="spin" /> : <DownloadSimple size={20} weight="bold" />}>{p != null ? 'Rendering 4 clips…' : 'Save to Photos'}</Primary>
              </div>
            </div>
          ) : (
            <motion.div key="done" initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={soft}>
              <div className="row" style={{ gap: 8, justifyContent: 'center', margin: '22px 0 18px', fontSize: 14, color: 'var(--text-2)' }}><CheckCircle size={20} weight="fill" color="var(--select)" /> {res} · {fps} fps · in your Photos</div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10 }}>
                {[{ I: TiktokLogo, k: 'TikTok' }, { I: InstagramLogo, k: 'Reels' }, { I: YoutubeLogo, k: 'Shorts' }, { I: Copy, k: 'Copy link' }].map(s => (
                  <button key={s.k} className="tool" style={{ minWidth: 0 }}><span className="ic" style={{ width: '100%', height: 58 }}><s.I size={26} weight="duotone" color="var(--text)" /></span>{s.k}</button>
                ))}
              </div>
              <button className="btn btn-ghost" style={{ width: '100%', marginTop: 16 }} onClick={() => go('home')}><Plus size={18} weight="bold" /> Recreate another</button>
            </motion.div>
          )}
      </div>
    </div>
  )
}

/* ───────────── 09 Library ───────────── */
export function Library({ go }: Ctx) {
  const [f, setF] = useState('All')
  const items = LIBRARY.filter(x => f === 'All' || (f === 'Photos' ? x.d === 'Photo' : x.d !== 'Photo'))
  return (
    <div className="page">
      <div className="pad">
        <div className="row between"><h1 className="h-l">Library</h1><span className="mono" style={{ fontSize: 12, color: 'var(--text-3)' }}>{LIBRARY.length} items</span></div>
        <div className="seg" style={{ margin: '16px 0' }}>
          {['All', 'Videos', 'Photos'].map(o => <button key={o} aria-pressed={f === o} onClick={() => setF(o)}>{f === o && <motion.span layoutId="libseg" className="on" transition={spring} />}<span>{o}</span></button>)}
        </div>
        <motion.div layout style={{ columns: 2, columnGap: 10 }}>
          <AnimatePresence>
            {items.map((x, i) => (
              <motion.button layout key={x.t} initial={{ opacity: 0, scale: .9 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: .9 }} transition={soft}
                onClick={() => go(x.d === 'Photo' ? 'editor' : 'compare')} style={{ display: 'block', width: '100%', marginBottom: 10, breakInside: 'avoid', textAlign: 'left' }}>
                <div style={{ position: 'relative', height: [210, 160, 180, 230][i % 4], borderRadius: 18, overflow: 'hidden' }}>
                  <img src={x.img} alt="" className="media-img" />
                  <span className="chip media" style={{ position: 'absolute', right: 8, bottom: 8, height: 24, fontSize: 11 }}>{x.d === 'Photo' ? <Sun size={12} weight="fill" /> : <Play size={11} weight="fill" />} {x.d}</span>
                </div>
                <div style={{ fontSize: 12.5, color: 'var(--text-2)', marginTop: 6 }}>{x.t}</div>
              </motion.button>
            ))}
          </AnimatePresence>
        </motion.div>
      </div>
    </div>
  )
}

/* ───────────── 10 You ───────────── */
export function Profile({ go }: Ctx) {
  const [haptics, setHaptics] = useState(true)
  const [grain, setGrain] = useState(true)
  const Toggle = ({ on, set, label }: { on: boolean; set: (b: boolean) => void; label: string }) => (
    <button role="switch" aria-checked={on} aria-label={label} onClick={() => set(!on)} style={{ width: 52, height: 32, borderRadius: 16, padding: 3, background: on ? 'var(--select)' : 'var(--surface-3)', transition: 'background .2s' }}>
      <motion.span layout transition={spring} style={{ display: 'block', width: 26, height: 26, borderRadius: 13, background: 'var(--on-media)', marginLeft: on ? 20 : 0 }} />
    </button>
  )
  return (
    <div className="page">
      <div className="pad">
        <div className="row" style={{ gap: 14 }}>
          <img src={IMG.portrait} alt="" style={{ width: 64, height: 64, borderRadius: 32, objectFit: 'cover', boxShadow: '0 0 0 3px var(--bg), 0 0 0 5px var(--action)' }} />
          <div><h1 className="h-m">Your studio</h1><div style={{ fontSize: 13, color: 'var(--text-3)', marginTop: 3 }}>Shooting since March</div></div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8, marginTop: 20 }}>
          {[{ v: '24', k: 'Recreations', c: 'var(--action)' }, { v: '84%', k: 'Avg match', c: 'var(--select)' }, { v: '6', k: 'Day streak', c: 'var(--warn)' }].map(s => (
            <div key={s.k} className="card" style={{ padding: '14px 12px' }}><div className="display" style={{ fontSize: 26, fontWeight: 700, color: s.c }}>{s.v}</div><div style={{ fontSize: 12, color: 'var(--text-3)' }}>{s.k}</div></div>
          ))}
        </div>
        <div style={{ marginTop: 14, borderRadius: 24, padding: 18, background: 'linear-gradient(135deg, #FF7A2F, #C8501A 55%, #12786E)', color: 'var(--on-media)', position: 'relative', overflow: 'hidden' }}>
          <Crown size={26} weight="duotone" />
          <div className="h-m" style={{ marginTop: 10 }}>MOVA Pro</div>
          <div style={{ fontSize: 13.5, opacity: .9, marginTop: 4, maxWidth: 230 }}>Unlimited recreations, 4K export and every look.</div>
          <button className="btn" style={{ height: 40, marginTop: 14, padding: '0 16px', fontSize: 14, background: 'var(--on-media)', color: 'var(--action-ink)' }}>Try 7 days free <ArrowUpRight size={16} weight="bold" /></button>
        </div>
        <div className="card" style={{ marginTop: 14, padding: '4px 14px' }}>
          {[
            { I: Vibrate, k: 'Haptics', r: <Toggle on={haptics} set={setHaptics} label="Haptics" /> },
            { I: FilmStrip, k: 'Film grain in previews', r: <Toggle on={grain} set={setGrain} label="Film grain" /> },
            { I: Lightning, k: 'Capture quality', r: <span style={{ fontSize: 13, color: 'var(--text-3)' }}>HEVC · 4K</span> },
            { I: HardDrives, k: 'Storage', r: <span style={{ fontSize: 13, color: 'var(--text-3)' }}>2.3 GB</span> },
          ].map((s, i) => (
            <div key={s.k} className="row" style={{ gap: 12, height: 56, borderBottom: i < 3 ? '1px solid var(--line)' : 0 }}>
              <s.I size={22} weight="duotone" color="var(--p-teal-300)" /><span style={{ flex: 1, fontSize: 14.5 }}>{s.k}</span>{s.r}
            </div>
          ))}
        </div>
        <button onClick={() => go('welcome')} style={{ margin: '18px auto 0', display: 'block', fontSize: 13, color: 'var(--text-3)' }}>Replay onboarding</button>
      </div>
    </div>
  )
}

export { TabBar }
