import Combine
import SwiftUI
@MainActor
final class ClipboardManager: ObservableObject {
    let history = ClipboardHistory()
    let settings = ClipboardSettings()
    private let hotkey = ClipboardHotkey()
    private var storage: ClipboardStorage?
    private var windowController: ClipboardWindowController?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    func startSync() {
        do {
            storage = try ClipboardStorage()
            if let items = try? storage?.load() { history.replaceAll(with: items) }
        } catch { print("Storage error: \(error)") }
        let testItem = ClipboardItem(type: .text, content: "✅ Paste 已启动")
        history.add(testItem)
        windowController = ClipboardWindowController(history: history)
        windowController?.manager = self
        hotkey.register(modifiers: settings.hotkeyModifiers, keyCode: settings.hotkeyKeyCode)
        hotkey.onHotkeyPressed = { [weak self] in
            Task { @MainActor in self?.scanClipboard(); self?.windowController?.toggle() }
        }
        settings.$hotkeyModifiers.combineLatest(settings.$hotkeyKeyCode)
            .dropFirst()
            .sink { [weak self] m, c in self?.hotkey.register(modifiers: m, keyCode: c) }
            .store(in: &cancellables)
    }
    func scanClipboard() {
        guard let type = PasteboardTypeMapper.detectType(from: NSPasteboard.general),
              var item = PasteboardTypeMapper.extractItem(from: NSPasteboard.general, type: type) else { return }
        if item.type == .image, let d = item.data, let p = try? storage?.cacheImage(data: d, id: item.id) { item.imageCachePath = p }
        history.add(item)
    }
    func openSettings() {
        if settingsWindow == nil {
            let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 420, height: 320),
                styleMask: [.titled, .closable], backing: .buffered, defer: false)
            win.title = "Paste 设置"
            win.contentView = NSHostingView(rootView: SettingsView(settings: settings))
            win.center(); win.isReleasedWhenClosed = false
            settingsWindow = win
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    func stop() { hotkey.unregister(); try? storage?.clear() }
}
