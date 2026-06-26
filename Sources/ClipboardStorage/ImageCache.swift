import Foundation
import AppKit

final class ImageCache {
    private let fileManager = FileManager.default

    init() throws {
        let dir = Constants.imageCacheDirectory
        if !fileManager.fileExists(atPath: dir.path) {
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    func saveImage(data: Data, id: UUID) throws -> String {
        let filename = "\(id.uuidString).png"
        let url = Constants.imageCacheDirectory.appendingPathComponent(filename)
        if let image = NSImage(data: data),
           let tiff = image.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let pngData = rep.representation(using: .png, properties: [:]) {
            try pngData.write(to: url)
        } else {
            try data.write(to: url)
        }
        return filename
    }

    func loadImage(path: String) -> Data? {
        let url = Constants.imageCacheDirectory.appendingPathComponent(path)
        return try? Data(contentsOf: url)
    }

    func deleteImage(path: String) throws {
        let url = Constants.imageCacheDirectory.appendingPathComponent(path)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    func cleanupOrphaned(validPaths: Set<String>) throws {
        let dir = Constants.imageCacheDirectory
        guard fileManager.fileExists(atPath: dir.path) else { return }
        let files = try fileManager.contentsOfDirectory(atPath: dir.path)
        for file in files {
            if !validPaths.contains(file) {
                try? fileManager.removeItem(at: dir.appendingPathComponent(file))
            }
        }
    }
}
