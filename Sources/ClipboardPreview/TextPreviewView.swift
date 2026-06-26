import SwiftUI
struct TextPreviewView: View {
    let text: String
    var body: some View {
        ScrollView {
            Text(text).textSelection(.enabled).font(.body)
                .frame(maxWidth: .infinity, alignment: .leading).padding()
        }
    }
}
