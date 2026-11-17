import SwiftUI
import Observation
import MovaCore

/// Screens pushed on the main navigation stack.
enum Route: Hashable {
    case reference          // 04
    case breakdown          // 05
    case result             // 06
    case editor             // 07 (also the Edit tab root)
    case export             // 08
    case exporting          // 12
    case analysisFailed(AnalysisError)  // 14
}

/// A colour look applied to footage in the editor (07). Pure SwiftUI colour adjustments for now.
struct Look: Identifiable, Hashable {
    let id: String
    let name: String
    var saturation: Double = 1
    var contrast: Double = 1
    var brightness: Double = 0
    var hue: Double = 0          // degrees
    var tint: Color = .white     // colorMultiply

    static let all: [Look] = [
        Look(id: "original", name: "Original"),
        Look(id: "golden", name: "Golden", saturation: 1.15, contrast: 1.05, brightness: 0.02, tint: Color(hex: 0xFFE7C2)),
        Look(id: "coast", name: "Coast", saturation: 1.05, contrast: 1.05, hue: -8, tint: Color(hex: 0xD8F1F2)),
        Look(id: "film", name: "Film", saturation: 0.85, contrast: 1.15, brightness: -0.02, tint: Color(hex: 0xF4E6D2)),
        Look(id: "dusk", name: "Dusk", saturation: 1.1, contrast: 1.1, brightness: -0.06, hue: 10, tint: Color(hex: 0xFFD3C4)),
        Look(id: "mono", name: "Mono", saturation: 0, contrast: 1.2),
    ]
}

extension View {
    func look(_ look: Look) -> some View {
        self.saturation(look.saturation)
            .contrast(look.contrast)
            .brightness(look.brightness)
            .hueRotation(.degrees(look.hue))
            .colorMultiply(look.tint)
    }
}

struct LibraryItem: Identifiable, Hashable {
    enum Kind: Hashable { case recreation(shots: Int, score: Int), video, photo }
    let id = UUID()
    var photo: String
    var title: String
    var caption: String
    var duration: Double?
    var kind: Kind

    var isRecreation: Bool {
        if case .recreation = kind { return true }
        return false
    }
}

/// App-wide state. One instance, injected into the environment.
@Observable
final class AppModel {
    // Navigation
    var tab: MainTab = .studio
    var path: [Route] = []
    var showCamera = false
    var showPaywall = false

    // Current recreation
    var plan: ShotPlan = Samples.courtPlan
    var beat: BeatMap = Samples.courtBeat
    var score: MatchScore = Samples.courtScore
    /// Shots captured so far in the camera (0…plan.shots.count).
    var shotsCaptured = 0
    var takes: [URL] = []

    // Editor / export
    var look: Look = Look.all[1]
    var exportSettings = ExportSettings()
    var exportProgress: Double = 0

    // Account / settings (persisted where it matters)
    var isPro = false
    var name = "Maya"
    var library: [LibraryItem] = LibraryItem.samples
    var defaultResolution: ExportResolution = .uhd4k
    var defaultFrameRate: ExportFrameRate = .fps30
    var showsGrid = false
    var guideGhostOn = true
    var voiceTips = true
    var haptics = true

    let analyzer: any ClipAnalyzing

    init(analyzer: any ClipAnalyzing = MockClipAnalyzer()) {
        self.analyzer = analyzer
    }

    // MARK: Flow actions

    func open(_ route: Route) { path.append(route) }
    func back() { if !path.isEmpty { path.removeLast() } }
    func popToRoot() { path.removeAll() }

    func startRecreation() {
        shotsCaptured = 0
        takes = []
        showCamera = true
    }

    /// Called by the camera when a shot finishes recording.
    func captured(take url: URL?) {
        if let url { takes.append(url) }
        shotsCaptured = min(shotsCaptured + 1, plan.shots.count)
    }

    var allShotsCaptured: Bool { shotsCaptured >= plan.shots.count }

    /// Analyze a pasted link; pushes Reference on success, or the failure screen.
    @MainActor
    func analyze(link: String) async {
        do {
            let result = try await analyzer.analyze(link: link)
            plan = result.plan
            beat = result.beat
            open(.reference)
        } catch let error as AnalysisError {
            open(.analysisFailed(error))
        } catch {
            open(.analysisFailed(.unreachable))
        }
    }
}

extension LibraryItem {
    static let samples: [LibraryItem] = [
        LibraryItem(photo: "fashion_yellow", title: "Seaside recreate", caption: "Recreation · 4 shots", duration: 9, kind: .recreation(shots: 4, score: 91)),
        LibraryItem(photo: "road", title: "Canyon road", caption: "Yesterday", duration: 12, kind: .video),
        LibraryItem(photo: "beach", title: "Low tide", caption: "Recreation · 3 shots", duration: 7, kind: .recreation(shots: 3, score: 84)),
        LibraryItem(photo: "cinema", title: "Central Cinema", caption: "Photo", duration: nil, kind: .photo),
        LibraryItem(photo: "port_red2", title: "Red room", caption: "Recreation · 5 shots", duration: 11, kind: .recreation(shots: 5, score: 78)),
        LibraryItem(photo: "hoodie", title: "Rooftop", caption: "Photo", duration: nil, kind: .photo),
    ]
}
