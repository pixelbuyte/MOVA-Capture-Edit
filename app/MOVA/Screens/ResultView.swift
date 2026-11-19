import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 06 — your take vs the reference, the score, and one fix.
struct ResultView: View {
    @Environment(AppModel.self) private var model
    @State private var split: CGFloat = 0.5

    /// The cut that is furthest off the reference. Until real take analysis exists, shot 3 is half a beat early
    /// (matches the sample score's weak timing).
    private var fix: CutTiming {
        var take = model.plan
        if take.shots.count >= 3 {
            take.shots[1].duration -= model.beat.interval / 2
            take.shots[2].duration += model.beat.interval / 2
        }
        let timings = model.beat.cutTimings(reference: model.plan, take: take)
        return timings.max { abs($0.beats) < abs($1.beats) } ?? CutTiming(shotNumber: 1, beats: 0)
    }

    var body: some View {
        let score = model.score
        let fix = self.fix
        ScrollView {
            VStack(alignment: .leading, spacing: Space.m) {
                ShotBar(fractions: model.plan.fractions, height: 4,
                        colors: model.plan.shots.map { $0.number == fix.shotNumber ? Color.sun : Color.mint })
                HStack {
                    CircleIconButton(glyph: .x, label: "Close") { model.popToRoot() }
                    Spacer()
                    VStack(spacing: 2) {
                        EyebrowText("All \(model.plan.shots.count) shots")
                        Text("Your take").font(.movaH2).foregroundStyle(.white)
                    }
                    Spacer()
                    CircleIconButton(glyph: .export, label: "Export") { model.open(.export) }
                }

                compare
                    .frame(height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.media, style: .continuous))

                HStack(spacing: Space.m) {
                    MatchRing(value: score.overall, size: 64, lineWidth: 6, showsPercent: false)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            EyebrowText("Match", color: .mint)
                            EyebrowText("· out of 100")
                        }
                        Text(score.headline).font(.movaH1).foregroundStyle(.white)
                    }
                }

                VStack(spacing: Space.s) {
                    ForEach(MatchScore.Dimension.allCases, id: \.self) { d in
                        scoreBar(d.label, score.value(d))
                    }
                }

                coachCard(fix)
            }
            .padding(.horizontal, Space.gutter)
            .padding(.top, Space.xs)
            .padding(.bottom, 60)
        }
        .scrollIndicators(.hidden)
        .background(Color.ink)
    }

    private var compare: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                // Your take (right side): same frame, slightly tighter and cooler until real takes are wired in.
                PhotoCrop(name: "fashion_yellow", scale: 1.07, anchor: UnitPoint(x: 0.52, y: 0.4))
                    .saturation(0.9).hueRotation(.degrees(-6))
                PhotoCrop(name: "fashion_yellow")
                    .mask(alignment: .leading) { Rectangle().frame(width: w * split) }
                Rectangle().fill(.white).frame(width: 2).offset(x: w * split - 1)
                Icon(.arrowsHorizontal, .bold, size: 18, color: .ink)
                    .frame(width: 40, height: 40)
                    .background(.white, in: Circle())
                    .offset(x: w * split - 20)
                    .accessibilityHidden(true)
                VStack {
                    HStack {
                        Chip(text: "Reference", tint: .white, background: .coral)
                        Spacer()
                        Text("Your take").font(.mova(12, .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 10).frame(height: 26).glass(radius: 13)
                    }
                    Spacer()
                }
                .padding(Space.s)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                split = min(max(v.location.x / max(w, 1), 0.05), 0.95)
            })
            .accessibilityElement()
            .accessibilityLabel("Compare reference and your take")
            .accessibilityValue("\(Int(split * 100)) percent reference")
            .accessibilityAdjustableAction { dir in
                switch dir {
                case .increment: split = min(split + 0.1, 0.95)
                case .decrement: split = max(split - 0.1, 0.05)
                @unknown default: break
                }
            }
        }
    }

    private func scoreBar(_ label: String, _ value: Int) -> some View {
        HStack(spacing: Space.s) {
            Text(label).font(.mova(14, .medium)).foregroundStyle(Color.w72)
                .frame(width: 104, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.hair)
                    Capsule().fill(Color.mint).frame(width: geo.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 6)
            Text("\(value)").font(.movaMono(13, medium: true)).foregroundStyle(.white).monospacedDigit()
                .frame(width: 28, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
    }

    private func coachCard(_ fix: CutTiming) -> some View {
        VStack(alignment: .leading, spacing: Space.s) {
            HStack(spacing: 6) {
                Icon(.timer, size: 16, color: .sun)
                EyebrowText("Timing · Shot \(fix.shotNumber)", color: .sun)
            }
            Text(fix.coaching).font(.mova(18, .semibold)).foregroundStyle(.white)
            Text("Boots to face cuts in about \(String(format: "%.1f", abs(fix.beats) * model.beat.interval))s before the beat. Reshoot it, or slide the cut in the editor.")
                .font(.movaCallout).foregroundStyle(Color.w72)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: Space.xs) {
                Button {
                    model.shotsCaptured = max(fix.shotNumber - 1, 0)
                    model.showCamera = true
                } label: {
                    HStack(spacing: 6) { Icon(.arrowCounterClockwise, size: 16); Text("Retake shot \(fix.shotNumber)") }
                }
                .buttonStyle(.movaSecondary)
                Button {
                    model.open(.editor)
                } label: {
                    HStack(spacing: 6) { Icon(.scissors, .bold, size: 16); Text("Fix in edit") }
                }
                .buttonStyle(.movaPrimary)
            }
        }
        .padding(Space.m)
        .background(Color.sun.opacity(0.08), in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radius.card, style: .continuous).strokeBorder(Color.sun.opacity(0.3)))
    }
}

#Preview {
    ResultView().environment(AppModel())
}
