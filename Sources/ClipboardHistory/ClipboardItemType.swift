import Foundation
enum ClipboardItemType: Int, Codable, CaseIterable {
    case text = 0; case image = 1; case html = 2; case file = 3
    var displayName: String {
        switch self {
        case .text: "文本"
        case .image: "图片"
        case .html: "HTML"
        case .file: "文件"
        }
    }
}
