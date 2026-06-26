import Foundation
import SQLite3
final class Database {
    private var db: OpaquePointer?
    init() throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: Constants.cacheDirectory.path) {
            try fm.createDirectory(at: Constants.cacheDirectory, withIntermediateDirectories: true)
        }
        if sqlite3_open(Constants.databaseURL.path, &db) != SQLITE_OK {
            throw PasteError.databaseError(String(cString: sqlite3_errmsg(db)))
        }
        try createTables()
    }
    deinit { sqlite3_close(db) }
    private func createTables() throws {
        try exec("CREATE TABLE IF NOT EXISTS clipboard_items (id TEXT PRIMARY KEY, type INTEGER NOT NULL, content TEXT NOT NULL DEFAULT '', data BLOB, image_cache_path TEXT, file_bookmark BLOB, preview TEXT NOT NULL DEFAULT '', timestamp REAL NOT NULL, is_pinned INTEGER NOT NULL DEFAULT 0);")
    }
    func saveItems(_ items: [ClipboardItem]) throws {
        try exec("DELETE FROM clipboard_items")
        let sql = "INSERT INTO clipboard_items (id,type,content,data,image_cache_path,file_bookmark,preview,timestamp,is_pinned) VALUES (?,?,?,?,?,?,?,?,?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { throw PasteError.databaseError(String(cString: sqlite3_errmsg(db))) }
        defer { sqlite3_finalize(stmt) }
        for item in items {
            sqlite3_bind_text(stmt, 1, item.id.uuidString, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_int(stmt, 2, Int32(item.type.rawValue))
            sqlite3_bind_text(stmt, 3, item.content, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            if let d = item.data { _ = d.withUnsafeBytes { sqlite3_bind_blob(stmt, 4, $0.baseAddress, Int32(d.count), unsafeBitCast(-1, to: sqlite3_destructor_type.self)) } } else { sqlite3_bind_null(stmt, 4) }
            if let p = item.imageCachePath { sqlite3_bind_text(stmt, 5, p, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self)) } else { sqlite3_bind_null(stmt, 5) }
            if let b = item.fileBookmark { _ = b.withUnsafeBytes { sqlite3_bind_blob(stmt, 6, $0.baseAddress, Int32(b.count), unsafeBitCast(-1, to: sqlite3_destructor_type.self)) } } else { sqlite3_bind_null(stmt, 6) }
            sqlite3_bind_text(stmt, 7, item.preview, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_double(stmt, 8, item.timestamp.timeIntervalSince1970)
            sqlite3_bind_int(stmt, 9, item.isPinned ? 1 : 0)
            guard sqlite3_step(stmt) == SQLITE_DONE else { throw PasteError.databaseError(String(cString: sqlite3_errmsg(db))) }
            sqlite3_reset(stmt)
        }
    }
    func loadItems() throws -> [ClipboardItem] {
        let sql = "SELECT id,type,content,data,image_cache_path,file_bookmark,preview,timestamp,is_pinned FROM clipboard_items ORDER BY rowid;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { throw PasteError.databaseError(String(cString: sqlite3_errmsg(db))) }
        defer { sqlite3_finalize(stmt) }
        var items: [ClipboardItem] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let idStr = String(cString: sqlite3_column_text(stmt, 0))
            let tr = Int(sqlite3_column_int(stmt, 1))
            let content = String(cString: sqlite3_column_text(stmt, 2))
            var data: Data? = nil
            if let blob = sqlite3_column_blob(stmt, 3) { data = Data(bytes: blob, count: Int(sqlite3_column_bytes(stmt, 3))) }
            var cp: String? = nil; if let c = sqlite3_column_text(stmt, 4) { cp = String(cString: c) }
            var bm: Data? = nil; if let b = sqlite3_column_blob(stmt, 5) { bm = Data(bytes: b, count: Int(sqlite3_column_bytes(stmt, 5))) }
            let preview = String(cString: sqlite3_column_text(stmt, 6))
            let ts = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 7))
            let pinned = sqlite3_column_int(stmt, 8) != 0
            guard let id = UUID(uuidString: idStr), let type = ClipboardItemType(rawValue: tr) else { continue }
            items.append(ClipboardItem(id: id, type: type, content: content, data: data, imageCachePath: cp, fileBookmark: bm, preview: preview, timestamp: ts, isPinned: pinned))
        }
        return items
    }
    func clearAll() throws { try exec("DELETE FROM clipboard_items") }
    private func exec(_ sql: String) throws {
        var err: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            let msg = err.map { String(cString: $0) } ?? "unknown"; sqlite3_free(err); throw PasteError.databaseError(msg)
        }
    }
}
