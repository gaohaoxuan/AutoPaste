import Foundation
import Combine
class ClipboardHistory: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var searchQuery: String = ""
    var maxCount: Int = Constants.defaultMaxHistoryCount { didSet { enforceLimit() } }
    private let searchEngine = ClipboardSearch()
    var filteredItems: [ClipboardItem] {
        let pinned = items.filter { $0.isPinned }
        let unpinned = items.filter { !$0.isPinned }
        if searchQuery.isEmpty { return pinned + unpinned }
        return searchEngine.filter(items: pinned, query: searchQuery)
            + searchEngine.filter(items: unpinned, query: searchQuery)
    }
    func add(_ item: ClipboardItem) {
        var newItem = item
        ClipboardItemPreview.generate(for: &newItem)
        guard !isDuplicate(newItem) else { return }
        items.insert(newItem, at: 0)
        enforceLimit()
    }
    func delete(_ item: ClipboardItem) { items.removeAll { $0.id == item.id } }
    func togglePin(_ item: ClipboardItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isPinned.toggle()
    }
    func clearAll() { items.removeAll { !$0.isPinned } }
    func replaceAll(with newItems: [ClipboardItem]) { items = newItems; enforceLimit() }
    private func isDuplicate(_ item: ClipboardItem) -> Bool {
        guard let first = items.first else { return false }
        if first.content == item.content && first.type == item.type { return true }
        if let d1 = first.data, let d2 = item.data, d1 == d2 { return true }
        return false
    }
    private func enforceLimit() {
        let unpinned = items.filter { !$0.isPinned }
        guard unpinned.count > maxCount else { return }
        let ids = unpinned.suffix(unpinned.count - maxCount).map(\.id)
        items.removeAll { ids.contains($0.id) }
    }
}
