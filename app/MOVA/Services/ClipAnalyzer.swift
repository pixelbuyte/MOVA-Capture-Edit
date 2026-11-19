import Foundation
import MovaCore

/// Why a reference clip could not be broken into shots (screen 14).
enum AnalysisError: Error, Hashable {
    case privateClip
    case tooShort(seconds: Double)
    case noCuts(seconds: Double)
    case offline
    case unreachable

    var title: String {
        switch self {
        case .privateClip: "This clip is private"
        case .tooShort: "This clip is too short"
        case .noCuts: "No cuts to split"
        case .offline: "You're offline"
        case .unreachable: "Couldn't open this link"
        }
    }

    var detail: String {
        switch self {
        case .privateClip:
            "MOVA can only read clips anyone can watch. Ask the creator to make it public, or save it to Photos and pick it from there."
        case .tooShort(let s):
            "It runs \(String(format: "%.1f", s))s. MOVA needs at least 3 seconds to find shots."
        case .noCuts(let s):
            "The clip runs \(String(format: "%.1f", s))s without a cut. MOVA needs at least two shots to coach you through."
        case .offline:
            "Links need a connection. Clips from Photos still work offline."
        case .unreachable:
            "Check the link and try again, or pick the clip from Photos."
        }
    }
}

struct AnalysisResult: Sendable {
    var plan: ShotPlan
    var beat: BeatMap
}

/// Turns a reference clip into a shot plan. The real implementation (on-device video analysis
/// or a backend) plugs in here; the app only depends on this protocol.
protocol ClipAnalyzing: Sendable {
    func analyze(link: String) async throws -> AnalysisResult
    func analyze(fileURL: URL) async throws -> AnalysisResult
}

/// Stand-in analyzer used until the real one exists. Returns the sample plan after a short delay,
/// and returns specific failures for test links so every state can be exercised:
/// links containing "private", "short", "nocuts" or "offline".
struct MockClipAnalyzer: ClipAnalyzing {
    var delay: Duration = .milliseconds(900)

    func analyze(link: String) async throws -> AnalysisResult {
        try await Task.sleep(for: delay)
        let l = link.lowercased()
        if l.contains("private") { throw AnalysisError.privateClip }
        if l.contains("short") { throw AnalysisError.tooShort(seconds: 1.8) }
        if l.contains("nocuts") { throw AnalysisError.noCuts(seconds: 9.0) }
        if l.contains("offline") { throw AnalysisError.offline }
        guard l.hasPrefix("http") || l.isEmpty else { throw AnalysisError.unreachable }
        return AnalysisResult(plan: Samples.courtPlan, beat: Samples.courtBeat)
    }

    func analyze(fileURL: URL) async throws -> AnalysisResult {
        try await Task.sleep(for: delay)
        return AnalysisResult(plan: Samples.courtPlan, beat: Samples.courtBeat)
    }
}
