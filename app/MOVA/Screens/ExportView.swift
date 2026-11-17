import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 08 — pick a size, save. Rendering happens on the device (screen 12).
struct ExportView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        let duration = model.plan.totalDuration
        let mb = model.exportSettings.estimatedMegabytes(duration: duration)
        ScrollView {
            VStack(spacing: Space.l) {
                ScreenHeader(eyebrow: "Seaside recreate", title: "Export", onBack: { model.back() })
                    .padding(.horizontal, -Space.gutter)

                ZStack(alignment: .topTrailing) {
                    SamplePhoto(name: "fashion_yellow")
                        .look(model.look)
                        .frame(width: 210, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    ScoreBadge(score: model.score.overall).padding(Space.s)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Space.xs)
                .background {
                    SamplePhoto(name: "fashion_yellow").blur(radius: 40).opacity(0.35).clipped()
                }

                VStack(spacing: Space.s) {
                    row("Resolution") {
                        SegmentedPill(options: ExportResolution.allCases, selection: $model.exportSettings.resolution) { $0.rawValue }
                            .frame(width: 170)
                    }
                    row("Frame rate") {
                        SegmentedPill(options: ExportFrameRate.allCases, selection: $model.exportSettings.frameRate) { "\($0.rawValue)" }
                            .frame(width: 200)
                    }
                }

                HStack(spacing: Space.s) {
                    Icon(.deviceMobile, size: 22, color: .w72)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Renders on this iPhone").font(.mova(15, .semibold)).foregroundStyle(.white)
                        Text("About \(estimatedSeconds) seconds").font(.movaCaption).foregroundStyle(Color.w52)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(mb) MB").font(.movaMono(15, medium: true)).foregroundStyle(.white)
                        EyebrowText("est. size")
                    }
                }
                .padding(Space.m)
                .raisedCard()

                HStack(spacing: Space.xs) {
                    ShareLink(item: "Made with MOVA") {
                        Icon(.shareNetwork, size: 20)
                            .frame(width: 54, height: 54)
                            .background(Color.white.opacity(0.1), in: Circle())
                    }
                    .accessibilityLabel("Share")
                    Button {
                        model.exportProgress = 0
                        model.open(.exporting)
                    } label: {
                        HStack(spacing: 8) { Icon(.downloadSimple, .bold, size: 18); Text("Save to Photos") }
                    }
                    .buttonStyle(.movaPrimary)
                }

                Text(model.exportSettings.summary).font(.movaMono(11)).foregroundStyle(Color.w52)
            }
            .padding(.horizontal, Space.gutter)
            .padding(.top, Space.xs)
            .padding(.bottom, Space.l)
        }
        .scrollIndicators(.hidden)
        .background(Color.ink)
    }

    /// Rough on-device render time: 4K takes longer, higher frame rates take longer.
    private var estimatedSeconds: Int {
        let base = model.exportSettings.resolution == .uhd4k ? 0.9 : 0.4
        let fps = Double(model.exportSettings.frameRate.rawValue) / 30
        return max(2, Int((model.plan.totalDuration * base * fps).rounded()))
    }

    private func row<Control: View>(_ title: String, @ViewBuilder control: () -> Control) -> some View {
        HStack {
            Text(title).font(.mova(15, .medium)).foregroundStyle(Color.w72)
            Spacer()
            control()
        }
    }
}

#Preview {
    ExportView().environment(AppModel())
}
