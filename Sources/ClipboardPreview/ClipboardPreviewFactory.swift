import SwiftUI
enum ClipboardPreviewFactory {
    @ViewBuilder
    static func view(for item: ClipboardItem) -> some View {
        switch item.type {
        case .text:
            TextPreviewView(text: item.content)
        case .image:
            if let data = item.data, let nsImage = NSImage(data: data) {
                ImagePreviewView(image: Image(nsImage: nsImage))
            } else {
                Text("No image data")
                    .foregroundColor(.secondary)
            }
        case .html:
            HTMLPreviewView(htmlContent: item.content)
        case .file:
            if let urls = try? item.fileURLs() {
                FilePreviewView(fileURLs: urls)
            } else {
                Text(item.preview)
                    .foregroundColor(.secondary)
            }
        }
    }
}
