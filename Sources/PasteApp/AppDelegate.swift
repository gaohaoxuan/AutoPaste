import AppKit
import SwiftUI
import ServiceManagement
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let manager = ClipboardManager()
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        manager.startSync()
        try? SMAppService.mainApp.register()
    }
    func applicationWillTerminate(_ notification: Notification) {
        manager.stop()
    }
}
