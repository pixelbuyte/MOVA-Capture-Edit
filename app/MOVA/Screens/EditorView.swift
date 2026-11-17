import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 07 — editor. Used as the Edit tab root and when pushed from Result.
struct EditorView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var playhead = 2.6
    @State private var playing = false
    @State private var tool = "Looks"

    private var isPushed: Bool { model.path.last == .editor }
    private struct Tool: Identifiable { let id: String; let glyph: Ph }
    private let tools: [Tool] = [
        Tool(id: "Split", glyph: .scissors), Tool(id: "Looks", glyph: .swatches), Tool(id: "Adjust", glyph: .slidersHorizontal),
        Tool(id: "Text", glyph: .textT), Tool(id: "Audio", glyph: .musicNotes), Tool(id: "Beat sync", glyph: .magicWand),
    ]

    var body: some View {
        let plan = model.plan
        VStack(spacing: Space.s) {
            topBar(plan)
            preview(plan)
            transport(plan)
            timeline(plan)
            toolRow
            looksRail
            Spacer(minLength: 0)
        }
        .padding(.bottom, isPushed ? Space.s : 96)
        .background(Color.ink)
        .task(id: playing) {
            guard playing else { return }
            while playing && !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(40))
                playhead += 0.04
                if playhead >= plan.totalDuration { playhead = 0 }
            }
        }
    }

    private func topBar(_ plan: ShotPlan) -> some View {
        HStack {
            if isPushed {
                CircleIconButton(glyph: .caretLeft, label: "Back") { model.back() }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Seaside recreate").font(.mova(17, .semibold)).foregroundStyle(.white)
                EyebrowText("\(plan.shots.count) clips · \(String(format: "%.1f", plan.totalDuration))s")
            }
            Spacer()
            Button {
                model.open(.export)
            } label: {
                Text("Export").font(.mova(15, .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 16).frame(height: 38)
                    .background(Color.coral, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Space.gutter)
        .padding(.top, Space.xs)
    }

    private func preview(_ plan: ShotPlan) -> some View {
        let i = plan.shotIndex(at: playhead)
        return ZStack(alignment: .topLeading) {
            PhotoCrop(name: "fashion_yellow", scale: ShotCrop.scale(i), anchor: ShotCrop.anchor(i))
                .look(model.look)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: i)
            Chip(text: model.look.name, background: .black.opacity(0.45)).padding(Space.s)
            if playhead > 1 && playhead < 6 {
                Text("Seaside, 6 pm")
                    .font(.mova(22, .bold)).foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, Space.l)
            }
        }
        .frame(width: 236, height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func transport(_ plan: ShotPlan) -> some View {
        HStack {
            Text("\(timecode(playhead)) / \(timecode(plan.totalDuration))")
                .font(.movaMono(13)).foregroundStyle(Color.w72).monospacedDigit()
            Spacer()
            HStack(spacing: Space.l) {
                Button { playhead = 0 } label: { Icon(.skipBack, .fill, size: 20) }
                    .accessibilityLabel("Back to start")
                Button { playing.toggle() } label: {
                    Icon(playing ? .pause : .play, .fill, size: 20, color: .ink)
                        .frame(width: 44, height: 44).background(.white, in: Circle())
                }
                .accessibilityLabel(playing ? "Pause" : "Play")
                Button { playhead = model.beat.snap(playhead + model.beat.interval) } label: { Icon(.skipForward, .fill, size: 20) }
                    .accessibilityLabel("Next beat")
            }
            .buttonStyle(.plain)
            Spacer()
            Icon(.arrowCounterClockwise, size: 20, color: .w52).accessibilityHidden(true)
        }
        .padding(.horizontal, Space.gutter)
    }

    private func timeline(_ plan: ShotPlan) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let total = max(plan.totalDuration, 0.001)
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 3) {
                        ForEach(Array(plan.shots.enumerated()), id: \.element.number) { i, shot in
                            PhotoCrop(name: "fashion_yellow", scale: ShotCrop.scale(i), anchor: ShotCrop.anchor(i))
                                .look(model.look)
                                .frame(width: max((w - 9) * CGFloat(shot.duration / total), 0), height: 46)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay {
                                    if i == plan.shotIndex(at: playhead) {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(.white, lineWidth: 2)
                                    }
                                }
                        }
                    }
                    HStack(spacing: 6) {
                        Icon(.musicNotes, size: 14, color: .lagoon)
                        Text("Low tide").font(.movaMono(11)).foregroundStyle(Color.w52)
                    }
                    BeatMapView(plan: plan, beat: model.beat).frame(height: 30)
                    Text("Seaside, 6 pm")
                        .font(.mova(11, .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 8).frame(height: 22)
                        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
                        .offset(x: w * CGFloat(1 / total))
                }
                Rectangle().fill(Color.coral).frame(width: 2, height: 150)
                    .offset(x: w * CGFloat(playhead / total) - 1, y: -6)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                playing = false
                playhead = min(max(Double(v.location.x / max(w, 1)) * total, 0), total)
            })
            .accessibilityElement()
            .accessibilityLabel("Timeline")
            .accessibilityValue(timecode(playhead))
            .accessibilityAdjustableAction { dir in
                switch dir {
                case .increment: playhead = min(playhead + 0.5, total)
                case .decrement: playhead = max(playhead - 0.5, 0)
                @unknown default: break
                }
            }
        }
        .frame(height: 150)
        .padding(.horizontal, Space.gutter)
    }

    private var toolRow: some View {
        HStack(spacing: 0) {
            ForEach(tools) { t in
                let name = t.id, glyph = t.glyph
                let on = tool == name
                Button {
                    Haptics.select()
                    tool = name
                    if name == "Beat sync" { Haptics.success() }
                } label: {
                    VStack(spacing: 5) {
                        Icon(glyph, size: 22, color: on ? .coral : .white)
                        Text(name).font(.mova(11, .medium)).foregroundStyle(on ? .white : Color.w52)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(.horizontal, Space.s)
    }

    private var looksRail: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Space.xs) {
                ForEach(Look.all) { look in
                    let on = model.look.id == look.id
                    Button {
                        Haptics.select()
                        withAnimation(Motion.snappy) { model.look = look }
                    } label: {
                        VStack(spacing: 5) {
                            PhotoCrop(name: "fashion_yellow", scale: 1.6, anchor: UnitPoint(x: 0.5, y: 0.3))
                                .look(look)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(on ? Color.coral : .clear, lineWidth: 2))
                            Text(look.name).font(.mova(11, .medium)).foregroundStyle(on ? .white : Color.w52)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(look.name) look")
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, Space.gutter, for: .scrollContent)
    }
}

#Preview {
    EditorView().environment(AppModel())
}
