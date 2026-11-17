import SwiftUI
import PhosphorSwift

/// Every icon in MOVA goes through this view so the icon set lives in one place.
/// Uses Phosphor (github.com/phosphor-icons/swift), matching the v5 designs:
/// regular weight for UI, fill for selected tabs and play, bold inside coral buttons.
struct Icon: View {
    enum Weight { case regular, bold, fill, duotone }

    let glyph: Ph
    var weight: Weight = .regular
    var size: CGFloat = 22
    var color: Color? = nil

    init(_ glyph: Ph, _ weight: Weight = .regular, size: CGFloat = 22, color: Color? = nil) {
        self.glyph = glyph
        self.weight = weight
        self.size = size
        self.color = color
    }

    var body: some View {
        image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color ?? .white)
            .accessibilityHidden(true)
    }

    private var image: Image {
        switch weight {
        case .regular: glyph.regular
        case .bold: glyph.bold
        case .fill: glyph.fill
        case .duotone: glyph.duotone
        }
    }
}
