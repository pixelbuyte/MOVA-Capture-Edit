import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 13 — replaces the viewfinder when camera access is off.
struct CameraPermissionView: View {
    var onAllow: () -> Void
    var onClose: () -> Void
    private let plan = Samples.courtPlan

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Space.s) {
                ShotBar(fractions: plan.fractions, done: 0, current: 0, height: 4)
                HStack {
                    CircleIconButton(glyph: .x, label: "Close", action: onClose)
                    Spacer()
                    VStack(spacing: 2) {
                        HStack(spacing: 6) {
                            EyebrowText("Shot 1 of \(plan.shots.count)", color: .coral)
                            EyebrowText("· \(String(format: "%.1f", plan.shots[0].duration))s")
                        }
                        Text(plan.shots[0].name).font(.mova(20, .bold)).foregroundStyle(.white)
                    }
                    Spacer()
                    CircleIconButton(glyph: .lightning, label: "Flash", tint: .w52) {}
                        .disabled(true)
                        .opacity(0.5)
                }
            }
            .padding(.horizontal, Space.m)
            .padding(.top, Space.xs)

            emptyFrame
                .frame(maxWidth: .infinity)
                .frame(height: 230)
                .padding(.top, Space.l)

            VStack(alignment: .leading, spacing: Space.s) {
                Text("MOVA can't see yet").font(.movaH1).foregroundStyle(.white)
                Text("Turn on the camera so MOVA can line you up with each shot. The microphone keeps your take's sound.")
                    .font(.movaCallout).foregroundStyle(Color.w72)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 0) {
                    accessRow(.camera, "Camera", "Frames each shot")
                    Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                    accessRow(.microphone, "Microphone", "Records your take's sound")
                }
                .padding(.horizontal, Space.m)
                .raisedCard()

                HStack(spacing: 8) {
                    Icon(.shieldCheck, size: 16, color: .w72)
                    Text("Footage stays on this iPhone unless you share it.").font(.movaCaption).foregroundStyle(Color.w72)
                }
                .padding(.top, Space.xxs)
            }
            .padding(.horizontal, Space.gutter)
            .padding(.top, Space.l)

            Spacer(minLength: Space.m)

            VStack(spacing: Space.xs) {
                Button {
                    Haptics.tap()
                    onAllow()
                } label: {
                    HStack(spacing: 8) { Text("Allow camera"); Icon(.arrowSquareOut, .bold, size: 18) }
                }
                .buttonStyle(.movaPrimary)
                Button("Not now", action: onClose)
                    .font(.mova(15, .medium)).foregroundStyle(Color.w72)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .padding(.horizontal, Space.gutter)
            .padding(.bottom, Space.s)
        }
        .background(Color.ink.ignoresSafeArea())
    }

    private var emptyFrame: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ink2)
                .frame(width: 150, height: 210)
            ReferenceGhost()
                .frame(width: 70, height: 150)
                .opacity(0.6)
            Icon(.cameraSlash, size: 34, color: .white)
                .frame(width: 64, height: 64)
                .background(Color.ink, in: Circle())
                .overlay(Circle().strokeBorder(Color.hair))
        }
        .accessibilityHidden(true)
    }

    private func accessRow(_ glyph: Ph, _ title: String, _ detail: String) -> some View {
        HStack(spacing: Space.s) {
            Icon(glyph, size: 20, color: .w72)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.mova(15, .semibold)).foregroundStyle(.white)
                Text(detail).font(.movaCaption).foregroundStyle(Color.w52)
            }
            Spacer()
            Text("Off").font(.movaMono(12, medium: true)).foregroundStyle(Color.ink)
                .padding(.horizontal, 10).frame(height: 24)
                .background(Color.sun, in: Capsule())
        }
        .frame(minHeight: 58)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CameraPermissionView(onAllow: {}, onClose: {})
}
