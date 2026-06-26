import AppKit
import SwiftUI
@MainActor
final class ClipboardWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let history: ClipboardHistory
    weak var manager: ClipboardManager?
    init(history: ClipboardHistory) { self.history = history; super.init() }
    func show() {
        if window == nil {
            let cv = ClipboardContentView(history: history,
                onDismiss: { [weak self] in self?.hide() },
                onSelect: { [weak self] i in self?.selectItem(i) },
                onDelete: { [weak self] i in self?.history.delete(i) },
                onPin: { [weak self] i in self?.history.togglePin(i) },
                onClearAll: { [weak self] in self?.history.clearAll() },
                onSettings: { [weak self] in self?.manager?.openSettings() })
            let hv = NSHostingView(rootView: cv)
            hv.frame = NSRect(x: 0, y: 0, width: .clipboardWindowWidth, height: .clipboardWindowMaxHeight)
            let w = NSPanel(contentRect: NSRect(x: 0, y: 0, width: .clipboardWindowWidth, height: .clipboardWindowMaxHeight),
                styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel], backing: .buffered, defer: false)
            w.titleVisibility = .hidden; w.level = .floating
            w.collectionBehavior = [.canJoinAllSpaces, .transient]; w.isReleasedWhenClosed = false; w.delegate = self
            w.contentView = hv; w.titlebarAppearsTransparent = true
            w.isOpaque = false; w.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.97)
            self.window = w
        }
        positionWindowNearMouse()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    func hide() { window?.orderOut(nil) }
    var isVisible: Bool { window?.isVisible ?? false }
    func toggle() { isVisible ? hide() : show() }
    private func selectItem(_ item: ClipboardItem) { NSPasteboard.general.restoreClipboard(item: item); hide() }
    private func positionWindowNearMouse() {
        guard let w = window else { return }
        let ml = NSEvent.mouseLocation; var f = w.frame
        f.origin.x = ml.x - f.width/2; f.origin.y = ml.y - f.height - 20
        let sf = NSScreen.main?.visibleFrame ?? .zero
        if f.maxX > sf.maxX { f.origin.x = sf.maxX - f.width - 8 }
        if f.minX < sf.minX { f.origin.x = sf.minX + 8 }
        if f.minY < sf.minY { f.origin.y = ml.y + 24 }
        w.setFrame(f, display: true)
    }
    func windowDidResignKey(_ notification: Notification) { hide() }
}
