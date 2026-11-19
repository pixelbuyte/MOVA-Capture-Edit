import SwiftUI
import UIKit

// MARK: - Color tokens (from design/v5: coral is the single brand hue, mint is match only)

extension Color {
    static let ink = Color(hex: 0x0E1116)        // app background
    static let ink2 = Color(hex: 0x1B2028)       // raised cards, trays
    static let paper = Color(hex: 0xF4EEE3)
    static let coral = Color(hex: 0xFF5A36)      // brand, primary action, reference, recording
    static let coralDeep = Color(hex: 0xE2401D)
    static let mint = Color(hex: 0x3DF0A8)       // match score only
    static let sun = Color(hex: 0xFFC53D)        // beat, timing, caution
    static let lagoon = Color(hex: 0x1F8A9E)     // rare accent (audio waveform)
    static let w72 = Color.white.opacity(0.72)   // secondary text
    static let w52 = Color.white.opacity(0.52)   // tertiary text, labels
    static let hair = Color.white.opacity(0.14)  // hairlines, inactive segments

    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

// MARK: - Type

enum MovaFont {
    static let display = "Bricolage Grotesque"
    static let mono = "DM Mono"

    /// True once the bundled fonts are registered (UIAppFonts in Info.plist).
    static var isAvailable: Bool { UIFont(name: "DMMono-Regular", size: 12) != nil }
}

extension Font {
    /// Display / UI face. Falls back to the system font if the bundle font is missing.
    static func mova(_ size: CGFloat, _ weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        guard MovaFont.isAvailable else { return .system(size: size, weight: weight) }
        return .custom(MovaFont.display, size: size, relativeTo: style).weight(weight)
    }

    /// Mono face for numbers, timecodes and small caps labels.
    static func movaMono(_ size: CGFloat, medium: Bool = false) -> Font {
        guard MovaFont.isAvailable else { return .system(size: size, weight: medium ? .medium : .regular, design: .monospaced) }
        return .custom(medium ? "DMMono-Medium" : "DMMono-Regular", size: size, relativeTo: .caption)
    }

    // Scale used across the designs.
    static let movaTitle = Font.mova(34, .bold, relativeTo: .largeTitle)
    static let movaH1 = Font.mova(26, .bold, relativeTo: .title)
    static let movaH2 = Font.mova(20, .semibold, relativeTo: .title3)
    static let movaBody = Font.mova(16, .medium)
    static let movaCallout = Font.mova(14, .regular, relativeTo: .callout)
    static let movaCaption = Font.mova(12, .medium, relativeTo: .caption)
}

/// Small uppercase mono label, e.g. "SHOT 1 OF 4 · 3.2S".
struct EyebrowText: View {
    var text: String
    var color: Color = .w52
    init(_ text: String, color: Color = .w52) { self.text = text; self.color = color }
    var body: some View {
        Text(text.uppercased())
            .font(.movaMono(12, medium: true))
            .tracking(1.2)
            .foregroundStyle(color)
    }
}

// MARK: - Spacing and radius

enum Space {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 20
    static let xl: CGFloat = 28
    static let xxl: CGFloat = 40
    /// Side gutter for screens.
    static let gutter: CGFloat = 20
}

enum Radius {
    static let chip: CGFloat = 12
    static let control: CGFloat = 16
    static let card: CGFloat = 20
    static let media: CGFloat = 26
}

// MARK: - Motion

enum Motion {
    static let snappy = Animation.spring(response: 0.32, dampingFraction: 0.82)
    static let soft = Animation.spring(response: 0.5, dampingFraction: 0.86)
    static let push = Animation.easeOut(duration: 0.26)
}

// MARK: - Haptics

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func select() { UISelectionFeedbackGenerator().selectionChanged() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}
