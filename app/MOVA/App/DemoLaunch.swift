import SwiftUI
import MovaCore

#if DEBUG
/// Debug-only: open the app straight on one screen, for screenshots and design review.
///   xcrun simctl launch <device> space.playlocal.mova -MOVAScreen editor
/// Screens: welcome studio reference breakdown camera result editor export library settings
///          paywall exporting permission failed empty
enum DemoLaunch {
    static var screen: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-MOVAScreen"), i + 1 < args.count else { return nil }
        return args[i + 1]
    }

    /// Puts the model into the state for `screen`.
    @MainActor static func apply(_ screen: String, to model: AppModel) {
        switch screen {
        case "studio": model.tab = .studio
        case "reference": model.path = [.reference]
        case "breakdown": model.path = [.reference, .breakdown]
        case "camera": model.shotsCaptured = 0; model.showCamera = true
        case "result": model.path = [.result]
        case "editor": model.tab = .edit
        case "export": model.path = [.editor, .export]
        case "exporting": model.path = [.editor, .export, .exporting]
        case "library": model.tab = .library
        case "empty": model.library = []; model.tab = .library
        case "settings": model.tab = .you
        case "paywall": model.showPaywall = true
        case "failed": model.path = [.analysisFailed(.noCuts(seconds: 9))]
        default: break
        }
    }
}
#endif
