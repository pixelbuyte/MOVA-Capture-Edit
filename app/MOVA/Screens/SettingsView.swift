import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 10 — You / Settings tab.
struct SettingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        let recreations = model.library.filter(\.isRecreation)
        let avg = recreations.isEmpty ? 0 : recreations.compactMap { item -> Int? in
            if case .recreation(_, let s) = item.kind { return s }
            return nil
        }.reduce(0, +) / recreations.count

        ScrollView {
            VStack(alignment: .leading, spacing: Space.l) {
                profile
                HStack(spacing: Space.xs) {
                    stat("\(recreations.count)", "Recreations", .white)
                    stat("\(avg)%", "Avg match", .mint)
                    stat("5", "Day streak", .white)
                }

                group("Capture") {
                    IconRow(glyph: .frameCorners, title: "Resolution") {
                        Menu {
                            Picker("Resolution", selection: $model.defaultResolution) {
                                ForEach(ExportResolution.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                            }
                        } label: { value(model.defaultResolution.rawValue) }
                    }
                    divider
                    IconRow(glyph: .filmStrip, title: "Frame rate") {
                        Menu {
                            Picker("Frame rate", selection: $model.defaultFrameRate) {
                                ForEach(ExportFrameRate.allCases, id: \.self) { Text("\($0.rawValue) fps").tag($0) }
                            }
                        } label: { value("\(model.defaultFrameRate.rawValue) fps") }
                    }
                    divider
                    toggleRow(.gridFour, "Grid", $model.showsGrid)
                    divider
                    toggleRow(.userFocus, "Guide ghost", $model.guideGhostOn)
                }

                group("Coaching") {
                    toggleRow(.speakerHigh, "Voice tips", $model.voiceTips)
                    divider
                    toggleRow(.vibrate, "Haptics", $model.haptics)
                }

                group("This iPhone") {
                    IconRow(glyph: .hardDrives, title: "Storage") { value("1.2 GB") }
                    divider
                    IconRow(glyph: .shieldCheck, title: "Privacy") { value("Analyzed on device") }
                    divider
                    IconRow(glyph: .question, title: "Help") { Icon(.caretRight, size: 16, color: .w52) }
                }

                Text("MOVA 0.1.0").font(.movaMono(11)).foregroundStyle(Color.w52).frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Space.gutter)
            .padding(.top, Space.s)
            .clearsTabBar()
        }
        .scrollIndicators(.hidden)
        .background(Color.ink)
    }

    private var profile: some View {
        HStack(spacing: Space.s) {
            SamplePhoto(name: "port_bun")
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(model.name).font(.movaH1).foregroundStyle(.white)
                Text(model.isPro ? "MOVA Pro" : "Free plan").font(.movaCallout).foregroundStyle(Color.w72)
            }
            Spacer()
            if !model.isPro {
                Button {
                    model.showPaywall = true
                } label: {
                    HStack(spacing: 6) { Icon(.crown, .fill, size: 16); Text("Get Pro") }
                        .font(.mova(14, .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 14).frame(height: 38)
                        .background(Color.coral, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func stat(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.mova(24, .bold)).foregroundStyle(color).monospacedDigit()
            Text(label).font(.movaCaption).foregroundStyle(Color.w52)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Space.s)
        .raisedCard(radius: 16)
        .accessibilityElement(children: .combine)
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            EyebrowText(title)
            VStack(spacing: 0) { content() }
                .padding(.horizontal, Space.m)
                .raisedCard()
        }
    }

    private var divider: some View {
        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
    }

    private func value(_ text: String) -> some View {
        Text(text).font(.mova(14, .medium)).foregroundStyle(Color.w72)
    }

    private func toggleRow(_ glyph: Ph, _ title: String, _ binding: Binding<Bool>) -> some View {
        Toggle(isOn: binding) {
            HStack(spacing: Space.s) {
                Icon(glyph, size: 20, color: .w72)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                Text(title).font(.mova(15, .medium)).foregroundStyle(.white)
            }
        }
        .toggleStyle(MovaToggleStyle())
        .frame(minHeight: 50)
    }
}

#Preview {
    SettingsView().environment(AppModel())
}
