import Testing
import AppKit
@testable import Paste
@Suite struct ClipboardItemTests {
    @Test func testItemCreation() {
        let item = ClipboardItem(type: .text, content: "Hello World")
        #expect(item.type == .text)
        #expect(item.content == "Hello World")
        #expect(!item.isPinned)
    }
    @Test func testItemPinToggle() {
        var item = ClipboardItem(type: .text, content: "test")
        #expect(!item.isPinned)
        item.togglePin()
        #expect(item.isPinned)
        item.togglePin()
        #expect(!item.isPinned)
    }
    @Test func testPreviewGeneration() {
        var textItem = ClipboardItem(type: .text, content: "Hello World")
        ClipboardItemPreview.generate(for: &textItem)
        #expect(textItem.preview == "Hello World")
        var imageItem = ClipboardItem(type: .image, content: "")
        ClipboardItemPreview.generate(for: &imageItem)
        #expect(imageItem.preview == "[Image]")
    }
}
@Suite struct ClipboardHistoryTests {
    @Test @MainActor func testAddItem() {
        let history = ClipboardHistory()
        let item = ClipboardItem(type: .text, content: "test")
        history.add(item)
        #expect(history.items.count == 1)
    }
    @Test @MainActor func testDuplicatePrevention() {
        let history = ClipboardHistory()
        let item1 = ClipboardItem(type: .text, content: "same")
        history.add(item1)
        let item2 = ClipboardItem(type: .text, content: "same")
        history.add(item2)
        #expect(history.items.count == 1)
    }
    @Test @MainActor func testDeleteItem() {
        let history = ClipboardHistory()
        let item = ClipboardItem(type: .text, content: "test")
        history.add(item)
        history.delete(item)
        #expect(history.items.isEmpty)
    }
    @Test @MainActor func testClearAllKeepsPinned() {
        let history = ClipboardHistory()
        var pinnedItem = ClipboardItem(type: .text, content: "pinned")
        pinnedItem.togglePin()
        history.add(ClipboardItem(type: .text, content: "unpinned"))
        history.add(pinnedItem)
        history.clearAll()
        #expect(history.items.count == 1)
        #expect(history.items.first!.isPinned)
    }
    @Test @MainActor func testMaxLimit() {
        let history = ClipboardHistory()
        history.maxCount = 3
        for i in 0..<5 {
            history.add(ClipboardItem(type: .text, content: "item \(i)"))
        }
        #expect(history.items.count == 3)
    }
}
@Suite struct ClipboardSearchTests {
    @Test func testSearchText() {
        let search = ClipboardSearch()
        let items = [
            ClipboardItem(type: .text, content: "Hello World", preview: "Hello World"),
            ClipboardItem(type: .text, content: "Goodbye", preview: "Goodbye"),
        ]
        let result = search.filter(items: items, query: "hello")
        #expect(result.count == 1)
        #expect(result.first!.content == "Hello World")
    }
    @Test func testSearchEmptyQuery() {
        let search = ClipboardSearch()
        let items = [ClipboardItem(type: .text, content: "Hello", preview: "Hello")]
        let result = search.filter(items: items, query: "")
        #expect(result.count == 1)
    }
}
