import Foundation
final class ClipboardStorage {
    private let database: Database
    private let imageCache: ImageCache
    init() throws { self.database = try Database(); self.imageCache = try ImageCache() }
    func load() throws -> [ClipboardItem] {
        let items = try database.loadItems()
        var result: [ClipboardItem] = []
        for var item in items {
            if item.type == .image, let path = item.imageCachePath, let data = imageCache.loadImage(path: path) {
                item.data = data
            }
            result.append(item)
        }
        return result
    }
    func cacheImage(data: Data, id: UUID) throws -> String { try imageCache.saveImage(data: data, id: id) }
    func clear() throws { try database.clearAll(); try? imageCache.cleanupOrphaned(validPaths: []) }
}
