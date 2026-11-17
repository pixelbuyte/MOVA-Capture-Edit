import Foundation

/// How the camera moves during a shot.
public enum CameraMove: String, Codable, CaseIterable, Sendable {
    case lockedOff, dollyIn, dollyOut, panLeft, panRight, tiltUp, tiltDown, handheld

    public var label: String {
        switch self {
        case .lockedOff: "Locked off"
        case .dollyIn: "Dolly in"
        case .dollyOut: "Dolly out"
        case .panLeft: "Pan left"
        case .panRight: "Pan right"
        case .tiltUp: "Tilt up"
        case .tiltDown: "Tilt down"
        case .handheld: "Handheld"
        }
    }
}

/// How much of the subject is in frame.
public enum Framing: String, Codable, CaseIterable, Sendable {
    case wide, medium, closeUp, lowAngle

    public var label: String {
        switch self {
        case .wide: "Wide"
        case .medium: "Medium"
        case .closeUp: "Close-up"
        case .lowAngle: "Low angle"
        }
    }
}

/// One shot detected in a reference clip.
public struct Shot: Identifiable, Codable, Hashable, Sendable {
    public var id: Int { number }
    public var number: Int
    public var name: String
    public var framing: Framing
    public var move: CameraMove
    /// Duration in seconds.
    public var duration: Double

    public init(number: Int, name: String, framing: Framing, move: CameraMove, duration: Double) {
        precondition(duration > 0, "A shot must have a positive duration")
        self.number = number
        self.name = name
        self.framing = framing
        self.move = move
        self.duration = duration
    }
}

/// The ordered shots of a reference clip, as detected (and possibly edited by the user).
public struct ShotPlan: Codable, Hashable, Sendable {
    public var title: String
    public var shots: [Shot]
    /// True while the plan is exactly what analysis produced; false once the user adjusts it.
    public var isAutoDetected: Bool

    public init(title: String, shots: [Shot], isAutoDetected: Bool = true) {
        self.title = title
        self.shots = shots
        self.isAutoDetected = isAutoDetected
    }

    public var totalDuration: Double { shots.reduce(0) { $0 + $1.duration } }

    /// Start time of each shot, in seconds from the beginning of the clip.
    public var startTimes: [Double] {
        var t = 0.0
        return shots.map { s in defer { t += s.duration }; return t }
    }

    /// Times of the cuts between shots (excludes 0 and the end).
    public var cutTimes: [Double] { Array(startTimes.dropFirst()) }

    /// Each shot's share of the total duration, for drawing the segmented shot bar.
    public var fractions: [Double] {
        let total = totalDuration
        guard total > 0 else { return [] }
        return shots.map { $0.duration / total }
    }

    /// The shot playing at time `t` (clamped to the clip).
    public func shotIndex(at t: Double) -> Int {
        guard !shots.isEmpty else { return 0 }
        let starts = startTimes
        let clamped = min(max(t, 0), totalDuration)
        return (starts.lastIndex { $0 <= clamped } ?? 0)
    }

    /// Splits shot `index` at `offset` seconds into it. Returns false if the split point is not strictly inside the shot.
    @discardableResult
    public mutating func split(shotAt index: Int, offset: Double) -> Bool {
        guard shots.indices.contains(index) else { return false }
        let s = shots[index]
        guard offset > 0, offset < s.duration else { return false }
        let first = Shot(number: 0, name: s.name, framing: s.framing, move: s.move, duration: offset)
        let second = Shot(number: 0, name: s.name + " (2)", framing: s.framing, move: s.move, duration: s.duration - offset)
        shots.replaceSubrange(index...index, with: [first, second])
        renumber()
        isAutoDetected = false
        return true
    }

    /// Merges shot `index` with the one after it.
    @discardableResult
    public mutating func merge(shotAt index: Int) -> Bool {
        guard shots.indices.contains(index), shots.indices.contains(index + 1) else { return false }
        let a = shots[index], b = shots[index + 1]
        shots.replaceSubrange(index...(index + 1), with: [Shot(number: 0, name: a.name, framing: a.framing, move: a.move, duration: a.duration + b.duration)])
        renumber()
        isAutoDetected = false
        return true
    }

    private mutating func renumber() {
        for i in shots.indices { shots[i].number = i + 1 }
    }
}
