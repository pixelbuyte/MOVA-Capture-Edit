import SwiftUI
import PhosphorSwift
import MovaCore

// MARK: - Shot bar
/// The segmented, duration-proportional shot bar used on Camera, Welcome, Studio, Reference and Result.
struct ShotBar: View {
    var fractions: [Double]
    /// Segments before this index are "done".
    var done: Int = 0
    /// Highlighted (current) segment, if any.
    var current: Int? = nil
    var height: CGFloat = 4
    var spacing: CGFloat = 4
    var doneColor: Color = .coral
    var currentColor: Color = .coral
    var restColor: Color = .hair
    /// Optional per-segment color override (e.g. Result: mint for good shots, sun for the one to fix).
    var colors: [Color]? = nil

    var body: some View {
        GeometryReader { geo in
            let usable = geo.size.width - spacing * CGFloat(max(fractions.count - 1, 0))
            HStack(spacing: spacing) {
                ForEach(Array(fractions.enumerated()), id: \.offset) { i, f in
                    Capsule()
                        .fill(color(for: i))
                        .frame(width: max(usable * f, 0))
                }
            }
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityLabel("\(fractions.count) shots")
        .accessibilityValue(current.map { "Shot \($0 + 1) of \(fractions.count)" } ?? "\(done) of \(fractions.count) done")
    }

    private func color(for i: Int) -> Color {
        if let colors, colors.indices.contains(i) { return colors[i] }
        if i == current { return currentColor }
        return i < done ? doneColor : restColor
    }
}

// MARK: - Match ring
/// Mint progress ring with the percentage inside. Mint is reserved for match scores.
struct MatchRing: View {
    var value: Int          // 0…100
    var size: CGFloat = 44
    var lineWidth: CGFloat = 4
    var showsPercent: Bool = true

