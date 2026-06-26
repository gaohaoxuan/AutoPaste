import Foundation
enum ClipboardItemPreview {
    static func generate(for item: inout ClipboardItem) {
        switch item.type {
        case .text: item.preview = trunc(item.content)
        case .image: item.preview = "[图片]"
        case .html: item.preview = trunc(item.plainTextContent ?? "")
        case .file:
            if let urls = try? item.fileURLs() { item.preview = urls.map{$0.lastPathComponent}.joined(separator: ", ") }
            else { item.preview = "[文件]" }
        }
    }
    private static func trunc(_ t: String, max: Int = 100) -> String {
        let c = t.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\r", with: " ")
        if c.count <= max { return c.isEmpty ? "[空]" : c }
        return String(c[..<c.index(c.startIndex, offsetBy: max)]) + "…"
    }
}
