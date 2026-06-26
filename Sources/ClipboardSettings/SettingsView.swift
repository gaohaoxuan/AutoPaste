import SwiftUI
struct SettingsView: View {
    @ObservedObject var settings: ClipboardSettings
    @State private var historyCount: String = ""
    var body: some View {
        TabView {
            Form {
                Section {
                    HStack {
                        Text("最大历史记录数：")
                        Spacer()
                        TextField("100", text: $historyCount)
                            .frame(width: 80)
                            .onSubmit { if let v = Int(historyCount), v > 0 { settings.maxHistoryCount = v } }
                            .onAppear { historyCount = "\(settings.maxHistoryCount)" }
                    }
                } header: { Text("历史") }
                Section {
                    HStack {
                        Text("当前快捷键：")
                        Spacer()
                        Text(settings.hotkeyDescription).monospaced().foregroundColor(.accentColor)
                    }
                } header: { Text("快捷键") }
            }
            .formStyle(.grouped)
            .tabItem { Label("通用", systemImage: "gearshape") }
        }
        .frame(width: 420, height: 250)
    }
}
