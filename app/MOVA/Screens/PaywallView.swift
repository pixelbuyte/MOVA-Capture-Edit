import SwiftUI
import MovaCore
import PhosphorSwift

/// Screen 11 — MOVA Pro. Presented as a sheet.
/// Prices below are placeholders; real prices must come from StoreKit (`Product.displayPrice`).
struct PaywallView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var yearly = true

    private let benefits: [(Ph, String, String)] = [
        (.infinity, "Unlimited recreations", "No monthly cap"),
        (.frameCorners, "4K export", "At 24, 30 or 60 fps"),
        (.swatches, "All looks", "Every colour look, on every clip"),
        (.waveform, "Beat sync", "Cuts snap to the music"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.l) {
                hero

                VStack(alignment: .leading, spacing: Space.s) {
                    ForEach(benefits.indices, id: \.self) { i in
                        let b = benefits[i]
                        HStack(spacing: Space.s) {
                            Icon(b.0, size: 20, color: .white)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(b.1).font(.mova(15, .semibold)).foregroundStyle(.white)
                                Text(b.2).font(.movaCaption).foregroundStyle(Color.w52)
                            }
                        }
                    }
                }
                .padding(.horizontal, Space.gutter)

                VStack(spacing: Space.xs) {
                    plan(selected: yearly, title: "Yearly", price: "$39.99", note: "$3.33 a month, billed yearly", tag: "Save 44%") { yearly = true }
                    plan(selected: !yearly, title: "Monthly", price: "$5.99", note: "Billed monthly", tag: nil) { yearly = false }
                }
                .padding(.horizontal, Space.gutter)

                VStack(spacing: Space.s) {
                    Button("Start 7-day free trial") {
                        // TODO: StoreKit 2 purchase of the selected product; unlock only on a verified transaction.
                        model.isPro = true
                        Haptics.success()
                        close()
                    }
                    .buttonStyle(.movaPrimary)

                    Text("Free for 7 days, then \(yearly ? "$39.99 a year" : "$5.99 a month"). Renews until you cancel. Cancel anytime in Settings.")
                        .font(.movaCaption).foregroundStyle(Color.w52)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: Space.l) {
                        Button("Restore purchases") {}     // TODO: AppStore.sync()
                        Button("Terms") {}
                        Button("Privacy") {}
                    }
                    .font(.mova(13, .medium))
                    .foregroundStyle(Color.w72)
                }
                .padding(.horizontal, Space.gutter)
            }
            .padding(.bottom, Space.l)
        }
        .scrollIndicators(.hidden)
        .background(Color.ink)
        .ignoresSafeArea(edges: .top)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            SamplePhoto(name: "hiker")
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipped()
            LinearGradient(colors: [.clear, .ink], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: Space.xs) {
                HStack(spacing: 6) {
                    Circle().fill(Color.coral).frame(width: 8, height: 8)
                    EyebrowText("MOVA Pro", color: .white)
                }
                Text("Recreate anything.\nExport it in 4K.").font(.movaTitle).foregroundStyle(.white)
            }
            .padding(Space.gutter)
            CircleIconButton(glyph: .x, label: "Close", action: close)
                .padding(.top, 56)
                .padding(.trailing, Space.m)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .frame(height: 300)
    }

    private func plan(selected: Bool, title: String, price: String, note: String, tag: String?, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.select()
            action()
        } label: {
            HStack(spacing: Space.s) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(selected ? Color.white : Color.w52)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title).font(.mova(16, .semibold)).foregroundStyle(.white)
                        if let tag {
                            Text(tag).font(.mova(11, .semibold)).foregroundStyle(Color.ink)
                                .padding(.horizontal, 7).frame(height: 20)
                                .background(Color.white, in: Capsule())
                        }
                    }
                    Text(note).font(.movaCaption).foregroundStyle(Color.w52)
                }
                Spacer()
                Text(price).font(.movaMono(16, medium: true)).foregroundStyle(.white)
            }
            .padding(Space.m)
            .raisedCard()
            .overlay(RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(selected ? Color.white : .clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func close() {
        model.showPaywall = false
        dismiss()
    }
}

#Preview {
    PaywallView().environment(AppModel())
}
