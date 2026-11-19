import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 04 — the reference clip and what MOVA found in it.
struct ReferenceView: View {
    @Environment(AppModel.self) private var model
    @State private var playing = false
    @State private var playhead = 0.0

    private let palette: [Color] = [Color(hex: 0xF2B632), Color(hex: 0x6CB7D3), Color(hex: 0xD9C3A0), Color(hex: 0x2F5D73), Color(hex: 0xEEE6DA)]

    var body: some View {
        let plan = model.plan
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.l) {
                    media(plan)
                    VStack(alignment: .leading, spacing: Space.l) {
                        titleBlock(plan)
                        found(plan)
                    }
                    .padding(.horizontal, Space.gutter)
                }
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)

            Button {
                model.open(.breakdown)
            } label: {
                HStack(spacing: 8) { Icon(.scissors, .bold, size: 18); Text("Break it into shots") }
            }
            .buttonStyle(.movaPrimary)
            .padding(.horizontal, Space.gutter)
            .padding(.bottom, Space.s)
            .background(LinearGradient(colors: [.clear, .ink], startPoint: .top, endPoint: .center).ignoresSafeArea())
        }
        .background(Color.ink)
        .task(id: playing) {
            guard playing else { return }
            while playing && !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                playhead += 0.05
                if playhead >= plan.totalDuration { playhead = 0; playing = false }
            }
        }
    }

    private func media(_ plan: ShotPlan) -> some View {
        ZStack(alignment: .bottomLeading) {
            SamplePhoto(name: "fashion_yellow")
                .frame(height: 420)
                .frame(maxWidth: .infinity)
                .clipped()
            MediaScrim(top: 0.5, bottom: 0.9)
            HStack {
                CircleIconButton(glyph: .caretLeft, label: "Back") { model.back() }
                Spacer()
                CircleIconButton(glyph: .dotsThree, label: "More") {}
            }
            .padding(.horizontal, Space.gutter)
            .padding(.top, 60)
            .frame(maxHeight: .infinity, alignment: .top)

            HStack(spacing: Space.s) {
                Button {
                    playing.toggle()
                } label: {
                    Icon(playing ? .pause : .play, .fill, size: 20, color: .ink)
                        .frame(width: 44, height: 44)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(playing ? "Pause" : "Play")
                Text("\(timecode(playhead)) / \(timecode(plan.totalDuration))")
                    .font(.movaMono(13)).foregroundStyle(.white).monospacedDigit()
                Spacer()
                Chip(text: "9:16 · 30 fps", background: .black.opacity(0.45))
            }
            .padding(Space.gutter)
        }
        .frame(height: 420)
    }

    private func titleBlock(_ plan: ShotPlan) -> some View {
        VStack(alignment: .leading, spacing: Space.s) {
            HStack(spacing: 6) {
                EyebrowText("Reference", color: .coral)
                EyebrowText("· Imported clip")
            }
            Text(plan.title).font(.movaH1).foregroundStyle(.white)
            ShotBar(fractions: plan.fractions, done: plan.shots.count, current: plan.shotIndex(at: playhead), height: 6,
                    doneColor: Color.coral.opacity(0.55), currentColor: .coral)
            GeometryReader { geo in
                let starts = plan.startTimes
                ForEach(plan.shots.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(plan.shots[i].number)").font(.movaMono(11, medium: true)).foregroundStyle(.white)
                        Text(timecode(starts[i])).font(.movaMono(11)).foregroundStyle(Color.w52)
                    }
                    .offset(x: geo.size.width * CGFloat(starts[i] / max(plan.totalDuration, 0.001)))
                }
            }
            .frame(height: 32)
        }
    }

    private func found(_ plan: ShotPlan) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("What MOVA found").font(.movaH2).foregroundStyle(.white)
                Spacer()
                EyebrowText("Detected · editable")
            }
            .padding(.bottom, Space.xs)

            row(.filmStrip, "Shots", "\(plan.shots.count) in \(String(format: "%.1f", plan.totalDuration))s")
            row(.videoCamera, "Camera moves", Set(plan.shots.map(\.move)).map(\.label).sorted().joined(separator: ", "))
            row(.waveform, "Beat", "\(Int(model.beat.bpm)) BPM · cuts on the beat")
            row(.sun, "Light and grade", "Hard sun, warm")
            HStack {
                Text("Palette").font(.mova(15, .medium)).foregroundStyle(Color.w72)
                Spacer()
                HStack(spacing: 6) {
                    ForEach(palette.indices, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 5).fill(palette[i]).frame(width: 22, height: 22)
                    }
                }
            }
            .frame(minHeight: 48)
        }
        .padding(.horizontal, Space.m)
        .padding(.vertical, Space.s)
        .raisedCard()
    }

    private func row(_ glyph: Ph, _ title: String, _ value: String) -> some View {
        HStack(spacing: Space.s) {
            Icon(glyph, size: 18, color: .w72)
            Text(title).font(.mova(15, .medium)).foregroundStyle(Color.w72)
            Spacer()
            Text(value).font(.mova(15, .semibold)).foregroundStyle(.white).multilineTextAlignment(.trailing)
        }
        .frame(minHeight: 48)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1) }
    }
}

#Preview {
    ReferenceView().environment(AppModel())
}
