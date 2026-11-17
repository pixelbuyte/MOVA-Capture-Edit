import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 12 — export in progress, then the saved state.
struct ExportingView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var cancelled = false

    private let renderSeconds = 3.0
    private var done: Bool { model.exportProgress >= 1 }

    var body: some View {
        let p = model.exportProgress
        let total = model.plan.totalDuration
        VStack(spacing: Space.l) {
            Spacer(minLength: Space.m)

            ZStack {
                SamplePhoto(name: "fashion_yellow")
                    .look(model.look)
                    .frame(width: 200, height: 286)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(Color.black.opacity(done ? 0 : 0.45).clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous)))
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .trim(from: 0, to: p)
                    .stroke(done ? Color.mint : Color.coral, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 214, height: 300)
                if done {
                    Icon(.checkCircle, .fill, size: 56, color: .mint)
                } else {
                    VStack(spacing: 4) {
                        Text("\(Int(p * 100))%").font(.mova(44, .bold)).foregroundStyle(.white).monospacedDigit()
                        Text("\(timecode(total * p)) of \(timecode(total))").font(.movaMono(12)).foregroundStyle(Color.w72)
                    }
                }
            }
            .accessibilityElement()
            .accessibilityLabel(done ? "Saved" : "Exporting")
            .accessibilityValue("\(Int(p * 100)) percent")

            VStack(spacing: 4) {
                Text(done ? "Saved to Photos" : ExportStep.current(at: p).rawValue)
                    .font(.movaH1).foregroundStyle(.white)
                Text(done ? model.exportSettings.summary : "About \(max(1, Int(((1 - p) * renderSeconds).rounded(.up)))) seconds left")
                    .font(.movaMono(12)).foregroundStyle(Color.w52)
            }

            if !done {
                VStack(spacing: 0) {
                    ForEach(ExportStep.allCases, id: \.self) { step in
                        stepRow(step, progress: p)
                    }
                }
                .padding(.horizontal, Space.m)
                .raisedCard()
                .padding(.horizontal, Space.gutter)
            }

            Spacer(minLength: Space.m)

            VStack(spacing: Space.xs) {
                if done {
                    Button("Back to Studio") {
                        model.popToRoot()
                        model.tab = .studio
                    }
                    .buttonStyle(.movaPrimary)
                } else {
                    Text("Keep MOVA open — rendering on this iPhone").font(.movaCaption).foregroundStyle(Color.w52)
                    Button("Cancel export") {
                        cancelled = true
                        model.exportProgress = 0
                        model.back()
                    }
                    .buttonStyle(.movaSecondary)
                }
            }
            .padding(.horizontal, Space.gutter)
            .padding(.bottom, Space.s)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ink)
        .task {
            // TODO: real AVAssetExportSession / AVMutableComposition render of model.takes with model.look,
            // then save with PHPhotoLibrary. Simulated so the flow can be reviewed end to end.
            model.exportProgress = 0
            let steps = 60
            for _ in 0..<steps {
                try? await Task.sleep(for: .seconds(renderSeconds / Double(steps)))
                if cancelled || Task.isCancelled { return }
                if reduceMotion {
                    model.exportProgress = min(1, model.exportProgress + 1 / Double(steps))
                } else {
                    withAnimation(.linear(duration: renderSeconds / Double(steps))) {
                        model.exportProgress = min(1, model.exportProgress + 1 / Double(steps))
                    }
                }
            }
            model.exportProgress = 1
            Haptics.success()
        }
    }

    private func stepRow(_ step: ExportStep, progress p: Double) -> some View {
        let all = ExportStep.allCases
        let current = ExportStep.current(at: p)
        let idx = all.firstIndex(of: step) ?? 0
        let curIdx = all.firstIndex(of: current) ?? 0
        let state = idx < curIdx ? "done" : idx == curIdx ? "running" : "pending"
        let detail: String = switch step {
        case .renderingClips: "\(model.plan.shots.count) clips"
        case .applyingLook: model.look.name
        case .mixingAudio: "Low tide"
        case .saving: "To Photos"
        }
        return HStack(spacing: Space.s) {
            Group {
                switch state {
                case "done": Icon(.checkCircle, .fill, size: 20, color: .white)
                case "running": ProgressView().tint(.coral).frame(width: 20, height: 20)
                default: Circle().strokeBorder(Color.hair, lineWidth: 2).frame(width: 18, height: 18)
                }
            }
            .frame(width: 22)
            Text(step.rawValue).font(.mova(15, state == "pending" ? .regular : .semibold))
                .foregroundStyle(state == "pending" ? Color.w52 : .white)
            Spacer()
            Text(detail).font(.movaMono(12)).foregroundStyle(Color.w52)
        }
        .frame(minHeight: 46)
        .accessibilityElement(children: .combine)
        .accessibilityValue(state)
    }
}

#Preview {
    ExportingView().environment(AppModel())
}
