import SwiftUI
struct FilePreviewView: View {
    let fileURLs: [URL]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(fileURLs, id: \.self) { url in
                HStack(spacing: 8) {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text(url.lastPathComponent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
}
