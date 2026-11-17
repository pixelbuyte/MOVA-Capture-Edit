import Foundation

/// How closely a take matches its reference, 0–100 per dimension.
public struct MatchScore: Codable, Hashable, Sendable {
    public enum Dimension: String, CaseIterable, Codable, Sendable {
        case framing, cameraMove, color, timing

        public var label: String {
            switch self {
            case .framing: "Framing"
            case .cameraMove: "Camera move"
            case .color: "Color"
            case .timing: "Timing"
            }
        }
    }

    public var framing: Int
    public var cameraMove: Int
    public var color: Int
    public var timing: Int

    public init(framing: Int, cameraMove: Int, color: Int, timing: Int) {
        self.framing = Self.clamp(framing)
        self.cameraMove = Self.clamp(cameraMove)
        self.color = Self.clamp(color)
        self.timing = Self.clamp(timing)
    }

    public func value(_ d: Dimension) -> Int {
        switch d {
        case .framing: framing
        case .cameraMove: cameraMove
        case .color: color
        case .timing: timing
        }
    }

    /// Equal-weight average, rounded half up.
    public var overall: Int {
        let sum = Dimension.allCases.reduce(0) { $0 + value($1) }
        return Int((Double(sum) / Double(Dimension.allCases.count)).rounded())
    }

    /// The dimension that most needs work (lowest score; ties go to the earlier dimension).
    public var weakest: Dimension {
        Dimension.allCases.min { value($0) < value($1) } ?? .framing
    }

    /// Plain-language headline for the result screen.
    public var headline: String {
        switch overall {
        case 90...: "Nailed it."
        case 80..<90: "Close. One fix left."
        case 65..<80: "Getting there."
        default: "Let's try that again."
        }
    }

    private static func clamp(_ v: Int) -> Int { min(max(v, 0), 100) }
}

/// Live framing match while shooting: how far the subject box is from the reference box.
public struct FramingBox: Equatable, Sendable {
    /// Normalized 0…1 coordinates in the frame.
    public var x: Double, y: Double, width: Double, height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x; self.y = y; self.width = width; self.height = height
    }

    public var area: Double { max(width, 0) * max(height, 0) }

    /// Intersection over union with another box, 0…1.
    public func iou(_ o: FramingBox) -> Double {
        let ix = max(0, min(x + width, o.x + o.width) - max(x, o.x))
        let iy = max(0, min(y + height, o.y + o.height) - max(y, o.y))
        let inter = ix * iy
        let union = area + o.area - inter
        return union > 0 ? inter / union : 0
    }

    /// One coaching tip that moves the subject toward `target`. Size is checked first, then position.
    public func tip(toward target: FramingBox) -> String? {
        let scale = height / max(target.height, 0.0001)
        if scale < 0.9 { return "One step closer" }
        if scale > 1.1 { return "Step back a little" }
        let dx = (x + width / 2) - (target.x + target.width / 2)
        if dx > 0.06 { return "Move a little left" }
        if dx < -0.06 { return "Move a little right" }
        return nil
    }
}
