import SwiftUI
@main
struct PasteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup { EmptyView() }
            .defaultSize(width: 0, height: 0)
            .windowResizability(.contentSize)
    }
}