    var body: some View {
        ZStack {
            Circle().stroke(Color.hair, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(value) / 100)
                .stroke(Color.mint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(showsPercent ? "\(value)%" : "\(value)")
                .font(.movaMono(size * 0.28, medium: true))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(width: size, height: size)
        .animation(Motion.soft, value: value)
        .accessibilityElement()
        .accessibilityLabel("Match")
        .accessibilityValue("\(value) percent")
    }
}

// MARK: - Surfaces

extension View {
    /// Glass card over media: blur + dark tint + hairline.
    func glass(radius: CGFloat = Radius.card) -> some View {
        background(.ultraThinMaterial.opacity(0.9), in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .background(Color.ink.opacity(0.35), in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(Color.hair, lineWidth: 1))
            .environment(\.colorScheme, .dark)
    }

    /// Raised ink card on the app background.
    func raisedCard(radius: CGFloat = Radius.card) -> some View {
        background(Color.ink2, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(Color.white.opacity(0.06), lineWidth: 1))
    }
}

/// Top and bottom scrim so white text reads over photos.
struct MediaScrim: View {
    var top: Double = 0.55
    var bottom: Double = 0.85
    var body: some View {
        LinearGradient(stops: [
            .init(color: .black.opacity(top), location: 0),
            .init(color: .clear, location: 0.28),
            .init(color: .clear, location: 0.55),
            .init(color: .ink.opacity(bottom), location: 1),
        ], startPoint: .top, endPoint: .bottom)
        .allowsHitTesting(false)
    }
}

// MARK: - Buttons

/// Coral pill. One per screen.
struct PrimaryButtonStyle: ButtonStyle {
    var fullWidth = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.mova(17, .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 54)
            .background(Color.coral, in: Capsule())
            .shadow(color: .coral.opacity(0.35), radius: 16, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(Motion.snappy, value: configuration.isPressed)
    }
}

/// Quiet secondary action on dark surfaces.
struct SecondaryButtonStyle: ButtonStyle {
    var fullWidth = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.mova(16, .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 50)
            .background(Color.white.opacity(configuration.isPressed ? 0.16 : 0.1), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Motion.snappy, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var movaPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func movaPrimary(fullWidth: Bool) -> PrimaryButtonStyle { PrimaryButtonStyle(fullWidth: fullWidth) }
}
extension ButtonStyle where Self == SecondaryButtonStyle {
    static var movaSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
    static func movaSecondary(fullWidth: Bool) -> SecondaryButtonStyle { SecondaryButtonStyle(fullWidth: fullWidth) }
}

/// 44pt round glass icon button (close, flash, back, share…).
struct CircleIconButton: View {
    var glyph: Ph
    var label: String
    var size: CGFloat = 44
    var tint: Color? = nil
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Icon(glyph, size: size * 0.45, color: tint)
                .frame(width: size, height: size)
                .glass(radius: size / 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

// MARK: - Chips

struct Chip: View {
    var text: String
    var glyph: Ph? = nil
    var tint: Color = .white
    var background: Color = .white.opacity(0.1)

    var body: some View {
        HStack(spacing: 6) {
            if let glyph { Icon(glyph, .fill, size: 13, color: tint) }
            Text(text).font(.mova(12, .semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .frame(height: 26)
        .background(background, in: Capsule())
    }
}

// MARK: - Segmented control (white selected pill — coral stays for the primary action)

struct SegmentedPill<Value: Hashable>: View {
    var options: [Value]
    @Binding var selection: Value
    var label: (Value) -> String
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let on = option == selection
                Button {
                    Haptics.select()
                    withAnimation(Motion.snappy) { selection = option }
                } label: {
                    Text(label(option))
                        .font(.mova(14, .semibold))
                        .foregroundStyle(on ? Color.ink : Color.w72)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background {
                            if on { Capsule().fill(.white).matchedGeometryEffect(id: "pill", in: ns) }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Color.ink2, in: Capsule())
    }
}

// MARK: - Toggle (white track when on; mint is reserved for match)

struct MovaToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            Haptics.select()
            withAnimation(Motion.snappy) { configuration.isOn.toggle() }
        } label: {
            HStack {
                configuration.label
                Spacer(minLength: 12)
                Capsule()
                    .fill(configuration.isOn ? Color.white : Color.white.opacity(0.16))
                    .frame(width: 50, height: 30)
                    .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                        Circle().fill(configuration.isOn ? Color.ink : Color.white)
                            .padding(3)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityValue(configuration.isOn ? "On" : "Off")
    }
}

// MARK: - Tab bar

enum MainTab: Hashable { case studio, library, edit, you }

struct MainTabBar: View {
    @Binding var selection: MainTab
    var onCamera: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            tab(.studio, .house, "Studio")
            tab(.library, .squaresFour, "Library")
            Button {
                Haptics.tap()
                onCamera()
            } label: {
                Icon(.camera, .bold, size: 26)
                    .frame(width: 60, height: 60)
                    .background(Color.coral, in: Circle())
                    .shadow(color: .coral.opacity(0.4), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open camera")
            .frame(maxWidth: .infinity)
            .offset(y: -10)
            tab(.edit, .filmSlate, "Edit")
            tab(.you, .user, "You")
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .background(Color.ink.opacity(0.96).ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) { Rectangle().fill(Color.hair).frame(height: 1) }
    }

    private func tab(_ t: MainTab, _ glyph: Ph, _ title: String) -> some View {
        let on = selection == t
        return Button {
            Haptics.select()
            selection = t
        } label: {
            VStack(spacing: 4) {
                Icon(glyph, on ? .fill : .regular, size: 24, color: on ? .white : .w52)
                Text(title).font(.mova(11, .semibold)).foregroundStyle(on ? .white : .w52)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

// MARK: - Sample photos (real Unsplash photos bundled in Assets.xcassets/Samples)

struct SamplePhoto: View {
    var name: String
    var body: some View {
        // Fill whatever frame we're given without changing the layout size: an aspect-fill image
        // reports its own (wider) size, which pushed whole screens off the left edge.
        Color.clear
            .overlay {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

// MARK: - Screen header with back button and centered title

struct ScreenHeader<Trailing: View>: View {
    var eyebrow: String? = nil
    var title: String
    var onBack: (() -> Void)?
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: Space.s) {
            if let onBack {
                CircleIconButton(glyph: .caretLeft, label: "Back", action: onBack)
            }
            VStack(alignment: .leading, spacing: 2) {
                if let eyebrow { EyebrowText(eyebrow) }
                Text(title).font(.movaH2).foregroundStyle(.white).lineLimit(1)
            }
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.horizontal, Space.gutter)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(eyebrow: String? = nil, title: String, onBack: (() -> Void)?) {
        self.init(eyebrow: eyebrow, title: title, onBack: onBack) { EmptyView() }
    }
}
