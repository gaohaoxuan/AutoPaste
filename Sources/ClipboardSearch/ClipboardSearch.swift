import Foundation

struct ClipboardSearch {
    func filter(items: [ClipboardItem], query: String) -> [ClipboardItem] {
        guard !query.isEmpty else { return items }
        let lowercased = query.lowercased()
        return items.filter { item in
            if item.preview.lowercased().contains(lowercased) {
                return true
            }
            if item.type == .text || item.type == .html {
                if item.content.lowercased().contains(lowercased) {
                    return true
                }
            }
            return false
        }
    }
}
