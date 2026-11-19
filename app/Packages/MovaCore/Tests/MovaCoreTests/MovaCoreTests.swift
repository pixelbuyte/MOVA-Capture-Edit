import XCTest
@testable import MovaCore

final class ShotPlanTests: XCTestCase {
    let plan = Samples.courtPlan

    func testTotalsAndCuts() {
        XCTAssertEqual(plan.totalDuration, 9.0, accuracy: 1e-9)
        for (got, want) in zip(plan.startTimes, [0, 3.2, 5.0, 7.4]) {
            XCTAssertEqual(got, want, accuracy: 1e-9)
        }
        XCTAssertEqual(plan.cutTimes.count, 3)
        XCTAssertEqual(plan.fractions.reduce(0, +), 1, accuracy: 1e-9)
    }

    func testShotIndexAtTime() {
        XCTAssertEqual(plan.shotIndex(at: 0), 0)
        XCTAssertEqual(plan.shotIndex(at: 3.19), 0)
        XCTAssertEqual(plan.shotIndex(at: 3.2), 1)
        XCTAssertEqual(plan.shotIndex(at: 8.9), 3)
        XCTAssertEqual(plan.shotIndex(at: 99), 3, "clamped to last shot")
        XCTAssertEqual(plan.shotIndex(at: -1), 0, "clamped to first shot")
    }

    func testSplitAndMergeRenumberAndMarkEdited() {
        var p = plan
        XCTAssertTrue(p.split(shotAt: 0, offset: 1.0))
        XCTAssertEqual(p.shots.count, 5)
        XCTAssertEqual(p.shots.map(\.number), [1, 2, 3, 4, 5])
        XCTAssertEqual(p.totalDuration, 9.0, accuracy: 1e-9)
        XCTAssertFalse(p.isAutoDetected)

        XCTAssertTrue(p.merge(shotAt: 0))
        XCTAssertEqual(p.shots.count, 4)
        XCTAssertEqual(p.shots[0].duration, 3.2, accuracy: 1e-9)
    }

    func testInvalidSplitAndMergeAreRejected() {
        var p = plan
        XCTAssertFalse(p.split(shotAt: 0, offset: 0))
        XCTAssertFalse(p.split(shotAt: 0, offset: 3.2))
        XCTAssertFalse(p.split(shotAt: 9, offset: 1))
        XCTAssertFalse(p.merge(shotAt: 3))
        XCTAssertEqual(p, plan)
    }
}

final class BeatMapTests: XCTestCase {
    let beat = Samples.courtBeat

    func testSampleCutsLandOnBeats() {
        for cut in Samples.courtPlan.cutTimes {
            XCTAssertEqual(beat.offsetInBeats(cut), 0, accuracy: 1e-9, "cut at \(cut)")
        }
    }

    func testBeatsAndSnap() {
        XCTAssertEqual(beat.interval, 0.6, accuracy: 1e-9)
        XCTAssertEqual(beat.beats(upTo: 9).count, 15)
        XCTAssertEqual(beat.snap(5.2), 5.0, accuracy: 1e-9)
        XCTAssertEqual(beat.snap(5.35), 5.6, accuracy: 1e-9)
    }

    func testHalfBeatEarlyCoaching() {
        var take = Samples.courtPlan
        // Shot 2 runs 0.3 s short, so shot 3 starts half a beat early.
        take.shots[1].duration -= 0.3
        take.shots[2].duration += 0.3
        let timings = beat.cutTimings(reference: Samples.courtPlan, take: take)
        XCTAssertEqual(timings.map(\.shotNumber), [2, 3, 4])
        XCTAssertTrue(timings[0].isOnTime)
        XCTAssertEqual(timings[1].beats, -0.5, accuracy: 1e-9)
        XCTAssertEqual(timings[1].coaching, "Starts half a beat early")
        XCTAssertTrue(timings[2].isOnTime)
    }

    func testCoachingWording() {
        XCTAssertEqual(CutTiming(shotNumber: 2, beats: 0.1).coaching, "Lands on the beat")
        XCTAssertEqual(CutTiming(shotNumber: 2, beats: 0.3).coaching, "Starts a quarter beat late")
        XCTAssertEqual(CutTiming(shotNumber: 2, beats: -1).coaching, "Starts a beat early")
        XCTAssertEqual(CutTiming(shotNumber: 2, beats: 2.2).coaching, "Starts 2 beats late")
    }
}

final class MatchScoreTests: XCTestCase {
    func testSampleScore() {
        let s = Samples.courtScore
        XCTAssertEqual(s.overall, 83)
        XCTAssertEqual(s.weakest, .timing)
        XCTAssertEqual(s.headline, "Close. One fix left.")
    }

    func testClamping() {
        let s = MatchScore(framing: 120, cameraMove: -5, color: 50, timing: 50)
        XCTAssertEqual(s.framing, 100)
        XCTAssertEqual(s.cameraMove, 0)
    }

    func testFramingIoUAndTips() {
        let target = FramingBox(x: 0.3, y: 0.2, width: 0.4, height: 0.7)
        XCTAssertEqual(target.iou(target), 1, accuracy: 1e-9)
        XCTAssertEqual(target.iou(FramingBox(x: 0.9, y: 0.9, width: 0.05, height: 0.05)), 0)

        let small = FramingBox(x: 0.35, y: 0.3, width: 0.3, height: 0.55)
        XCTAssertEqual(small.tip(toward: target), "One step closer")
        let big = FramingBox(x: 0.25, y: 0.1, width: 0.5, height: 0.85)
        XCTAssertEqual(big.tip(toward: target), "Step back a little")
        let right = FramingBox(x: 0.4, y: 0.2, width: 0.4, height: 0.7)
        XCTAssertEqual(right.tip(toward: target), "Move a little left")
        XCTAssertNil(target.tip(toward: target))
    }
}

final class ExportTests: XCTestCase {
    func testEstimateGrowsWithResolutionAndFrameRate() {
        let hd = ExportSettings(resolution: .hd1080, frameRate: .fps30).estimatedMegabytes(duration: 9)
        let uhd = ExportSettings(resolution: .uhd4k, frameRate: .fps30).estimatedMegabytes(duration: 9)
        let uhd60 = ExportSettings(resolution: .uhd4k, frameRate: .fps60).estimatedMegabytes(duration: 9)
        XCTAssertLessThan(hd, uhd)
        XCTAssertLessThan(uhd, uhd60)
        XCTAssertEqual(uhd, 45)
    }

    func testSummaryAndSteps() {
        XCTAssertEqual(ExportSettings().summary, "HEVC · 2160 × 3840 · 30 fps")
        XCTAssertEqual(ExportStep.current(at: 0), .renderingClips)
        XCTAssertEqual(ExportStep.current(at: 0.64), .applyingLook)
        XCTAssertEqual(ExportStep.current(at: 0.75), .mixingAudio)
        XCTAssertEqual(ExportStep.current(at: 1), .saving)
    }

    func testTimecode() {
        XCTAssertEqual(timecode(5.8), "0:05.8")
        XCTAssertEqual(timecode(9), "0:09.0")
        XCTAssertEqual(timecode(65.25), "1:05.2")
    }
}
