import { useEffect, useState } from 'react'
import { motion, AnimatePresence, LayoutGroup, MotionConfig } from 'framer-motion'
import { CheckCircle } from '@phosphor-icons/react'
import { Welcome, Home, Reference, Analyze, CameraScreen, CompareScreen, Editor, Export, Library, Profile, TabBar, type Ctx } from './screens'
import { spring } from './ui'

type Note = { id: string; label: string; title: string; body: string; points: string[]; srcs: [string, boolean?][] }
const NOTES: Note[] = [
  { id: 'welcome', label: 'Welcome', title: 'Lead with the signature move', body: 'The first screen sells reference recreation, not a feature list. A real graded frame, a live shot-breakdown card, and one orange action.',
    points: ['Fireflies particles in tungsten orange (Vortex preset, recoloured)', 'Shot card is glass over media: blur, saturation and a specular edge', 'Button-in-button CTA with a spring nub'],
    srcs: [['twostraws/Vortex'], ['high-end-visual-design', true], ['imagegen-frontend-mobile', true]] },
  { id: 'home', label: 'Studio', title: 'Color lives in the content', body: 'Deep teal-black surfaces let the footage carry the color. Orange means "do it / AI". Teal means "selected / data". Nothing else gets a hue.',
    points: ['Hero card shares a layoutId with the Reference screen. Tap it and the image morphs.', 'Tab bar selection is a morphing glass blob', 'Difficulty and progress shown as data in teal'],
    srcs: [['framer-motion layoutId'], ['VSCO / TikTok refs from awesome-ios-design-md'], ['design-taste-frontend', true]] },
  { id: 'reference', label: 'Reference', title: 'Show what the AI actually sees', body: 'Before asking for anything, MOVA shows its reading of the clip: cuts, camera move, beat and grade. Each is typed and iconed so it scans in one glance.',
    points: ['Phosphor duotone icons, each tinted with its own data color', 'Extracted palette shown as swatches', 'Sticky primary action over a fade'],
    srcs: [['Phosphor duotone'], ['theme-factory (custom theme)', true]] },
  { id: 'analyze', label: 'Breakdown', title: 'Honest progress, then a shot list', body: 'Four real steps tick off one by one, each with what it found. The result is a shot list you can edit, plus a beat map showing where the cuts land.',
    points: ['Each shot is cropped from the reference frame and color-keyed', 'Move type is drawn as an icon: dolly, tilt, pan or locked off', '"Detected automatically. Tap to adjust" keeps it honest'],
    srcs: [['SwiftUI-Design-System-Pro motion tokens'], ['design-taste-frontend states', true]] },
  { id: 'camera', label: 'Camera', title: 'A coach inside the viewfinder', body: 'A teal ghost of the reference sits over the live view. A match ring and one amber tip tell you what to fix. Tap records the current shot; hold the shutter for the radial mode menu.',
    points: ['Radial menu: same atan2 segments and 0.3·(1−e^(−d/50)) expansion as the SwiftUI experiment', 'Look pad: 2D warm↔cool × soft↔punchy with detent haptics', 'Pow film-exposure flash on each captured shot'],
    srcs: [['mikelikesdesign/SwiftUI-experiments'], ['EmergeTools/Pow'], ['swiftui-liquid-glass', true]] },
  { id: 'compare', label: 'Result', title: 'Before / after you can drag', body: 'Drag the divider to compare. The score breaks into framing, move, color and timing, and the lowest one gets one actionable fix.',
    points: ['Spark burst (Vortex) when the result lands', 'Weak scores switch from teal to an orange-amber ramp', 'Two clear paths: retake one shot, or fix it in the edit'],
    srcs: [['twostraws/Vortex'], ['interactions port'], ['high-end-visual-design', true]] },
  { id: 'editor', label: 'Editor', title: 'A real timeline, not a filter app', body: 'Clips are sized by duration, beats are orange ticks under the audio, and text sits on its own lane. Looks preview on your own footage.',
    points: ['Draggable playhead; preview follows the active clip', 'Look selection ring morphs between swatches (layoutId)', 'Adjust swaps in the same 2D look pad as the camera'],
    srcs: [['framer-motion'], ['Phosphor duotone'], ['web-artifacts-builder', true]] },
  { id: 'export', label: 'Export', title: 'Finish with a moment', body: 'The final frame develops in with Pow\'s Snapshot transition. Rendering shows real progress on the frame itself; when it\'s done, confetti in the MOVA palette.',
    points: ['Segmented controls with sliding selection', 'Honest size estimate and on-device note', 'Share targets as one quiet row'],
    srcs: [['EmergeTools/Pow'], ['twostraws/Vortex']] },
  { id: 'library', label: 'Library', title: 'Masonry that reflows', body: 'Filtering animates items in and out with layout springs instead of cutting.', points: ['Video and photo badges on glass', 'Tap a video to open its comparison'], srcs: [['framer-motion layout']] },
  { id: 'profile', label: 'You', title: 'Settings with personality', body: 'Stats use the three data colors. Pro gets the only gradient in the app: orange into teal, the brand in one swatch.', points: ['Spring-loaded switches', 'Haptics and grain are user choices'], srcs: [['brand-guidelines (structure)', true]] },
]
const TABS = ['home', 'library', 'profile']

