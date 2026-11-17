import Foundation

/// Example content used by previews and by the mock analyzer, matching the v5 designs.
public enum Samples {
    public static let courtPlan = ShotPlan(title: "Yellow on the court", shots: [
        Shot(number: 1, name: "Wide approach", framing: .wide, move: .dollyIn, duration: 3.2),
        Shot(number: 2, name: "Hoodie close-up", framing: .closeUp, move: .lockedOff, duration: 1.8),
        Shot(number: 3, name: "Boots to face", framing: .lowAngle, move: .tiltUp, duration: 2.4),
        Shot(number: 4, name: "Hoop reveal", framing: .medium, move: .panLeft, duration: 1.6),
    ])

    /// 100 BPM with the first beat at 0.2 s: the cuts at 3.2, 5.0 and 7.4 s land on beats.
    public static let courtBeat = BeatMap(bpm: 100, firstBeat: 0.2)

    public static let courtScore = MatchScore(framing: 91, cameraMove: 88, color: 82, timing: 71)
}
