import SwiftUI
struct ImagePreviewView: View {
    let image: Image
    var body: some View {
        GeometryReader { g in
            image.resizable().aspectRatio(contentMode: .fit)
                .frame(maxWidth: g.size.width, maxHeight: g.size.height).padding()
        }
    }
}
