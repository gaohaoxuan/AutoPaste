import Foundation
import Combine
import Carbon
final class ClipboardSettings: ObservableObject {
    @Published var maxHistoryCount: Int { didSet { UserDefaults.standard.set(maxHistoryCount, forKey: "maxHistoryCount") } }
    @Published var hotkeyModifiers: UInt { didSet { UserDefaults.standard.set(hotkeyModifiers, forKey: "hotkeyModifiers") } }
    @Published var hotkeyKeyCode: UInt { didSet { UserDefaults.standard.set(hotkeyKeyCode, forKey: "hotkeyKeyCode") } }
    init() {
        let d = UserDefaults.standard
        let c = d.integer(forKey: "maxHistoryCount")
        maxHistoryCount = c > 0 ? c : Constants.defaultMaxHistoryCount
        hotkeyModifiers = d.object(forKey: "hotkeyModifiers") as? UInt ?? Constants.defaultHotkeyModifiers
        hotkeyKeyCode = d.object(forKey: "hotkeyKeyCode") as? UInt ?? Constants.defaultHotkeyKeyCode
    }
    var hotkeyDescription: String {
        var p: [String] = []
        let m = hotkeyModifiers
        if m & UInt(cmdKey) != 0 { p.append("⌘") }
        if m & UInt(shiftKey) != 0 { p.append("⇧") }
        if m & UInt(optionKey) != 0 { p.append("⌥") }
        if m & UInt(controlKey) != 0 { p.append("⌃") }
        p.append(k(Int(hotkeyKeyCode)))
        return p.joined()
    }
    private func k(_ c: Int) -> String {
        [0:"A",1:"S",2:"D",3:"F",4:"H",5:"G",6:"Z",7:"X",8:"C",9:"V",11:"B",12:"Q",13:"W",14:"E",15:"R",16:"Y",17:"T",31:"O",32:"U",34:"I",35:"P",45:"N",46:"M",49:"Space"][c] ?? "Key(\(c))"
    }
}
