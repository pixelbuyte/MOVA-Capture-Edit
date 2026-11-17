import SwiftUI
import MovaCore

/// Screen 03 — Studio (home tab).
struct StudioView: View {
    @Environment(AppModel.self) private var model
    @State private var link = ""
    @State private var isAnalyzing = false

    private struct Template: Identifiable {
        let id = UUID()
        let photo: String, title: String, shots: Int, seconds: Int, level: Int
    }
    private let templates = [
        Template(photo: "cinema", title: "Neon night out", shots: 5, seconds: 12, level: 2),
        Template(photo: "mustang", title: "Car reveal", shots: 4, seconds: 10, level: 1),
        Template(photo: "dog", title: "Pet intro", shots: 3, seconds: 8, level: 1),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.l) {
                header
                hero
                pasteRow
                section("Templates", trailing: "See all")
                templateRail
                section("Continue", trailing: "2 projects")
                continueRows
            }
            .padding(.horizontal, Space.gutter)
            .padding(.top, Space.s)
            .clearsTabBar()
        }
        .scrollIndicators(.hidden)
        .background(Color.ink)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hi \(model.name)").font(.movaCallout).foregroundStyle(Color.w72)
                Text("Studio").font(.movaTitle).foregroundStyle(.white)
            }
            Spacer()
            CircleIconButton(glyph: .bell, label: "Notifications") {}
            SamplePhoto(name: "port_bun")
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .onTapGesture { model.tab = .you }
                .accessibilityLabel("Your profile")
                .accessibilityAddTraits(.isButton)
        }
    }

    private var hero: some View {
        Button {
            model.open(.reference)
        } label: {
            ZStack(alignment: .bottomLeading) {
                SamplePhoto(name: "road")
                    .frame(height: 230)
                    .clipped()
                MediaScrim(top: 0.35, bottom: 0.95)
                VStack(alignment: .leading, spacing: Space.xs) {
                    HStack {
                        Chip(text: "Trending", glyph: .fire, tint: .sun, background: .black.opacity(0.4))
                        Spacer()
                        Text("@lena.drives").font(.movaMono(12)).foregroundStyle(Color.w72)
                    }
                    Spacer()
                    EyebrowText("4 shots · 0:09")
                    HStack(alignment: .bottom) {
                        Text("Open road reveal").font(.movaH1).foregroundStyle(.white)
                        Spacer()
                        Text("Recreate")
                            .font(.mova(15, .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(Color.coral, in: Capsule())
                    }
                    ShotBar(fractions: Samples.courtPlan.fractions, done: 4, height: 4)
                }
                .padding(Space.m)
            }
            .frame(height: 230)
            .clipShape(RoundedRectangle(cornerRadius: Radius.media, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open road reveal, trending, 4 shots. Recreate.")
    }

    private var pasteRow: some View {
        HStack(spacing: Space.s) {
            Icon(.linkSimple, size: 20, color: .w72)
            TextField("", text: $link, prompt: Text("Paste a TikTok, Reel or Short").foregroundStyle(Color.w52))
                .font(.mova(15, .medium))
                .foregroundStyle(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .onSubmit(analyze)
            Button(isAnalyzing ? "Reading…" : (link.isEmpty ? "Paste" : "Go")) {
                if link.isEmpty, let s = UIPasteboard.general.string { link = s }
                analyze()
            }
            .font(.mova(14, .semibold))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(Color.white, in: Capsule())
            .disabled(isAnalyzing)
        }
        .padding(.horizontal, Space.m)
        .frame(minHeight: 56)
        .raisedCard()
    }

    private func analyze() {
        guard !link.isEmpty, !isAnalyzing else { return }
        isAnalyzing = true
        Task {
            await model.analyze(link: link)
            isAnalyzing = false
        }
    }

    private func section(_ title: String, trailing: String) -> some View {
        HStack {
            Text(title).font(.movaH2).foregroundStyle(.white)
            Spacer()
            Text(trailing).font(.movaCaption).foregroundStyle(Color.w52)
        }
    }

    private var templateRail: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Space.s) {
                ForEach(templates) { t in
                    Button { model.open(.reference) } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack(alignment: .topLeading) {
                                SamplePhoto(name: t.photo)
                                    .frame(width: 128, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                difficulty(t.level).padding(8)
                            }
                            Text(t.title).font(.mova(14, .semibold)).foregroundStyle(.white).lineLimit(1)
                            Text("\(t.shots) shots · 0:\(String(format: "%02d", t.seconds))").font(.movaMono(11)).foregroundStyle(Color.w52)
                        }
                        .frame(width: 128, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, -Space.gutter)
        .contentMargins(.horizontal, Space.gutter, for: .scrollContent)
    }

    /// Three white signal bars + label (mint stays reserved for match).
    private func difficulty(_ level: Int) -> some View {
        HStack(spacing: 5) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(1...3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1).fill(i <= level ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 3, height: CGFloat(4 + i * 3))
                }
            }
            Text(level == 1 ? "Easy" : level == 2 ? "Medium" : "Hard").font(.mova(11, .semibold)).foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .frame(height: 24)
        .background(.black.opacity(0.45), in: Capsule())
    }

    private var continueRows: some View {
        VStack(spacing: Space.xs) {
            continueRow(photo: "fashion_yellow", title: "Court dance", detail: "2 of 4 shots", score: 86, done: 2) {
                model.startRecreation()
            }
            continueRow(photo: "headphones", title: "Headphone drop", detail: "Editing", score: nil, done: 3) {
                model.open(.editor)
            }
        }
    }

    private func continueRow(photo: String, title: String, detail: String, score: Int?, done: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Space.s) {
                SamplePhoto(name: photo)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 6) {
                    Text(title).font(.mova(15, .semibold)).foregroundStyle(.white)
                    HStack(spacing: 6) {
                        Text(detail).font(.movaMono(11)).foregroundStyle(Color.w52)
                        if let score {
                            Text("· \(score)% match").font(.movaMono(11, medium: true)).foregroundStyle(Color.mint)
                        }
                    }
                    ShotBar(fractions: Samples.courtPlan.fractions, done: done, height: 3)
                }
                Icon(.caretRight, size: 16, color: .w52)
            }
            .padding(Space.s)
            .raisedCard(radius: 18)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StudioView().environment(AppModel())
}
