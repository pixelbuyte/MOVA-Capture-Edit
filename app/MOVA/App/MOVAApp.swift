import SwiftUI

@main
struct MOVAApp: App {
    @State private var model: AppModel
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    private let demoScreen: String?

    init() {
        let m = AppModel()
        #if DEBUG
        demoScreen = DemoLaunch.screen
        if let s = demoScreen { DemoLaunch.apply(s, to: m) }
        #else
        demoScreen = nil
        #endif
        _model = State(initialValue: m)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if demoScreen == "permission" {
                    CameraPermissionView(onAllow: {}, onClose: {})                      // 13
                } else if demoScreen == "welcome" {
                    WelcomeView {}                                                     // 02
                } else if hasOnboarded || demoScreen != nil {
                    RootView()
                } else {
                    WelcomeView { withAnimation(Motion.soft) { hasOnboarded = true } }   // 02
                }
            }
            .environment(model)
            .preferredColorScheme(.dark)
            .tint(.coral)
        }
    }
}

/// Tabs + one navigation stack for the recreation flow. The camera is a full-screen cover.
struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        NavigationStack(path: $model.path) {
            tabContent
                .navigationDestination(for: Route.self) { route in
                    destination(route)
                        .toolbar(.hidden, for: .navigationBar)
                }
                .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(isPresented: $model.showCamera) { CameraView() }   // 01 (+13 when access is off)
        .sheet(isPresented: $model.showPaywall) { PaywallView() }           // 11
        .background(Color.ink.ignoresSafeArea())
    }

    @ViewBuilder private var tabContent: some View {
        @Bindable var model = model
        ZStack(alignment: .bottom) {
            Color.ink.ignoresSafeArea()
            switch model.tab {
            case .studio: StudioView()                                         // 03
            case .library: LibraryView()                                       // 09 / 15
            case .edit: EditorView()                                           // 07
            case .you: SettingsView()                                          // 10
            }
            MainTabBar(selection: $model.tab) { model.startRecreation() }
        }
    }

    @ViewBuilder private func destination(_ route: Route) -> some View {
        switch route {
        case .reference: ReferenceView()                                       // 04
        case .breakdown: BreakdownView()                                       // 05
        case .result: ResultView()                                             // 06
        case .editor: EditorView()                                             // 07
        case .export: ExportView()                                             // 08
        case .exporting: ExportingView()                                       // 12
        case .analysisFailed(let error): AnalysisFailedView(error: error)      // 14
        }
    }
}
