import SwiftUI
import PhotosUI
import MovaCore
import PhosphorSwift

/// Screen 15 — first-run Library with no takes.
struct LibraryEmptyView: View {
    @Environment(AppModel.self) private var model
    @State private var pick: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.l) {
            HStack(alignment: .firstTextBaseline) {
                Text("Library").font(.movaTitle).foregroundStyle(.white)
                Spacer()
                Icon(.magnifyingGlass, size: 20, color: .w52).accessibilityHidden(true)
            }

            Spacer(minLength: Space.m)

            illustration
                .frame(maxWidth: .infinity)

            VStack(spacing: Space.xs) {
                Text("Nothing shot yet").font(.movaH1).foregroundStyle(.white)
                Text("Your takes land here, each with its match score.")
                    .font(.movaCallout).foregroundStyle(Color.w72)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: Space.m)

            VStack(spacing: Space.xs) {
                Button {
                    model.tab = .studio
                } label: {
                    HStack(spacing: 8) { Icon(.plus, .bold, size: 18); Text("Recreate your first clip") }
                }
                .buttonStyle(.movaPrimary)

                PhotosPicker(selection: $pick, matching: .videos) {
                    HStack(spacing: 8) { Icon(.images, size: 18); Text("Import from Photos") }
                        .font(.mova(16, .semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.white.opacity(0.1), in: Capsule())
                }
                .onChange(of: pick) { _, new in
                    if new != nil { model.open(.reference); pick = nil }
                }
            }
        }
        .padding(.horizontal, Space.gutter)
        .padding(.top, Space.s)
        .clearsTabBar()
        .background(Color.ink)
    }

    /// Three 9:16 frames; the front one has the coral reference dashes and an empty four-shot bar.
    private var illustration: some View {
        ZStack {
            frame.rotationEffect(.degrees(-9)).offset(x: -54, y: 8).opacity(0.45)
            frame.rotationEffect(.degrees(8)).offset(x: 54, y: 8).opacity(0.45)
            ZStack {
                frame
                ReferenceGhost().frame(width: 50, height: 104).offset(y: -12)
                Icon(.plus, .bold, size: 18)
                    .frame(width: 38, height: 38)
                    .background(Color.coral, in: Circle())
                    .offset(y: 50)
                ShotBar(fractions: [0.36, 0.2, 0.26, 0.18], done: 0, current: 0, height: 3)
                    .frame(width: 92)
                    .offset(y: 82)
            }
        }
        .frame(height: 220)
        .accessibilityHidden(true)
    }

    private var frame: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.ink2)
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.hair))
            .frame(width: 112, height: 198)
    }
}

#Preview {
    LibraryEmptyView().environment(AppModel())
}
