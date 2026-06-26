import Foundation

enum PasteError: LocalizedError {
    case databaseError(String)
    case storageError(String)
    case cacheError(String)

    var errorDescription: String? {
        switch self {
        case .databaseError(let msg): "Database error: \(msg)"
        case .storageError(let msg): "Storage error: \(msg)"
        case .cacheError(let msg): "Cache error: \(msg)"
        }
    }
}
