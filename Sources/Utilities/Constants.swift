import Foundation
enum Constants {
    static let appName = "Paste"
    static let defaultMaxHistoryCount = 100
    static let defaultHotkeyModifiers: UInt = 0x0100 | 0x0200
    static let defaultHotkeyKeyCode: UInt = 9
    static let databaseFilename = "paste.db"
    static let imageCacheFolderName = "Images"
    static var cacheDirectory: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent(appName)
    }
    static var databaseURL: URL { cacheDirectory.appendingPathComponent(databaseFilename) }
    static var imageCacheDirectory: URL { cacheDirectory.appendingPathComponent(imageCacheFolderName) }
}
extension CGFloat {
    static let clipboardWindowWidth: CGFloat = 360
    static let clipboardWindowMaxHeight: CGFloat = 500
    static let clipboardItemRowHeight: CGFloat = 52
}
