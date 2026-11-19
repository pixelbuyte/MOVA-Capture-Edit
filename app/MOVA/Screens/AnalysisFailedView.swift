import SwiftUI
import PhotosUI
import MovaCore
import PhosphorSwift

/// Screen 14 — a pasted clip couldn't be broken into shots. Says why, and offers three ways forward.
struct AnalysisFailedView: View {
    @Environment(AppModel.self) private var model
    let error: AnalysisError
    @State private var pick: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.l) {
                header

                VStack(alignment: .leading, spacing: Space.s) {
                    Text("Couldn't break down this clip").font(.movaH1).foregroundStyle(.white)
                    ShotBar(fractions: [1], done: 0, height: 6, restColor: Color.sun.opacity(0.5))
                    if case .noCuts = error {
                        EyebrowText("No cuts found", color: .sun)
                    }
                }

                HStack(alignment: .top, spacing: Space.s) {
                    Icon(.warningCircle, size: 22, color: .sun)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(error.title).font(.mova(16, .semibold)).foregroundStyle(.white)
                        Text(error.detail).font(.movaCallout).foregroundStyle(Color.w72)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(Space.m)
                .background(Color.sun.opacity(0.08), in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: Radius.card, style: .continuous).strokeBorder(Color.sun.opacity(0.3)))

                VStack(alignment: .leading, spacing: Space.xs) {
                    EyebrowText("Keep going")
                    VStack(spacing: 0) {
                        Button {
                            model.back()
                            model.open(.breakdown)
                        } label: {
                            IconRow(glyph: .pencilSimple, title: "Mark shots myself") { Icon(.caretRight, size: 16, color: .w52) }
                        }
                        .buttonStyle(.plain)
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                        PhotosPicker(selection: $pick, matching: .videos) {
                            IconRow(glyph: .images, title: "Pick from Photos") { Icon(.caretRight, size: 16, color: .w52) }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Space.m)
                    .raisedCard()
                }

                Button {
                    model.back()
                } label: {
                    HStack(spacing: 8) { Icon(.linkSimple, .bold, size: 18); Text("Try another link") }
                }
                .buttonStyle(.movaPrimary)
            }
            .padding(.horizontal, Space.gutter)
            .padding(.bottom, Space.l)
        }
        .scrollIndicators(.hidden)
        .background(Color.ink)
        .onChange(of: pick) { _, new in
            guard new != nil else { return }
            pick = nil
            model.back()
            model.open(.reference)
        }
    }

    private var header: some View {
        ZStack(alignment: .topLeading) {
            SamplePhoto(name: "fashion_yellow")
                .saturation(0.15)
                .opacity(0.7)
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Radius.media, style: .continuous))
            HStack {
                CircleIconButton(glyph: .caretLeft, label: "Back") { model.back() }
                Spacer()
                if case .offline = error {
                    Chip(text: "Offline", glyph: .wifiSlash, tint: .ink, background: .sun)
                }
            }
            .padding(Space.s)
        }
        .padding(.top, Space.xs)
    }
}

#Preview {
    AnalysisFailedView(error: .noCuts(seconds: 9)).environment(AppModel())
}
