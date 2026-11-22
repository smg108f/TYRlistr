import SwiftUI
#if os(macOS)
import AppKit
#endif

@main
struct TYRlistrApp: App {
    init() {
        #if os(macOS)
        // Running from `swift run` starts as a background process; promote it to a normal app window.
        // A packaged .app (see scripts/package-macos.sh) already launches as a regular app.
        if Bundle.main.bundleURL.pathExtension != "app" {
            DispatchQueue.main.async {
                NSApplication.shared.setActivationPolicy(.regular)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup("TYRlistr") {
            root
        }
    }

    @ViewBuilder private var root: some View {
        #if os(macOS)
        ContentView().frame(minWidth: 900, minHeight: 720)
        #else
        ContentView()
        #endif
    }
}
