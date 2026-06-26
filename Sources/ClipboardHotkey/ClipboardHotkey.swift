import Carbon
import Foundation
import AppKit
final class ClipboardHotkey: @unchecked Sendable {
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let kEventHotKeyPressed: UInt32 = 5
    var onHotkeyPressed: (() -> Void)?
    func register(modifiers: UInt = Constants.defaultHotkeyModifiers,
                  keyCode: UInt = Constants.defaultHotkeyKeyCode) {
        unregister()
        var hotkeyID = EventHotKeyID()
        hotkeyID.signature = OSType(0x70617374)
        hotkeyID.id = 1
        let modifierFlags = UInt32(modifiers)
        let keyCode32 = UInt32(keyCode)
        let status = RegisterEventHotKey(keyCode32, modifierFlags, hotkeyID,
                                         GetApplicationEventTarget(), 0, &hotkeyRef)
        if status == noErr {
            print("✅ Hotkey registered: ⌘⇧V (status \(status))")
        } else {
            print("⚠️ Hotkey failed: status \(status). Go to System Settings → Privacy & Security → Accessibility and add Paste.app, then restart.")
        }
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        _ = InstallEventHandler(GetApplicationEventTarget(), { (_, event, userData) -> OSStatus in
            guard let userData = userData else { return -1 }
            let myself = Unmanaged<ClipboardHotkey>.fromOpaque(userData).takeUnretainedValue()
            let callback = myself.onHotkeyPressed
            DispatchQueue.main.async { callback?() }
            return noErr
        }, 1, &eventSpec, selfPtr, &eventHandlerRef)
    }
    func unregister() {
        if let ref = hotkeyRef { UnregisterEventHotKey(ref); hotkeyRef = nil }
        if let ref = eventHandlerRef { RemoveEventHandler(ref); eventHandlerRef = nil }
    }
    deinit { unregister() }
}
