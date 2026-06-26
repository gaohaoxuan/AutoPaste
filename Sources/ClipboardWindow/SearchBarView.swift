import SwiftUI
import AppKit
struct SearchBarView: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = "搜索剪贴板..."
    func makeNSView(context: Context) -> NSSearchField {
        let sf = NSSearchField()
        sf.placeholderString = placeholder
        sf.delegate = context.coordinator
        sf.focusRingType = .none
        sf.bezelStyle = .roundedBezel
        return sf
    }
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text { nsView.stringValue = text }
    }
    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }
        func controlTextDidChange(_ obj: Notification) {
            if let sf = obj.object as? NSSearchField { text = sf.stringValue }
        }
    }
}
