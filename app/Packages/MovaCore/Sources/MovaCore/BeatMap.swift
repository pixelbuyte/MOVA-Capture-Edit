import Foundation

/// A steady beat grid: `bpm` beats per minute, first beat at `firstBeat` seconds.
public struct BeatMap: Codable, Hashable, Sendable {
    public var bpm: Double
    public var firstBeat: Double

    public init(bpm: Double, firstBeat: Double = 0) {
        precondition(bpm > 0, "BPM must be positive")
        self.bpm = bpm
        self.firstBeat = firstBeat
    }

    /// Seconds between beats.
    public var interval: Double { 60 / bpm }

    /// All beat times in `0...duration`.
    public func beats(upTo duration: Double) -> [Double] {
        guard duration >= firstBeat else { return [] }
        let count = Int(((duration - firstBeat) / interval).rounded(.down)) + 1
        return (0..<count).map { firstBeat + Double($0) * interval }
    }

    /// Fractional beat position of time `t` (beat 0 = firstBeat).
    public func beatPosition(of t: Double) -> Double { (t - firstBeat) / interval }

    /// Nearest beat time to `t`.
    public func nearestBeat(to t: Double) -> Double {
        firstBeat + beatPosition(of: t).rounded() * interval
    }

    /// Signed offset of `t` from its nearest beat, in beats. Negative = early, positive = late.
    public func offsetInBeats(_ t: Double) -> Double {
        let p = beatPosition(of: t)
        return p - p.rounded()
    }

    /// Moves `t` onto the nearest beat (what the editor's Beat sync does to a cut).
    public func snap(_ t: Double) -> Double { nearestBeat(to: t) }
}

/// How a take's cut lines up with the reference cut.
public struct CutTiming: Equatable, Sendable {
    public let shotNumber: Int
    /// Signed difference, in beats: negative means the take cuts early.
    public let beats: Double

    public init(shotNumber: Int, beats: Double) {
        self.shotNumber = shotNumber
        self.beats = beats
    }

    /// Within a quarter beat counts as on time.
    public var isOnTime: Bool { abs(beats) < 0.25 }

    /// Short coaching line, e.g. "Starts half a beat early".
    public var coaching: String {
        if isOnTime { return "Lands on the beat" }
        let size: String
        switch abs(beats) {
        case ..<0.375: size = "a quarter beat"
        case ..<0.75: size = "half a beat"
        case ..<1.5: size = "a beat"
        default: size = "\(Int(abs(beats).rounded())) beats"
        }
        return "Starts \(size) \(beats < 0 ? "early" : "late")"
    }
}

public extension BeatMap {
    /// Compares where each shot of a take starts against the reference plan.
    func cutTimings(reference: ShotPlan, take: ShotPlan) -> [CutTiming] {
        let ref = reference.startTimes, mine = take.startTimes
        return zip(ref, mine).enumerated().dropFirst().map { i, pair in
            CutTiming(shotNumber: i + 1, beats: (pair.1 - pair.0) / interval)
        }
    }
}
