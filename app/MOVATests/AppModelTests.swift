import XCTest
import MovaCore
@testable import MOVA

@MainActor
final class AppModelTests: XCTestCase {
    func testCaptureFlowAdvancesAndStopsAtShotCount() {
        let model = AppModel()
        model.startRecreation()
        XCTAssertTrue(model.showCamera)
        XCTAssertEqual(model.shotsCaptured, 0)
        for _ in 0..<6 { model.captured(take: nil) }
        XCTAssertEqual(model.shotsCaptured, model.plan.shots.count)
        XCTAssertTrue(model.allShotsCaptured)
    }

    func testNavigation() {
        let model = AppModel()
        model.open(.reference)
        model.open(.breakdown)
        XCTAssertEqual(model.path, [.reference, .breakdown])
        model.back()
        XCTAssertEqual(model.path, [.reference])
        model.popToRoot()
        XCTAssertTrue(model.path.isEmpty)
    }

    func testAnalyzeSuccessOpensReference() async {
        let model = AppModel(analyzer: MockClipAnalyzer(delay: .zero))
        await model.analyze(link: "https://example.com/clip")
        XCTAssertEqual(model.path, [.reference])
    }

    func testAnalyzeFailuresOpenFailureScreen() async {
        let model = AppModel(analyzer: MockClipAnalyzer(delay: .zero))
        await model.analyze(link: "https://example.com/private-clip")
        XCTAssertEqual(model.path, [.analysisFailed(.privateClip)])

        model.popToRoot()
        await model.analyze(link: "not a link")
        XCTAssertEqual(model.path, [.analysisFailed(.unreachable)])
    }

    func testEveryAnalysisErrorHasCopy() {
        let errors: [AnalysisError] = [.privateClip, .tooShort(seconds: 1.8), .noCuts(seconds: 9), .offline, .unreachable]
        for e in errors {
            XCTAssertFalse(e.title.isEmpty)
            XCTAssertFalse(e.detail.isEmpty)
        }
    }
}