export default function App() {
  const [screen, setScreen] = useState(() => (location.hash.slice(1) || 'welcome'))
  const [look, setLook] = useState('tungsten')
  const [pad, setPad] = useState<[number, number]>([0.35, 0.4])
  const [done, setDone] = useState(0)
  const [scale, setScale] = useState(1)
  useEffect(() => {
    const f = () => setScale(Math.min(1, (window.innerWidth - 32) / 402, window.innerWidth > 1180 ? (window.innerHeight - 40) / 856 : 1))
    f(); addEventListener('resize', f); return () => removeEventListener('resize', f)
  }, [])
  const go = (s: string) => { if (s === 'camera' && done >= 4) setDone(0); setScreen(s); try { history.replaceState(null, '', '#' + s) } catch { /* sandboxed */ } }
  const ctx: Ctx = { go, look, setLook, pad, setPad, done, setDone }
  const note = NOTES.find(n => n.id === screen) ?? NOTES[0]
  const S = { welcome: Welcome, home: Home, reference: Reference, analyze: Analyze, camera: CameraScreen, compare: CompareScreen, editor: Editor, export: Export, library: Library, profile: Profile }[screen] ?? Welcome

  return (
    <MotionConfig reducedMotion="user">
      <main className="stage">
        <aside className="side">
          <div className="brandmark"><i />MOVA</div>
          <h1>v4 · <em>Teal &amp; Tungsten</em></h1>
          <p>A cinema grade for the whole product: teal-black surfaces, tungsten orange for every action, teal for data. Click through the full recreation flow on the phone, or jump to any screen.</p>
          <nav className="nav" aria-label="Screens">
            {NOTES.map((n, i) => (
              <button key={n.id} aria-current={screen === n.id} onClick={() => go(n.id)}>
                {screen === n.id && <motion.span layoutId="navhl" className="hl" transition={spring} />}
                <span className="num">{String(i + 1).padStart(2, '0')}</span>{n.label}
              </button>
            ))}
          </nav>
        </aside>

        <div style={{ width: 402 * scale, height: 856 * scale }}>
          <div className="phone" style={{ transform: `scale(${scale})`, transformOrigin: 'top left' }}>
            <div className="screen">
              <div className="island" />
              <LayoutGroup>
                <AnimatePresence initial={false}>
                  <motion.div key={screen} style={{ position: 'absolute', inset: 0 }}
                    initial={{ opacity: 0, scale: .985 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, transition: { duration: .18 } }} transition={{ duration: .32, ease: [.16, 1, .3, 1] }}>
                    <S {...ctx} />
                  </motion.div>
                </AnimatePresence>
              </LayoutGroup>
              {TABS.includes(screen) && <TabBar tab={screen as any} go={go} />}
            </div>
          </div>
        </div>

        <AnimatePresence mode="wait">
          <motion.section key={note.id} className="notes" initial={{ opacity: 0, x: 12 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -8 }} transition={{ duration: .25 }}>
            <div className="eyebrow">{String(NOTES.indexOf(note) + 1).padStart(2, '0')} · {note.label}</div>
            <h2>{note.title}</h2>
            <p>{note.body}</p>
            <ul>{note.points.map(p => <li key={p}><CheckCircle size={18} weight="duotone" color="var(--p-orange-400)" />{p}</li>)}</ul>
            <div className="label" style={{ marginBottom: 8 }}>Built with</div>
            <div className="srcs">{note.srcs.map(([s, skill]) => <span key={s} className={'src' + (skill ? ' o' : '')}>{s}</span>)}</div>
          </motion.section>
        </AnimatePresence>
      </main>
    </MotionConfig>
  )
}
