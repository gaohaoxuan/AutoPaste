import Foundation
struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    var type: ClipboardItemType
    var content: String
    var data: Data?
    var imageCachePath: String?
    var fileBookmark: Data?
    var preview: String
    var timestamp: Date
    var isPinned: Bool
    init(
        id: UUID = UUID(),
        type: ClipboardItemType,
        content: String,
        data: Data? = nil,
        imageCachePath: String? = nil,
        fileBookmark: Data? = nil,
        preview: String = "",
        timestamp: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.data = data
        self.imageCachePath = imageCachePath
        self.fileBookmark = fileBookmark
        self.preview = preview
        self.timestamp = timestamp
        self.isPinned = isPinned
    }
    mutating func togglePin() {
        isPinned.toggle()
    }
    func fileURLs() throws -> [URL] {
        guard type == .file, let bookmark = fileBookmark else { return [] }
        let urls = try JSONDecoder().decode([String].self, from: bookmark).compactMap { URL(string: $0) }
        return urls
    }
    var plainTextContent: String? {
        guard type == .html else { return nil }
        guard let data = content.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil).string
    }
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }
}
