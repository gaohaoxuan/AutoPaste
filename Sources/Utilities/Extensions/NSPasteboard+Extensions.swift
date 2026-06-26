import AppKit

extension NSPasteboard {
    func availableTypes() -> [NSPasteboard.PasteboardType] {
        types ?? []
    }

    func hasFileURLs() -> Bool {
        availableTypes().contains(.fileURL)
    }

    func fileURLData() -> [URL] {
        guard let items = pasteboardItems else { return [] }
        var urls: [URL] = []
        for item in items {
            if let path = item.string(forType: .fileURL),
               let url = URL(string: path) {
                urls.append(url)
            }
        }
        return urls
    }

    func hasHTML() -> Bool {
        availableTypes().contains(.html)
    }

    func htmlString() -> String? {
        string(forType: .html)
    }

    func hasImage() -> Bool {
        let imageTypes: Set<NSPasteboard.PasteboardType> = [
            .tiff, .png,
            NSPasteboard.PasteboardType("public.jpeg"),
            NSPasteboard.PasteboardType("com.compuserve.gif"),
            NSPasteboard.PasteboardType("org.webmproject.webp"),
        ]
        let available = Set(availableTypes())
        return !available.intersection(imageTypes).isEmpty
    }

    func imageData() -> Data? {
        if let tiffData = data(forType: .tiff) {
            return tiffData
        }
        if let pngData = data(forType: .png) {
            return pngData
        }
        if let jpgData = data(forType: NSPasteboard.PasteboardType("public.jpeg")) {
            return jpgData
        }
        if let gifData = data(forType: NSPasteboard.PasteboardType("com.compuserve.gif")) {
            return gifData
        }
        return nil
    }

    func restoreClipboard(item: ClipboardItem) {
        clearContents()
        switch item.type {
        case .text:
            setString(item.content, forType: .string)
        case .image:
            if let data = item.data {
                if let image = NSImage(data: data) {
                    let tiffData = image.tiffRepresentation!
                    let rep = NSBitmapImageRep(data: tiffData)!
                    let pngData = rep.representation(using: .png, properties: [:])!
                    setData(pngData, forType: .png)
                    setData(tiffData, forType: .tiff)
                }
            }
        case .html:
            setString(item.content, forType: .html)
            if let plainText = item.plainTextContent {
                setString(plainText, forType: .string)
            }
        case .file:
            if let urls = try? item.fileURLs() {
                let filePaths = urls.map { $0.absoluteString }
                let plistData = try! PropertyListSerialization.data(fromPropertyList: filePaths, format: .binary, options: 0)
                setPropertyList(plistData, forType: .fileURL)
            }
        }
    }
}
