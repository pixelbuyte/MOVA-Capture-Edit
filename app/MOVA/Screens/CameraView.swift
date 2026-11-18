import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 01 — coached Recreate camera (shows screen 13 when camera access is off).
struct CameraView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var camera = CameraService()
    @State private var mode = "Recreate"
    @State private var showSaved = false

    private let modes = ["Recreate", "Video", "Photo", "Slo-mo"]
    /// Demo framing until live subject detection exists: the subject box is a little small vs the reference.
    private let liveBox = FramingBox(x: 0.33, y: 0.24, width: 0.34, height: 0.62)
    private let referenceBox = FramingBox(x: 0.30, y: 0.18, width: 0.40, height: 0.72)

    var body: some View {
        Group {
            switch camera.access {
            case .denied:
                CameraPermissionView(onAllow: { camera.openSettings() }, onClose: close)
            default:
                viewfinder
            }
        }
        .background(Color.black)
        .statusBarHidden()
        .task {
            // No camera (Simulator): skip the permission prompt and show the demo frame.
            guard camera.isAvailable else { return }
            camera.refreshAccess()
            if camera.access == .unknown { await camera.requestAccess() }
            camera.start()
        }
        .onDisappear { camera.stop() }
    }

    private var shotIndex: Int { min(model.shotsCaptured, model.plan.shots.count - 1) }
    private var shot: Shot { model.plan.shots[shotIndex] }
    private var match: Int { Int((liveBox.iou(referenceBox) * 100 + 30).rounded()).clamped(0, 99) }

    // MARK: Viewfinder

    private var viewfinder: some View {
        ZStack {
            Group {
                if camera.isAvailable && camera.access == .granted {
                    CameraPreview(session: camera.session)
                } else {
                    SamplePhoto(name: "fashion_yellow")   // Simulator / no camera: demo frame
                }
            }
            .ignoresSafeArea()

            if model.showsGrid { gridOverlay.ignoresSafeArea() }

            MediaScrim(top: 0.6, bottom: 0.0).ignoresSafeArea()

            if model.guideGhostOn && mode == "Recreate" {
                ReferenceGhost()
                    .frame(width: 210, height: 430)
                    .overlay(alignment: .topLeading) {
                        Text("Reference")
                            .font(.mova(12, .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 10).frame(height: 24)
                            .background(Color.coral, in: Capsule())
                            .offset(x: -70, y: 120)
                    }
                    .offset(y: 30)
                    .transition(.opacity)
            }

            VStack(spacing: 0) {
                topBar
                coachRow.padding(.top, Space.s)
                Spacer()
                modeRow.padding(.bottom, Space.s)
                tray
            }
        }
        .animation(reduceMotion ? nil : Motion.soft, value: model.guideGhostOn)
    }

    private var topBar: some View {
        VStack(spacing: Space.s) {
            ShotBar(fractions: model.plan.fractions, done: model.shotsCaptured,
                    current: camera.isRecording ? shotIndex : nil, height: 4)
                .padding(.horizontal, Space.m)
            HStack(alignment: .center) {
                CircleIconButton(glyph: .x, label: "Close camera", action: close)
                Spacer()
                VStack(spacing: 2) {
                    if camera.isRecording {
                        HStack(spacing: 6) {
                            Circle().fill(Color.coral).frame(width: 8, height: 8)
                            Text(timecode(camera.recordedSeconds)).font(.movaMono(13, medium: true)).monospacedDigit()
                        }
                        .foregroundStyle(.white)
                    } else {
                        HStack(spacing: 6) {
                            EyebrowText("Shot \(shot.number) of \(model.plan.shots.count)", color: .coral)
                            EyebrowText("· \(String(format: "%.1f", shot.duration))s", color: .w72)
                        }
                    }
                    Text(shot.name).font(.mova(20, .bold)).foregroundStyle(.white)
                }
                Spacer()
                CircleIconButton(glyph: .lightning, label: camera.flashOn ? "Flash on" : "Flash off",
                                 tint: camera.flashOn ? Color.sun : nil) { camera.flashOn.toggle() }
            }
            .padding(.horizontal, Space.m)
        }
        .padding(.top, Space.xs)
    }

    private var coachRow: some View {
        HStack(spacing: Space.xs) {
            HStack(spacing: Space.s) {
                MatchRing(value: match, size: 46, lineWidth: 4)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        EyebrowText("Match", color: .mint)
                        EyebrowText("· \(match >= 85 ? "Nearly" : "Keep going")")
                    }
                    Text(liveBox.tip(toward: referenceBox) ?? "Hold it there")
                        .font(.mova(16, .semibold)).foregroundStyle(.white)
                }
                Spacer(minLength: 0)
            }
            .padding(Space.xs)
            .glass()
            .accessibilityElement(children: .combine)

            HStack(spacing: Space.xs) {
                Icon(shot.move.glyph, size: 18)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    EyebrowText("Move")
                    Text(shot.move.label).font(.mova(16, .semibold)).foregroundStyle(.white).lineLimit(1)
                }
            }
            .padding(Space.xs)
            .padding(.trailing, Space.xxs)
            .glass()
            .accessibilityElement(children: .combine)
        }
        .padding(.horizontal, Space.m)
    }

    private var modeRow: some View {
        HStack(spacing: Space.xs) {
            ForEach(modes, id: \.self) { m in
                Button {
                    Haptics.select()
                    withAnimation(Motion.snappy) { mode = m }
                } label: {
                    Text(m)
                        .font(.mova(15, .semibold))
                        .foregroundStyle(.white.opacity(mode == m ? 1 : 0.8))
                        .padding(.horizontal, 14)
                        .frame(height: 34)
                        .background(mode == m ? Color.coral : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(mode == m ? .isSelected : [])
            }
        }
    }

    private var tray: some View {
        HStack(alignment: .center) {
            trayButton(label: "Last take") {
                SamplePhoto(name: "fashion_yellow")
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(.white.opacity(0.8), lineWidth: 1.5))
            } action: { close(); model.tab = .library }

            trayButton(label: "Look") { Icon(.swatches, size: 20).frame(width: 44, height: 44).background(Color.white.opacity(0.08), in: Circle()) } action: {}

            ShutterButton(fractions: model.plan.fractions, done: model.shotsCaptured, isRecording: camera.isRecording, action: shutter)
                .frame(maxWidth: .infinity)

            trayButton(label: "Guide", on: model.guideGhostOn) {
                Icon(.userFocus, size: 20, color: model.guideGhostOn ? .coral : .white)
                    .frame(width: 44, height: 44)
                    .background(model.guideGhostOn ? Color.coral.opacity(0.18) : Color.white.opacity(0.08), in: Circle())
            } action: { model.guideGhostOn.toggle() }

            trayButton(label: "Flip") { Icon(.cameraRotate, size: 20).frame(width: 44, height: 44).background(Color.white.opacity(0.08), in: Circle()) } action: { camera.flip() }
        }
        .padding(.horizontal, Space.s)
        .padding(.top, Space.m)
        .padding(.bottom, Space.xs)
        .background(Color.ink.ignoresSafeArea(edges: .bottom))
    }

    private func trayButton<Content: View>(label: String, on: Bool = false, @ViewBuilder content: () -> Content, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            VStack(spacing: 6) {
                content()
                Text(label).font(.mova(11, .medium)).foregroundStyle(on ? Color.coral : Color.w72)
            }
            .frame(width: 60)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var gridOverlay: some View {
        GeometryReader { geo in
            Path { p in
                for i in 1...2 {
                    let x = geo.size.width * CGFloat(i) / 3, y = geo.size.height * CGFloat(i) / 3
                    p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: geo.size.height))
                    p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.18), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }

    // MARK: Actions

    private func shutter() {
        if camera.isRecording {
            camera.stopRecording()
            return
        }
        camera.startRecording(maxSeconds: shot.duration) { url in
            model.captured(take: url)
            Haptics.success()
            if model.allShotsCaptured {
                model.showCamera = false
                model.open(.result)
            }
        }
    }

    private func close() {
        if camera.isRecording { camera.stopRecording() }
        model.showCamera = false
    }
}

private extension Int {
    func clamped(_ lo: Int, _ hi: Int) -> Int { Swift.min(Swift.max(self, lo), hi) }
}

#Preview {
    CameraView().environment(AppModel())
}
