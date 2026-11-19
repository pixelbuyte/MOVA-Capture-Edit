import SwiftUI
import MovaCore
import PhosphorSwift

/// A crop of a sample photo: scale it up and pin an anchor, used for per-shot thumbnails.
struct PhotoCrop: View {
    var name: String
    var scale: CGFloat = 1
    var anchor: UnitPoint = .center

    var body: some View {
        GeometryReader { geo in
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(scale, anchor: anchor)
                .clipped()
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

/// Crops for the four sample shots (wide, face, mid, feet), so each shot reads differently.
enum ShotCrop {
    static func scale(_ i: Int) -> CGFloat { [1.0, 2.4, 1.6, 2.2][i % 4] }
    static func anchor(_ i: Int) -> UnitPoint {
        [UnitPoint.center, UnitPoint(x: 0.5, y: 0.18), UnitPoint(x: 0.5, y: 0.45), UnitPoint(x: 0.5, y: 0.9)][i % 4]
    }
}

extension CameraMove {
    var glyph: Ph {
        switch self {
        case .lockedOff: .crosshair
        case .dollyIn: .arrowsIn
        case .dollyOut: .arrowsOut
        case .panLeft, .panRight: .arrowsHorizontal
        case .tiltUp, .tiltDown: .arrowsVertical
        case .handheld: .handGrabbing
        }
    }
}

/// Beat map: waveform bars (lagoon), beats (sun dots) and cuts (coral lines), drawn with Canvas.
struct BeatMapView: View {
    var plan: ShotPlan
    var beat: BeatMap
    var playhead: Double? = nil

    var body: some View {
        Canvas { ctx, size in
            let total = max(plan.totalDuration, 0.001)
            func x(_ t: Double) -> CGFloat { CGFloat(t / total) * size.width }
            // waveform
            let bars = 64
            let barW = size.width / CGFloat(bars)
            for i in 0..<bars {
                let v = 0.25 + 0.75 * abs(sin(Double(i) * 1.7) * cos(Double(i) * 0.37))
                let h = CGFloat(v) * size.height * 0.7
                let r = CGRect(x: CGFloat(i) * barW + 1, y: (size.height - h) / 2, width: max(barW - 2, 1), height: h)
                ctx.fill(Path(roundedRect: r, cornerRadius: 1), with: .color(.lagoon.opacity(0.85)))
            }
            // beats
            for b in beat.beats(upTo: total) {
                ctx.fill(Path(ellipseIn: CGRect(x: x(b) - 2, y: size.height - 5, width: 4, height: 4)), with: .color(.sun))
            }
            // cuts
            for c in plan.cutTimes {
                ctx.fill(Path(CGRect(x: x(c) - 1, y: 0, width: 2, height: size.height - 8)), with: .color(.coral))
            }
            if let p = playhead {
                ctx.fill(Path(CGRect(x: x(p) - 1, y: 0, width: 2, height: size.height)), with: .color(.white))
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Beat map, \(Int(beat.bpm)) BPM. Cuts land on beats.")
    }
}

/// Dashed coral outline of where the subject stood in the reference.
struct ReferenceGhost: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                // head
                p.addEllipse(in: CGRect(x: w * 0.40, y: h * 0.02, width: w * 0.20, height: h * 0.11))
                // body: shoulders → hips → legs, as one rounded outline
                p.addRoundedRect(in: CGRect(x: w * 0.26, y: h * 0.14, width: w * 0.48, height: h * 0.36),
                                 cornerSize: CGSize(width: w * 0.14, height: w * 0.14))
                p.addRoundedRect(in: CGRect(x: w * 0.30, y: h * 0.48, width: w * 0.17, height: h * 0.50),
                                 cornerSize: CGSize(width: w * 0.07, height: w * 0.07))
                p.addRoundedRect(in: CGRect(x: w * 0.53, y: h * 0.48, width: w * 0.17, height: h * 0.50),
                                 cornerSize: CGSize(width: w * 0.07, height: w * 0.07))
            }
            .stroke(Color.coral, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [9, 7]))
            .shadow(color: .black.opacity(0.35), radius: 2)
        }
        .accessibilityLabel("Reference outline")
    }
}

/// Coral shutter. The ring shows one arc per shot; done shots are coral.
struct ShutterButton: View {
    var fractions: [Double]
    var done: Int
    var isRecording: Bool
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            ZStack {
                ForEach(Array(arcs.enumerated()), id: \.offset) { i, arc in
                    Circle()
                        .trim(from: arc.from, to: arc.to)
                        .stroke(i < done ? Color.coral : Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                RoundedRectangle(cornerRadius: isRecording ? 8 : 31, style: .continuous)
                    .fill(Color.coral)
                    .frame(width: isRecording ? 30 : 62, height: isRecording ? 30 : 62)
                    .animation(Motion.snappy, value: isRecording)
            }
            .frame(width: 80, height: 80)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRecording ? "Stop recording" : "Record shot")
    }

    private var arcs: [(from: CGFloat, to: CGFloat)] {
        let gap = 0.012
        var start = 0.0
        return fractions.map { f in
            defer { start += f }
            return (CGFloat(start + gap), CGFloat(start + f - gap))
        }
    }
}

/// Small coloured badge on media, e.g. the mint match score.
struct ScoreBadge: View {
    var score: Int
    var body: some View {
        HStack(spacing: 4) {
            Icon(.checkCircle, .fill, size: 13, color: .ink)
            Text("\(score)% match").font(.movaMono(12, medium: true))
        }
        .foregroundStyle(Color.ink)
        .padding(.horizontal, 9)
        .frame(height: 24)
        .background(Color.mint, in: Capsule())
        .accessibilityLabel("\(score) percent match")
    }
}

/// A list row with a Phosphor icon, title and trailing content.
struct IconRow<Trailing: View>: View {
    var glyph: Ph
    var title: String
    var tint: Color = .w72
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: Space.s) {
            Icon(glyph, size: 20, color: tint)
                .frame(width: 32, height: 32)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            Text(title).font(.mova(15, .medium)).foregroundStyle(.white)
            Spacer(minLength: Space.xs)
            trailing()
        }
        .frame(minHeight: 50)
    }
}

/// Bottom padding so tab-root screens scroll clear of the tab bar.
extension View {
    func clearsTabBar() -> some View { padding(.bottom, 110) }
}
