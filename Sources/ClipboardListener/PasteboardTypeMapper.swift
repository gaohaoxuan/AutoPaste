import AppKit
enum PasteboardTypeMapper {
    static func detectType(from pasteboard: NSPasteboard) -> ClipboardItemType? {
        let types = pasteboard.availableTypes()
        if types.contains(.fileURL) { return .file }
        if types.contains(.html) { return .html }
        let imageTypes: Set<NSPasteboard.PasteboardType> = [
            .tiff, .png,
            NSPasteboard.PasteboardType("public.jpeg"),
            NSPasteboard.PasteboardType("com.compuserve.gif"),
            NSPasteboard.PasteboardType("org.webmproject.webp"),
        ]
        if !Set(types).intersection(imageTypes).isEmpty { return .image }
        if types.contains(.string) {
            let text = pasteboard.string(forType: .string) ?? ""
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return .text
            }
        }
        return nil
    }
    static func extractItem(from pasteboard: NSPasteboard, type: ClipboardItemType) -> ClipboardItem? {
        var item = ClipboardItem(type: type, content: "")
        switch type {
        case .text:
            guard let text = pasteboard.string(forType: .string) else { return nil }
            item.content = text
        case .image:
            guard let data = pasteboard.imageData() else { return nil }
            item.data = data
            item.content = "[Image]"
        case .html:
            guard let html = pasteboard.htmlString() else { return nil }
            item.content = html
        case .file:
            let urls = pasteboard.fileURLData()
            guard !urls.isEmpty else { return nil }
            let pathStrings = urls.map { $0.absoluteString }
            if let jsonData = try? JSONEncoder().encode(pathStrings) {
                item.fileBookmark = jsonData
            }
            let names = urls.map { $0.lastPathComponent }
            item.content = names.joined(separator: ", ")
        }
        ClipboardItemPreview.generate(for: &item)
        return item
    }
}
