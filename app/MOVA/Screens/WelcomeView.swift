import SwiftUI
import MovaCore

/// Screen 02 — first launch. One promise, one photo, one button.
struct WelcomeView: View {
    var onContinue: () -> Void
    private let plan = Samples.courtPlan

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.ink.ignoresSafeArea()

            GeometryReader { geo in
                SamplePhoto(name: "hoodie")
                    .frame(width: geo.size.width, height: geo.size.height * 0.68)
                    .clipped()
                    .overlay(LinearGradient(colors: [.clear, .ink], startPoint: .center, endPoint: .bottom))
            }
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Circle().fill(Color.coral).frame(width: 10, height: 10)
                    Text("MOVA").font(.mova(22, .heavy)).foregroundStyle(.white)
                }
                .padding(.top, Space.m)

                Spacer()

                proofCard
                    .padding(.bottom, Space.xl)

                Text("Shoot it like\nyou saw it.")
                    .font(.mova(40, .bold, relativeTo: .largeTitle))
                    .foregroundStyle(.white)
                    .lineSpacing(-4)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Drop in a TikTok, Reel or Short. MOVA finds the shots and coaches you through them.")
                    .font(.movaCallout)
                    .foregroundStyle(Color.w72)
                    .padding(.top, Space.s)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    Haptics.tap()
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Text("Start creating")
                        Icon(.arrowRight, .bold, size: 18)
                    }
                }
                .buttonStyle(.movaPrimary)
                .padding(.top, Space.xl)

                Button("I already have an account", action: onContinue)
                    .font(.mova(15, .medium))
                    .foregroundStyle(Color.w72)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.top, Space.xs)
            }
            .padding(.horizontal, Space.gutter)
            .padding(.bottom, Space.s)
        }
    }

    /// Glass card showing the feature: a clip already split into four shots.
    private var proofCard: some View {
        HStack(spacing: Space.s) {
            SamplePhoto(name: "fashion_yellow")
                .frame(width: 46, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    EyebrowText("Reference", color: .coral)
                    EyebrowText("· \(String(format: "%.1f", plan.totalDuration))s")
                }
                Text("\(plan.shots.count) shots found").font(.mova(17, .semibold)).foregroundStyle(.white)
                ShotBar(fractions: plan.fractions, done: plan.shots.count, height: 4)
            }
        }
        .padding(Space.s)
        .glass()
        .accessibilityElement(children: .combine)
    }
}

#Preview { WelcomeView {} }
