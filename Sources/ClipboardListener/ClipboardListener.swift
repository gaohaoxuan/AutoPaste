import AppKit
import Foundation
final class ClipboardListener: @unchecked Sendable {
    private var source: DispatchSourceTimer?
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    var onNewItem: ((ClipboardItem) -> Void)?
    private let logFile: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Paste")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("listener.log")
    }()
    private func log(_ msg: String) {
        let line = "\(Date().timeIntervalSince1970) \(msg)\n"
        if let data = line.data(using: .utf8) {
            if let fh = try? FileHandle(forWritingTo: logFile) {
                fh.seekToEndOfFile(); fh.write(data); try? fh.close()
            } else { try? data.write(to: logFile) }
        }
    }
    func start() {
        log("START listener cc=\(lastChangeCount)")
        let s = DispatchSource.makeTimerSource(queue: .main)
        s.schedule(deadline: .now(), repeating: .milliseconds(500))
        s.setEventHandler { [weak self] in self?.poll() }
        s.resume()
        source = s
    }
    func stop() { source?.cancel(); source = nil; log("STOP") }
    private func poll() {
        let cc = pasteboard.changeCount
        guard cc != lastChangeCount else { return }
        log("CHANGE cc: \(lastChangeCount) → \(cc)")
        lastChangeCount = cc
        let types = pasteboard.availableTypes().map(\.rawValue)
        log("TYPES: \(types.joined(separator: "|"))")
        if let itemType = PasteboardTypeMapper.detectType(from: pasteboard),
           let item = PasteboardTypeMapper.extractItem(from: pasteboard, type: itemType) {
            log("CAPTURED type=\(itemType) preview=\(item.preview)")
            onNewItem?(item)
        } else { log("SKIP") }
    }
}
